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
	"bytes"
	"crypto/tls"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic/pkg/trace"
)

// EngineInstallerConfigOptions contains resource options for selection by user in exec.html
type EngineInstallerConfigOptions struct {
	Networks      []string
	Datastores    []string
	ResourcePools []string
}

// EngineInstaller contains all options to be used in the vic-machine create command
type EngineInstaller struct {
	loginInfo       lib.LoginInfo
	BridgeNetwork   string `json:"bridge-net"`
	PublicNetwork   string `json:"public-net"`
	ImageStore      string `json:"img-store"`
	ComputeResource string `json:"compute"`
	Name            string `json:"name"`
	Thumbprint      string `json:"thumbprint"`
	CreateCommand   []string
}

// AuthHTML holds the invalid login variable
type AuthHTML struct {
	InvalidLogin bool
}

// ExecHTMLOptions contains fields for html templating in exec.html
type ExecHTMLOptions struct {
	BridgeNetwork   template.HTML
	PublicNetwork   template.HTML
	ImageStore      template.HTML
	ComputeResource template.HTML
	Target          string
	User            string
	Password        string
	Name            string
	Thumbprint      string
	CreateCommand   string
}

func NewEngineInstaller() *EngineInstaller {
	return &EngineInstaller{Name: "default-vch"}
}

func (ei *EngineInstaller) populateConfigOptions() *EngineInstallerConfigOptions {
	defer trace.End(trace.Begin(""))

	vc := ei.loginInfo.Validator.IsVC()
	log.Infof("Is VC: %t\n", vc)

	dcs, err := ei.loginInfo.Validator.ListDatacenters()
	if err != nil {
		log.Infoln(err)
		return nil
	}
	for _, d := range dcs {
		log.Infof("DC: %s\n", d)
	}

	comp, err := ei.loginInfo.Validator.ListComputeResource()
	if err != nil {
		log.Infoln(err)
		return nil
	}
	for _, c := range comp {
		log.Infof("compute: %s\n", c)
	}

	rp, err := ei.loginInfo.Validator.ListResourcePool("*")
	if err != nil {
		log.Infoln(err)
		return nil
	}
	for _, p := range rp {
		log.Infof("rp: %s\n", p)
	}

	nets, err := ei.loginInfo.Validator.ListNetworks(!vc) // set to false for vC
	if err != nil {
		log.Infoln(err)
		return nil
	}
	for _, n := range nets {
		log.Infof("net: %s\n", n)
	}

	dss, err := ei.loginInfo.Validator.ListDatastores()
	if err != nil {
		log.Infoln(err)
		return nil
	}
	for _, d := range dss {
		log.Infof("ds: %s\n", d)
	}

	return &EngineInstallerConfigOptions{
		Networks:      nets,
		Datastores:    dss,
		ResourcePools: rp,
	}
}

func (ei *EngineInstaller) buildCreateCommand(binaryPath string) {
	defer trace.End(trace.Begin(""))

	var createCommand []string

	createCommand = append(createCommand, binaryPath+"/vic/vic-machine-linux")
	createCommand = append(createCommand, "create")
	createCommand = append(createCommand, "--no-tlsverify")
	createCommand = append(createCommand, []string{"--target", ei.loginInfo.Target}...)
	createCommand = append(createCommand, []string{"--user", ei.loginInfo.User}...)
	createCommand = append(createCommand, []string{"--password", ei.loginInfo.Password}...)
	createCommand = append(createCommand, []string{"--name", ei.Name}...)
	createCommand = append(createCommand, []string{"--public-network", ei.PublicNetwork}...)
	createCommand = append(createCommand, []string{"--bridge-network", ei.BridgeNetwork}...)
	createCommand = append(createCommand, []string{"--compute-resource", ei.ComputeResource}...)
	createCommand = append(createCommand, []string{"--image-store", ei.ImageStore}...)
	createCommand = append(createCommand, []string{"--thumbprint", ei.Thumbprint}...)

	ei.CreateCommand = createCommand
}

func setupDefaultAdmiral(vchIP string) {
	defer trace.End(trace.Begin(""))

	admiral := "https://localhost:8282"
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	client := &http.Client{Transport: tr}

	// validate vch host
	sslTrustPayload := fmt.Sprintf("{\"hostState\":{\"id\":\"%s\",\"address\":\"https://%s\",\"customProperties\":{\"__adapterDockerType\":\"API\",\"__containerHostType\":\"VCH\"}}}", vchIP, vchIP)
	sslTrustReq, _ := http.NewRequest(http.MethodPut, fmt.Sprintf("%s/resources/hosts?validate=true", admiral), bytes.NewBuffer([]byte(sslTrustPayload)))
	sslTrustResp, err := client.Do(sslTrustReq)
	if err != nil || sslTrustResp.StatusCode != http.StatusOK {
		log.Infof("error: %v\nresponse: %v\n", err, sslTrustResp)
		log.Infoln("Cannot add vch to Admiral.")
		return
	}

	// trust vch host on admiral
	sslCert, err := ioutil.ReadAll(sslTrustResp.Body)
	if err != nil {
		log.Infoln(err)
		log.Infoln("Cannot add vch to Admiral.")
		return
	}
	if len(sslCert) > 0 {
		sslCertReq, _ := http.NewRequest(http.MethodPost, fmt.Sprintf("%s/config/trust-certs", admiral), bytes.NewBuffer([]byte(sslCert)))
		sslCertResp, err := client.Do(sslCertReq)
		if err != nil || sslCertResp.StatusCode != http.StatusOK {
			log.Infof("error: %v\nresponse: %v\n", err, sslCertResp)
			log.Infoln("Admiral cannot trust host certificate.")
			return
		}
	}

	// add host to admiral
	addHostReq, _ := http.NewRequest(http.MethodPut, fmt.Sprintf("%s/resources/hosts", admiral), bytes.NewBuffer([]byte(sslTrustPayload)))
	addHostResp, err := client.Do(addHostReq)
	if err != nil || addHostResp.StatusCode != http.StatusNoContent {
		log.Infof("error: %v\nresponse: %v\n", err, addHostResp)
		log.Infoln("Error adding host to Admiral.")
		return
	}

	log.Infoln("Host added to admiral.")
}
