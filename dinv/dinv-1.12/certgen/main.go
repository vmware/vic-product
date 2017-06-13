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

package main

import (
	"io/ioutil"
	"net"
	"os"

	log "github.com/Sirupsen/logrus"
	"github.com/vmware/vic/pkg/certificate"
)

func main() {
	var err error
	files := []string{"/certs/docker.key", "/certs/docker.crt"}

	for _, file := range files {
		if _, err = os.Stat(file); err == nil {
			log.Errorf("File: %s exists. Exiting.", file)
			os.Exit(1)

		}
	}

	iface, err := net.InterfaceByName("eth0")
	if err != nil {
		log.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
		os.Exit(1)
	}
	addrs, err := iface.Addrs()
	if err != nil {
		log.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
		os.Exit(1)
	}
	for _, addr := range addrs {
		var ip net.IP
		switch v := addr.(type) {
		case *net.IPNet:
			ip = v.IP
		case *net.IPAddr:
			ip = v.IP
		}
		// If the IP is a loopback address an ipv6, we don't need it
		if ip.IsLoopback() || ip.To4() == nil {
			continue
		}
		log.Info("Generating self signed certificate")
		c, k, err := certificate.CreateSelfSigned(ip.String(), []string{"VMware, Inc."}, 2048)
		if err != nil {
			log.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
		log.Info("writing self signed certificates")
		if err := ioutil.WriteFile("/certs/docker.key", k.Bytes(), 0444); err != nil {
			log.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
		if err := ioutil.WriteFile("/certs/docker.crt", c.Bytes(), 0444); err != nil {
			log.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
		// We got what we need, let's break
		break
	}
}
