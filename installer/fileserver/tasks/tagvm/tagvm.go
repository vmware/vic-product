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

package tagvm

import (
	"net/url"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic/lib/guest"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/session"
	"github.com/vmware/vic/pkg/vsphere/tags"
)

const (
	VicProductCategory    = "VsphereIntegratedContainers"
	VicProductDescription = "VIC product"
	VicProductType        = "VirtualMachine"
	ProductVMTag          = "ProductVM"
	ProductVMDescription  = "Product VM"
)

func setupClient(op trace.Operation, sess *session.Session) (*tags.RestClient, error) {
	endpoint, err := url.Parse(sess.Service)
	client := tags.NewClient(endpoint, sess.Insecure, sess.Thumbprint)
	err = client.Login(op)
	if err != nil {
		op.Errorf("failed to connect rest API for %s", errors.ErrorStack(err))
		return client, errors.Errorf("Rest is not accessible")
	}

	return client, nil
}

func createProductVMtag(op trace.Operation, client *tags.RestClient) (string, error) {
	// create category first, then create tag
	categoryID, err := client.CreateCategoryIfNotExist(op, VicProductCategory, VicProductDescription, VicProductType, false)
	if err != nil {
		return "", errors.Errorf("failed to create vic product category: %s", errors.ErrorStack(err))
	}

	tagID, err := client.CreateTagIfNotExist(op, ProductVMTag, ProductVMDescription, *categoryID)
	if err != nil {
		return "", errors.Errorf("failed to create product vm tag: %s", errors.ErrorStack(err))
	}

	return *tagID, nil
}

func attachTag(op trace.Operation, client *tags.RestClient, sess *session.Session, tagID string, vm *object.VirtualMachine) error {
	if tagID == "" || sess == nil {
		return errors.Errorf("failed to attach product vm tag")
	}

	err := client.AttachTagToObject(op, tagID, vm.Reference().Value, vm.Reference().Type)
	if err != nil {
		return errors.Errorf("failed to apply the tag on product vm : %s", errors.ErrorStack(err))
	}

	op.Debugf("successfully attached the product tag")
	return nil
}

// Run takes in a url and session and tag the ova vm.
func Run(op trace.Operation, sess *session.Session) error {
	client, err := setupClient(op, sess)
	if err != nil {
		return err
	}

	tagID, err := createProductVMtag(op, client)
	if err != nil {
		return err
	}

	vm, err := guest.GetSelf(op, sess)
	if err != nil {
		return errors.Errorf("failed to get product vm : %s", errors.ErrorStack(err))
	}

	err = attachTag(op, client, sess, tagID, vm)
	if err != nil {
		return err
	}

	return nil
}
