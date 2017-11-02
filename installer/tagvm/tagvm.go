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

package tagvm

import (
	"context"
	"net/url"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic/lib/guest"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/vsphere/session"
	"github.com/vmware/vic/pkg/vsphere/tags"
)

const (
	VicProductCategory      = "VsphereIntegratedContainers"
	VicProductDescription   = "VIC product"
	VicProductType          = "VirtualMachine"
	ProductVMTag            = "ProductVM"
	ProductVMDescription    = "Product VM"
	ProductManagedObjectKey = "vic-ova-identifier"
)

func setupClient(ctx context.Context, sess *session.Session) (*tags.RestClient, error) {
	endpoint, err := url.Parse(sess.Service)
	client := tags.NewClient(endpoint, sess.Insecure, sess.Thumbprint)
	err = client.Login(ctx)
	if err != nil {
		log.Debugf("failed to connect rest API for %s", errors.ErrorStack(err))
		return client, errors.Errorf("Rest is not accessible")
	}

	return client, nil
}

func createProductVMtag(ctx context.Context, client *tags.RestClient) (string, error) {
	// create category first, then create tag
	categoryID, err := client.CreateCategoryIfNotExist(ctx, VicProductCategory, VicProductDescription, VicProductType, false)
	if err != nil {
		return "", errors.Errorf("failed to create vic product category: %s", errors.ErrorStack(err))
	}

	tagID, err := client.CreateTagIfNotExist(ctx, ProductVMTag, ProductVMDescription, *categoryID)
	if err != nil {
		return "", errors.Errorf("failed to create product vm tag: %s", errors.ErrorStack(err))
	}

	return *tagID, nil
}

func attachTag(ctx context.Context, client *tags.RestClient, sess *session.Session, tagID string, vm *object.VirtualMachine) error {
	if tagID == "" || sess == nil {
		return errors.Errorf("failed to attach product vm tag")
	}

	err := client.AttachTagToObject(ctx, tagID, vm.Reference().Value, vm.Reference().Type)
	if err != nil {
		return errors.Errorf("failed to apply the tag on product vm : %s", errors.ErrorStack(err))
	}

	log.Debugf("successfully attached the product tag")
	return nil
}

func addManagedObjectValue(ctx context.Context, sess *session.Session, vm *object.VirtualMachine) error {
	fieldManager, err := object.GetCustomFieldsManager(sess.Vim25())
	if err != nil {
		return err
	}

	def, err := fieldManager.Add(ctx, ProductManagedObjectKey, "", nil, nil)
	if err != nil {
		// TODO: Ignore Duplicate Name errors: http://pubs.vmware.com/vsphere-6-5/index.jsp?topic=%2Fcom.vmware.vspsdk.apiref.doc%2Fvim.CustomFieldsManager.html
		return err
	}

	// TODO: add ova version here
	err = fieldManager.Set(ctx, vm.Reference(), def.Key, "some-version-number")
	if err != nil {
		return err
	}

	return nil
}

// Run takes in a url and session and tag the ova vm.
func Run(ctx context.Context, sess *session.Session) error {
	client, err := setupClient(ctx, sess)
	if err != nil {
		return err
	}

	tagID, err := createProductVMtag(ctx, client)
	if err != nil {
		return err
	}

	vm, err := guest.GetSelf(ctx, sess)
	if err != nil {
		return errors.Errorf("failed to get product vm : %s", errors.ErrorStack(err))
	}

	err = attachTag(ctx, client, sess, tagID, vm)
	if err != nil {
		return err
	}

	err = addManagedObjectValue(ctx, sess, vm)
	if err != nil {
		return err
	}

	return nil
}
