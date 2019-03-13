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
	"flag"
	"fmt"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	"github.com/Sirupsen/logrus"
)

// DOCKER references the docker daemon to start
const DOCKER string = "/usr/bin/dockerd"

var (
	tls              bool
	tlsverify        bool
	local            bool
	storage          string
	insecureRegistry string
	vicIP            string
	dockerArgs       []string
	port             int
)

var log = logrus.New()

func init() {
	flag.BoolVar(&tls, "tls", false, "Use TLS; implied by --tlsverify. Certs are generated automatically if not available")
	flag.BoolVar(&tlsverify, "tlsverify", false, "Use TLS and verify the remote. Certs are generated automatically if not available")
	flag.BoolVar(&local, "local", false, "Do not bind API to external interfaces")
	flag.StringVar(&storage, "storage", "overlay2", "Storage driver to use")
	flag.StringVar(&insecureRegistry, "insecure-registry", "", "Enable insecure registry communication")
	flag.StringVar(&vicIP, "vic-ip", "", "Set IP for automatic certificate creation")
}	

func main() {
	flag.Parse()

	if os.Getenv("DEBUG") != "" {
		log.Level = logrus.DebugLevel
		dockerArgs = append(dockerArgs, "--log-level", "debug")
	}

	if !tls && !tlsverify {
		log.Debug("Setting Port to 2375")
		port = 2375
	} else {
		log.Debug("Setting Port to 2376")
		port = 2376

		if !tlsverify {
			log.Debug("TLS option set, verifying if certs are available")

			// Generate Self signed
			files := []string{
				"/certs/docker.key",
				"/certs/docker.crt",
			}

			if err := certsExist(files); err != nil {
				log.Debug("Certs not available, generating...")
				var ip net.IP
				ip, err = check_vic_ip(vicIP)
				if err != nil {
					log.Fatal(err.Error())
				}
				if err := generateSelfSignedCerts(ip); err != nil {
					log.Fatal(err.Error())
				}
			}
			dockerArgs = append(dockerArgs, "--tls", "--tlscert=/certs/docker.crt", "--tlskey=/certs/docker.key")
		} else {
			log.Debug("TLSVERIFY option set, verifying if certs are available")

			// Generate CA Certs
			files := []string{
				"/certs/docker.key",
				"/certs/docker.crt",
				"/certs/ca.crt",
				"/certs/ca-key.pem",
				"/certs/docker-client.key",
				"/certs/docker-client.crt",
			}

			if err := certsExist(files); err != nil {
				log.Debug("Certs not available, generating...")
				var ip net.IP
				ip, err = check_vic_ip(vicIP)
				if err != nil {
					log.Fatal(err.Error())
				}
				if err := generateCACerts(ip); err != nil {
					log.Fatal(err.Error())
				}
			}

			dockerArgs = append(dockerArgs, "--tlsverify", "--tlscacert=/certs/ca.crt", "--tlscert=/certs/docker.crt", "--tlskey=/certs/docker.key")
		}
	}

	// If local is not set, let docker listen on all ips
	if !local {
		log.Debug("Let docker listen on all ips")
		dockerArgs = append(dockerArgs, "-H", fmt.Sprintf("tcp://0.0.0.0:%d", port))
	}
	dockerArgs = append(dockerArgs, "-H", "unix:///var/run/docker.sock")

	// Append insecure registry configuration if present
	if insecureRegistry != "" {
		log.Debug("Setting insecure registry variable")
		dockerArgs = append(dockerArgs, fmt.Sprintf("--insecure-registry=%s", insecureRegistry))
	}

	// Append storage driver configuration
	dockerArgs = append(dockerArgs, "-s", storage)

	log.Debugf("Creating exec command for %s %v", DOCKER, dockerArgs)
	// #nosec: Subprocess launching with variable.
	cmd := exec.Command(DOCKER, dockerArgs...)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Install a signal handler
	log.Debug("Installing signal handler")
	sigc := make(chan os.Signal, 1)
	signal.Notify(sigc,
		syscall.SIGINT,
		syscall.SIGTERM,
		syscall.SIGQUIT)
	go func() {
		s := <-sigc
		// relay signal to the running docker
		log.Debugf("Sending signal %s to pid %d", s.String(), cmd.Process.Pid)
		cmd.Process.Signal(s)
	}()

	log.Debug("Starting process")
	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}

	os.Exit(0)
}
