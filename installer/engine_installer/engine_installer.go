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
	"encoding/json"
	"fmt"
	"html/template"
	"io/ioutil"
	"net/http"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic/pkg/trace"
)

// #nosec: Potential hardcoded credentials
const pscToken = "/etc/vmware/psc/admiral/tokens.properties"

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
	InvalidLogin    bool
	ConnectionError bool
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

func (ei *EngineInstaller) populateConfigOptions() (*EngineInstallerConfigOptions, error) {
	defer trace.End(trace.Begin(""))

	vc := ei.loginInfo.Validator.IsVC()
	log.Infof("Is VC: %t\n", vc)

	dcs, err := ei.loginInfo.Validator.ListDatacenters()
	if err != nil {
		log.Infoln(err)
		return nil, err
	}
	for _, d := range dcs {
		log.Infof("DC: %s\n", d)
	}

	comp, err := ei.loginInfo.Validator.ListComputeResource()
	if err != nil {
		log.Infoln(err)
		return nil, err
	}
	for _, c := range comp {
		log.Infof("compute: %s\n", c)
	}

	rp, err := ei.loginInfo.Validator.ListResourcePool("*")
	if err != nil {
		log.Infoln(err)
		return nil, err
	}
	for _, p := range rp {
		log.Infof("rp: %s\n", p)
	}

	nets, err := ei.loginInfo.Validator.ListNetworks(!vc) // set to false for vC
	if err != nil {
		log.Infoln(err)
		return nil, err
	}
	for _, n := range nets {
		log.Infof("net: %s\n", n)
	}

	dss, err := ei.loginInfo.Validator.ListDatastores()
	if err != nil {
		log.Infoln(err)
		return nil, err
	}
	for _, d := range dss {
		log.Infof("ds: %s\n", d)
	}

	return &EngineInstallerConfigOptions{
		Networks:      nets,
		Datastores:    dss,
		ResourcePools: rp,
	}, nil
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
	if ip, err := ip.FirstIPv4(ip.Eth0Interface); err == nil {
		createCommand = append(createCommand, []string{"--insecure-registry", fmt.Sprintf("%s:443", ip.String())}...)
	}
	createCommand = append(createCommand, []string{"--thumbprint", ei.Thumbprint}...)

	ei.CreateCommand = createCommand
}

// ClusterPayload is the main object used in creating a
// cluster in Admiral. See the following url for the cluster json spec:
// https://confluence.eng.vmware.com/pages/viewpage.action?pageId=230746111
type ClusterPayload struct {
	HostState         *State `json:"hostState,omitempty"`
	AcceptCertificate bool   `json:"acceptCertificate,omitempty"`
}

// State contains the address of the vch. We add the TentantLinks so Admiral
// can create a relationship between the cluster and the default project.
type State struct {
	Address          string   `json:"address,omitempty"`
	TenantLinks      []string `json:"tenantLinks,omitempty"`
	CustomProperties *Props   `json:"customProperties,omitempty"`
}

// Props are used by admiral to determine the address endpoint type and
// to give the VCH cluster a custom name.
type Props struct {
	ContainerHostType string `json:"__containerHostType,omitempty"`
	AdapterDockerType string `json:"__adapterDockerType,omitempty"`
	ClusterName       string `json:"__clusterName,omitempty"`
}

// NewDefaultVCHPayload creates a new ClusterPayload that will add the
// demo VCH created from this app as a cluster in the default Admiral project.
func NewDefaultVCHPayload(address string) ClusterPayload {
	return ClusterPayload{
		HostState: &State{
			Address:     fmt.Sprintf("https://%s", address),
			TenantLinks: []string{"/projects/default-project"},
			CustomProperties: &Props{
				ContainerHostType: "VCH",
				AdapterDockerType: "API",
				ClusterName:       "Default-VCH",
			},
		},
		AcceptCertificate: true,
	}
}

func setupDefaultAdmiral(vchIP string) error {
	defer trace.End(trace.Begin(""))

	admiral := "https://localhost:8282"
	// #nosec: TLS InsecureSkipVerify set true.
	client := &http.Client{Transport: &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}}

	// add host to admiral
	addHostPayload, err := json.Marshal(NewDefaultVCHPayload(vchIP))
	if err != nil {
		log.Infof("cannot marshall add host payload: %s", err.Error())
		return fmt.Errorf("error adding host to Admiral")
	}

	// #nosec: Errors unhandled.
	addHostReq, _ := http.NewRequest(http.MethodPost, fmt.Sprintf("%s/resources/clusters", admiral), bytes.NewBuffer(addHostPayload))
	hdr := http.Header{}

	// #nosec: Errors unhandled.
	token, _ := ioutil.ReadFile(pscToken)
	hdr.Add("x-xenon-auth-token", string(token))
	addHostReq.Header = hdr

	addHostResp, err := client.Do(addHostReq)
	if err != nil || addHostResp.StatusCode != http.StatusOK {
		log.Infof("error: %#v\nresponse: %#v\n", err, addHostResp)
		return fmt.Errorf("error adding host to Admiral")
	}

	log.Infoln("Host added to admiral.")
	return nil
}
