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
	"os"
	"os/exec"
	"os/signal"
	"syscall"

	"github.com/Sirupsen/logrus"
)

const (
	DOCKER     string = "/usr/bin/docker"
	CONTAINERD string = "/usr/bin/docker-containerd"
)

var (
	tls              bool
	tlsverify        bool
	local            bool
	storage          string
	insecureRegistry string
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
}

func main() {
	flag.Parse()

	// Append default args for 1.12
	dockerArgs = append(dockerArgs, "daemon", "-p", "/run/docker.pid", "--containerd", "/run/containerd.sock")

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
				ip, err := getFirstIP("eth0")
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
				ip, err := getFirstIP("eth0")
				if err != nil {
					log.Fatal(err.Error())
				}
				if err := generateCACerts(ip); err != nil {
					log.Fatal(err.Error())
				}
			}

			dockerArgs = append(dockerArgs, "--tls", "--tlscacert=/certs/ca.crt", "--tlscert=/certs/docker.crt", "--tlskey=/certs/docker.key")
		}
	}

	// If local is not set, let docker listen on all ips
	if !local {
		log.Debug("Let docker listen on all ips")
		dockerArgs = append(dockerArgs, "-H", fmt.Sprintf("tcp://0.0.0.0:%d", port))
	}

	// Append insecure registry configuration if present
	if insecureRegistry != "" {
		log.Debug("Setting insecure registry variable")
		dockerArgs = append(dockerArgs, fmt.Sprintf("--insecure-registry=%s", insecureRegistry))
	}

	// Append storage driver configuration
	dockerArgs = append(dockerArgs, "-s", storage)

	containerdArgs := []string{"--listen", "unix:///run/containerd.sock", "--runtime", "/usr/bin/docker-runc", "--shim", "/usr/bin/docker-containerd-shim"}
	log.Debugf("Creating exec command for %s %v", CONTAINERD, containerdArgs)
	containerdCmd := exec.Command(CONTAINERD, containerdArgs...)

	containerdCmd.Stdout = os.Stdout
	containerdCmd.Stderr = os.Stderr

	log.Debugf("Creating exec command for %s %v", DOCKER, dockerArgs)
	dockerCmd := exec.Command(DOCKER, dockerArgs...)

	dockerCmd.Stdout = os.Stdout
	dockerCmd.Stderr = os.Stderr

	// Install a signal handler
	log.Debug("Installing signal handler")
	sigc := make(chan os.Signal, 1)
	signal.Notify(sigc,
		syscall.SIGKILL,
		syscall.SIGINT,
		syscall.SIGTERM,
		syscall.SIGQUIT)
	go func() {
		s := <-sigc
		// relay signal to the running docker
		log.Debugf("Sending signal %s to docker with pid %d", s.String(), dockerCmd.Process.Pid)
		dockerCmd.Process.Signal(s)
		log.Debugf("Sending signal %s to containerd with pid %d", s.String(), containerdCmd.Process.Pid)
		containerdCmd.Process.Signal(s)
	}()

	log.Debug("Starting processes")
	if err := containerdCmd.Start(); err != nil {
		log.Fatal(err)
	}
	if err := dockerCmd.Start(); err != nil {
		log.Fatal(err)
	}

	dockerCmd.Wait()
	containerdCmd.Wait()

	os.Exit(0)
}
