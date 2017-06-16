// Copyright 2016-2017 VMware, Inc. All Rights Reserved.
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
//
// +build linux

package main

import (
	"fmt"
	"os/exec"
	"strings"
)

type NetworkStatus struct {
	down     string
	up       string
	ovfProps map[string]string
}

func (nstat *NetworkStatus) GetDNSStatus() string {
	dnsExpected := strings.FieldsFunc(nstat.ovfProps["network.DNS"],
		func(char rune) bool { return char == ',' || char == ' ' })

	command := `cat /etc/resolv.conf | grep nameserver | awk '{print $2}';`

	return nstat.addressPresenceHelper(dnsExpected, command)
}

func (nstat *NetworkStatus) GetIPStatus() string {
	ipsExpected := strings.FieldsFunc(nstat.ovfProps["network.ip0"],
		func(char rune) bool { return char == ',' || char == ' ' })

	command := `ifconfig | grep "inet" | awk '{print $2}' | sed -e 's/^[ \t]*//' | sed -e 's/[addr:]//g' | sed  '/^$/d';`
	return nstat.addressPresenceHelper(ipsExpected, command)
}

func (nstat *NetworkStatus) GetGatewayStatus() string {
	gatewayExpected := strings.FieldsFunc(nstat.ovfProps["network.gateway"],
		func(char rune) bool { return char == ',' || char == ' ' })

	command := `netstat -nr | grep 0.0.0.0 | head -n 1 | awk '{print $2}';`
	return nstat.addressPresenceHelper(gatewayExpected, command)
}

func (nstat *NetworkStatus) addressPresenceHelper(expectedAddresses []string, command string) string {
	if len(expectedAddresses) == 0 {
		return nstat.up
	}

	out, err := exec.Command("/bin/bash", "-c", command).Output()
	if err != nil {
		fmt.Printf("%#v\n%s", err, err.Error())
		return nstat.down
	}
	actualAddresses := strings.Split(string(out), "\n")
	allAddresses := make(map[string]struct{})

	for _, addr := range actualAddresses {
		allAddresses[addr] = struct{}{}
	}
	for _, addr := range expectedAddresses {
		allAddresses[addr] = struct{}{}
	}

	// equal lengths implies no members in expectedAddresses matched with actualAddresses
	if len(allAddresses) == (len(actualAddresses) + len(expectedAddresses)) {
		return fmt.Sprintf("%s -- OVF set address as: %s but addresses were: %s", nstat.down, expectedAddresses, actualAddresses)
	}
	return nstat.up

}
