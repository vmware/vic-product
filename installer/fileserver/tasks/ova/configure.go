// Copyright 2016-2018 VMware, Inc. All Rights Reserved.
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
	"net"
	"net/url"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/govmomi/vim25/types"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/session"
	"github.com/vmware/vic/pkg/vsphere/tasks"
	"github.com/vmware/vic/pkg/vsphere/vm"
)

const (
	// ManagedByKey defines the extension key to use in the ManagedByInfo of the OVA
	ManagedByKey = "com.vmware.vic"
	// ManagedByType defines the type to use in the ManagedByInfo of the OVA
	ManagedByType = "VicApplianceVM"
)

// ConfigureManagedByInfo sets the ManagedBy field for the VM specified by ovaURL
func ConfigureManagedByInfo(op trace.Operation, sess *session.Session, ovaURL string) error {
	op.Infof("Attempting to create the appliance vm ref")
	v, err := getOvaVM(op, sess, ovaURL)
	if err != nil {
		return err
	}

	op.Infof("Attempting to configure ManagedByInfo")
	err = configureManagedByInfo(op, sess, v)
	if err != nil {
		return err
	}

	op.Infof("Successfully configured ManagedByInfo")
	return nil
}

func configureManagedByInfo(op trace.Operation, sess *session.Session, v *vm.VirtualMachine) error {
	spec := types.VirtualMachineConfigSpec{
		ManagedBy: &types.ManagedByInfo{
			ExtensionKey: ManagedByKey,
			Type:         ManagedByType,
		},
	}

	info, err := v.WaitForResult(op, func(ctx context.Context) (tasks.Task, error) {
		return v.Reconfigure(ctx, spec)
	})

	if err != nil {
		op.Errorf("Error while setting ManagedByInfo: %s", err)
		return err
	}

	if info.State != types.TaskInfoStateSuccess {
		op.Errorf("Setting ManagedByInfo reported: %s", info.Error.LocalizedMessage)
		return err
	}

	return nil
}

func getOvaVM(op trace.Operation, sess *session.Session, u string) (*vm.VirtualMachine, error) {
	ovaURL, err := url.Parse(u)
	if err != nil {
		return nil, err
	}

	host := ovaURL.Hostname()

	op.Debugf("Looking up host %s", host)
	ips, err := net.LookupIP(host)
	if err != nil {
		return nil, errors.Errorf("IP lookup failed: %s", err)
	}

	op.Debugf("found %d IP(s) from hostname lookup on %s:", len(ips), host)
	var ip string
	for _, i := range ips {
		op.Debugf(i.String())
		if i.To4() != nil {
			ip = i.String()
		}
	}

	if ip == "" {
		return nil, errors.Errorf("IPV6 support not yet implemented")
	}

	// Create a vm reference using the appliance ip
	ref, err := object.NewSearchIndex(sess.Vim25()).FindByIp(op, nil, ip, true)
	if err != nil {
		return nil, errors.Errorf("failed to search for vms: %s", err.Error())
	}

	v, ok := ref.(*object.VirtualMachine)
	if !ok {
		return nil, errors.Errorf("failed to find vm with ip: %s", ip)
	}

	op.Debugf("Checking IP for %s", v.Reference().Value)
	vmIP, err := v.WaitForIP(op)
	if err != nil {
		return nil, errors.Errorf("Cannot get appliance vm ip: %s", err.Error())
	}

	// verify the tagged vm has the IP we expect
	if vmIP != ip {
		return nil, errors.Errorf("vm ip %s does not match guest.ip %s", vmIP, ip)
	}

	op.Debugf("Found OVA with matching IP: %s", ip)
	return &vm.VirtualMachine{
		VirtualMachine: v,
		Session:        sess,
	}, nil
}
