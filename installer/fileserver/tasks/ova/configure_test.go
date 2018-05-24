// Copyright 2016 VMware, Inc. All Rights Reserved.
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

package ova

import (
	"context"
	"crypto/tls"
	"fmt"
	"net/url"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/session"
)

func TestGetOvaVMByTagBadURL(t *testing.T) {
	bogusURL := "foo/bar.url://what-is-this"
	op := trace.NewOperation(context.Background(), "TestGetOvaVMByTagBadURL")
	vm, err := getOvaVMByTag(op, nil, bogusURL)
	assert.Nil(t, vm)
	assert.Error(t, err)
}

func TestGetOvaVMByTag(t *testing.T) {
	username := os.Getenv("TEST_VC_USERNAME")
	password := os.Getenv("TEST_VC_PASSWORD")
	vcURL := os.Getenv("TEST_VC_URL")
	ovaURL := os.Getenv("TEST_OVA_URL")
	op := trace.NewOperation(context.Background(), "TestGetOvaVMByTag")

	if vcURL == "" || ovaURL == "" {
		op.Infof("Skipping TestGetOvaVMByTag")
		t.Skipf("This test should only run against a VC with a deployed OVA")
	}

	vc, err := url.Parse(vcURL)
	if err != nil {
		fmt.Printf("Failed to parse VC url: %s", err)
		t.FailNow()
	}

	vc.User = url.UserPassword(username, password)

	var cert object.HostCertificateInfo
	if err = cert.FromURL(vc, new(tls.Config)); err != nil {
		op.Error(err.Error())
		t.FailNow()
	}

	if cert.Err != nil {
		op.Errorf("Failed to verify certificate for target=%s (thumbprint=%s)", vc.Host, cert.ThumbprintSHA1)
		op.Error(cert.Err.Error())
	}

	tp := cert.ThumbprintSHA1
	op.Infof("Accepting host %q thumbprint %s", vc.Host, tp)

	sessionConfig := &session.Config{
		Thumbprint:     tp,
		Service:        vc.String(),
		DatacenterPath: "/ha-datacenter",
		DatastorePath:  "datastore1",
		User:           vc.User,
		Insecure:       true,
	}

	s := session.NewSession(sessionConfig)
	sess, err := s.Connect(op)
	if err != nil {
		op.Errorf("Error connecting: %s", err.Error())
	}
	defer sess.Logout(op)

	sess, err = sess.Populate(op)
	if err != nil {
		op.Errorf("Error populating: %s", err.Error())
	}

	vm, err := getOvaVMByTag(op, sess, ovaURL)
	if err != nil {
		op.Errorf("Error getting OVA by tag: %s", err.Error())
	}
	if vm == nil {
		op.Errorf("No VM found")
		t.FailNow()
	}

	op.Infof("%s", vm.String())
}
