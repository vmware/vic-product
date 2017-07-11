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
	"os/exec"
	"strings"

	log "github.com/sirupsen/logrus"

	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic/pkg/vsphere/optmanager"
)

const (
	pscBinaryPath    = "/etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar"
	vcHostnameOption = "config.vpxd.hostnameUrl"
	pscConfDir       = "/etc/vmware/psc"
)

// registerWithPSC runs the PSC register command to register VIC services with
// the platforms services controller. The command generates config files and
// keystore files to use while getting and renewing tokens.
func registerWithPSC(ctx context.Context) error {
	var err error

	session := admin.Validator.Session
	version := session.ServiceContent.About.Version
	versionFields := strings.Split(version, ".")
	if len(versionFields) > 2 {
		// Set version in required format (x.y)
		version = versionFields[0] + "." + versionFields[1]
	}

	// Obtain the admin user's domain
	domain := "vsphere.local"
	userFields := strings.SplitN(admin.User, "@", 2)
	if len(userFields) == 2 {
		domain = userFields[1]
	}

	// Obtain the hostname of the vCenter host
	vcHostname, err := optmanager.QueryOptionValue(ctx, session, vcHostnameOption)
	if err != nil {
		return err
	}

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

	// Register all VIC components with PSC
	cmdName := "java"
	for _, client := range []string{"admiral", "harbor", "engine"} {
		cmdArgs := []string{
			"-jar",
			pscBinaryPath,
			"--command=register",
			"--clientName=" + client,
			"--version=" + version,
			"--tenant=" + domain,
			"--domainController=" + vcHostname,
			"--username=" + admin.User,
			"--password=" + admin.Password,
			"--admiralUrl=" + fmt.Sprintf("https://%s:%s", vmIP.String(), admiralPort),
			"--configDir=" + pscConfDir,
		}
		cmd := exec.Command(cmdName, cmdArgs...)
		if output, err := cmd.CombinedOutput(); err != nil {
			log.Infof("Error running PSC register command: %s", string(output))
			return err
		}
	}

	return nil
}
