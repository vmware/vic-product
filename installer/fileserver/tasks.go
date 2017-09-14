// Copyright 2017 VMware, Inc. All Rights Reserved.
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

package main

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic/pkg/vsphere/optmanager"
)

const (
	pscBinaryPath    = "/etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar"
	vcHostnameOption = "config.vpxd.hostnameUrl"
	pscConfDir       = "/etc/vmware/psc"
	pscConfFileName  = "psc-config.properties"
)

// registerWithPSC runs the PSC register command to register VIC services with
// the platforms services controller. The command generates config files and
// keystore files to use while getting and renewing tokens.
func registerWithPSC(ctx context.Context) error {
	var err error

	// Obtain the admin user's domain
	domain := "vsphere.local"
	userFields := strings.SplitN(admin.User, "@", 2)
	if len(userFields) == 2 {
		domain = userFields[1]
	}

	if pscInstance == "" {
		// Obtain the hostname of the vCenter host to use as PSC instance
		pscInstance, err = optmanager.QueryOptionValue(ctx, admin.Validator.Session, vcHostnameOption)
		if err != nil {
			return err
		}
	}
	if pscDomain != "" {
		log.Infof("User domain: %s PSC domain: %s. Using %s", domain, pscDomain, pscDomain)
		domain = pscDomain
	}
	log.Infof("vCenter user: %s", admin.User)
	log.Infof("PSC instance: %s", pscInstance)
	log.Infof("PSC domain: %s", domain)

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
	admiralPort := ovf.Properties["management_portal.port"]

	// Out of the box users
	defCreateUsers, foundCreateUsers := ovf.Properties["default_users.create_def_users"]
	defPrefix, foundPrefix := ovf.Properties["default_users.def_user_prefix"]
	defPassword, foundPassword := ovf.Properties["default_users.def_user_password"]

	log.Infof("PSC Out of the box users. CreateUsers: %s, FoundCreateUsers: %v, Prefix: %s",
		defCreateUsers, foundCreateUsers, defPrefix)

	// Register all VIC components with PSC
	cmdName := "/usr/bin/java"
	for _, client := range []string{"harbor", "engine", "admiral"} {
		pscConfFile := filepath.Join(pscConfDir, client, pscConfFileName)
		if _, err := os.Stat(pscConfFile); err == nil {
			log.Infof("Skipping registering %s with PSC since PSC config file is present", client)
			continue
		}

		cmdArgs := []string{
			"-jar",
			pscBinaryPath,
			"--command=register",
			"--clientName=" + client,
			// NOTE(anchal): version set to 6.0 to use SAML for both versions 6.0 and 6.5
			"--version=6.0",
			"--tenant=" + domain,
			"--domainController=" + pscInstance,
			"--username=" + admin.User,
			"--password=" + admin.Password,
			"--admiralUrl=" + fmt.Sprintf("https://%s:%s", vmIP.String(), admiralPort),
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
			log.Infof("Error running PSC register command for %s: %s", client, string(output))
			return err
		}
		log.Infof("Successfully registered %s with PSC", client)
	}

	return nil
}
