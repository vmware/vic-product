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
	"fmt"
	"io/ioutil"
	"net"
	"os"

	"github.com/vmware/vic/pkg/certificate"
)

func certsExist(files []string) error {
	for _, file := range files {
		if _, err := os.Stat(file); err != nil {
			return err
		}
	}

	return nil
}

func getFirstIP(ifname string) (net.IP, error) {
	iface, err := net.InterfaceByName(ifname)
	if err != nil {
		return nil, fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}
	addrs, err := iface.Addrs()
	if err != nil {
		return nil, fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
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
		return ip, nil
	}

	return nil, fmt.Errorf("Can't find %s IP address", ifname)
}

// If tlsverify is set, but no certificates are available, we create CA, server and
// client certs, this is a sort of "last resort" for people who want to try out
// dinv but not wanting to create certs on their machine, client certs can be
// downloaded from /certs.
func generateCACerts(ip net.IP) error {
	// Certificate authority
	cacrt, cakey, err := certificate.CreateRootCA(ip.String(), []string{"VMware, Inc."}, 2048)
	if err != nil {
		return fmt.Errorf("Failed to generate a self-signed CA certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/ca-key.pem", cakey.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/ca.crt", cacrt.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}

	srvcrt, srvkey, err := certificate.CreateServerCertificate(ip.String(), []string{"VMware, Inc."}, 2048, cacrt.Bytes(), cakey.Bytes())
	if err != nil {
		return fmt.Errorf("Failed to generate a CA-signed server certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/docker.key", srvkey.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/docker.crt", srvcrt.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}

	cltcrt, cltkey, err := certificate.CreateClientCertificate(ip.String(), []string{"VMware, Inc."}, 2048, cacrt.Bytes(), cakey.Bytes())
	if err != nil {
		return fmt.Errorf("Failed to generate a CA-signed client certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/docker-client.key", cltkey.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/docker-client.crt", cltcrt.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}

	return nil
}

func generateSelfSignedCerts(ip net.IP) error {
	c, k, err := certificate.CreateSelfSigned(ip.String(), []string{"VMware, Inc."}, 2048)
	if err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/docker.key", k.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}
	if err := ioutil.WriteFile("/certs/docker.crt", c.Bytes(), 0444); err != nil {
		return fmt.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
	}

	return nil
}
