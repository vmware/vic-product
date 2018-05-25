// Copyright 2017-2018 VMware, Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package tasks

import (
	"fmt"
	"io/ioutil"
	"net"
	"os/exec"
	"strings"
	"time"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/fileserver/tasks/tagvm"
	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/optmanager"
)

const (
	// InitServicesTimestamp exists on the local fs when registration first succeeds
	InitServicesTimestamp = "./registration-timestamps.txt"
	pscBinaryPath         = "/etc/vmware/admiral/admiral-auth-psc-1.3.2-SNAPSHOT-command.jar"
	vcHostnameOption      = "config.vpxd.hostnameUrl"
	pscConfDir            = "/etc/vmware/psc"
	pscConfFileName       = "psc-config.properties"
)

// PSCRegistrationConfig holds the required data for a psc registration
type PSCRegistrationConfig struct {
	Admin       *lib.LoginInfo
	PscInstance string
	PscDomain   string
}

// NewPSCRegistrationConfig returns a PSCRegistrationConfig with a initialized Admin LoginInfo type
func NewPSCRegistrationConfig() *PSCRegistrationConfig {
	return &PSCRegistrationConfig{
		Admin: &lib.LoginInfo{},
	}
}

// RegisterAppliance runs the three processes required to register the appliance:
// TagVM, RegisterWithPSC, and SaveInitializationState
func (conf *PSCRegistrationConfig) RegisterAppliance(op trace.Operation) error {
	if err := tagvm.Run(op, conf.Admin.Session); err != nil {
		op.Debug(errors.ErrorStack(err))
		return errors.New("Failed to locate VIC Appliance. Please check the vCenter Server provided and try again")
	}

	if err := conf.RegisterWithPSC(op); err != nil {
		op.Debug(errors.ErrorStack(err))
		return errors.New("Failed to register with PSC. Please check the PSC settings provided and try again")
	}

	if err := ioutil.WriteFile(InitServicesTimestamp, []byte(time.Now().String()), 0644); err != nil {
		op.Debug(errors.ErrorStack(err))
		return errors.New("Failed to write to timestamp file")
	}

	return nil
}

// RegisterWithPSC runs the PSC register command to register VIC services with
// the platforms services controller. The command generates config files and
// keystore files to use while getting and renewing tokens.
func (conf *PSCRegistrationConfig) RegisterWithPSC(op trace.Operation) error {
	var err error

	// Use vSphere as the psc instance if external psc was not supplied
	if conf.PscInstance == "" {
		// Obtain the hostname of the vCenter host to use as PSC instance
		conf.PscInstance, err = optmanager.QueryOptionValue(op.Context, conf.Admin.Session, vcHostnameOption)
		if err != nil {
			return err
		}
	}

	// Use vSphere or user's domain as the psc domain if external psc was not supplied
	if conf.PscDomain == "" {
		// Obtain the Admin user's domain
		conf.PscDomain = "vsphere.local"
		userFields := strings.SplitN(conf.Admin.User, "@", 2)
		if len(userFields) == 2 {
			conf.PscDomain = userFields[1]
		}
	}

	op.Infof("vCenter user: %s", conf.Admin.User)
	op.Infof("PSC instance: %s", conf.PscInstance)
	op.Infof("PSC domain: %s", conf.PscDomain)

	// Obtain the OVA VM's IP
	vmIP, err := ip.FirstIPv4(ip.Eth0Interface)
	if err != nil {
		return err
	}

	// Fetch the OVF env to get the Admiral port
	ovf, err := lib.UnmarshaledOvfEnv()
	if err != nil {
		return err
	}
	admiralPort := ovf.Properties["management_portal.management_portal_port"]

	// Out of the box users
	defCreateUsers, foundCreateUsers := ovf.Properties["default_users.create_def_users"]
	defPrefix, foundPrefix := ovf.Properties["default_users.def_user_prefix"]
	defPassword, foundPassword := ovf.Properties["default_users.def_user_password"]

	op.Infof("PSC Out of the box users. CreateUsers: %s, FoundCreateUsers: %v, Prefix: %s",
		defCreateUsers, foundCreateUsers, defPrefix)

	// Register all VIC components with PSC
	cmdName := "/usr/bin/java"
	for _, client := range []string{"harbor", "engine", "admiral"} {

		cmdArgs := []string{
			"-jar",
			pscBinaryPath,
			"--command=register",
			"--clientName=" + client,
			// NOTE(anchal): version set to 6.0 to use SAML for both versions 6.0 and 6.5
			"--version=6.0",
			"--tenant=" + conf.PscDomain,
			"--domainController=" + conf.PscInstance,
			"--username=" + conf.Admin.User,
			"--password=" + conf.Admin.Password,
			"--admiralUrl=" + fmt.Sprintf("https://%s:%s", GetHostname(ovf, vmIP), admiralPort),
			"--configDir=" + pscConfDir,
		}

		if client == "admiral" && foundCreateUsers && strings.ToLower(defCreateUsers) == "true" {
			if foundPrefix && defPrefix != "" {
				arg := "--defaultUserPrefix=" + defPrefix
				cmdArgs = append(cmdArgs, arg)
			}

			if foundPassword && defPrefix != "" && defPassword != "" {
				arg := "--defaultUserPassword=" + defPassword
				cmdArgs = append(cmdArgs, arg)
			}
		}

		// #nosec: Subprocess launching with variable.
		// This runs the PSC tool's register command.
		cmd := exec.Command(cmdName, cmdArgs...)
		if output, err := cmd.CombinedOutput(); err != nil {
			op.Infof("Error running PSC register command for %s: %s", client, string(output))
			return err
		}
		op.Infof("Successfully registered %s with PSC", client)
	}

	return nil
}

// GetHostname returns the non-transient hostname of the Appliance
func GetHostname(ovf lib.Environment, vmIP net.IP) string {

	// Until we gix transient hostnames, use the static hostname reported by hostnamectl.
	// os.Hostname() returns the kernel hostname, with no regard to transient or static classifications.
	// fqdn, err := os.Hostname()
	// var url string
	// if err == nil && fqdn != "" {
	// 	return fqdn
	// } else {
	// 	return vmIP.String()
	// }

	command := "hostnamectl status --static"
	// #nosec: Subprocess launching with variable.
	out, err := exec.Command("/bin/bash", "-c", command).Output()
	if err != nil {
		log.Errorf(err.Error())
		return vmIP.String()
	}
	outString := strings.TrimSpace(string(out))
	if outString == "" {
		return vmIP.String()
	}
	return outString
}
