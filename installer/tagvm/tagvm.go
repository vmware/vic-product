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

	"github.com/vmware/vic-product/installer/tags"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/vsphere/guest"
	"github.com/vmware/vic/pkg/vsphere/session"
)

const (
	VicProductCategory    = "VsphereIntegratedContainers"
	VicProductDescription = "VIC product"
	VicProductType        = "VirtualMachine"
	ProductVMTag          = "ProductVM"
	ProductVMDescription  = "Product VM"
)

func setupClient(sess *session.Session) (*tags.RestClient, error) {
	endpoint, err := url.Parse(sess.Service)
	client := tags.NewClient(endpoint, sess.Insecure)
	err = client.Login()
	if err != nil {
		log.Debugf("failed to connect rest API for %s", errors.ErrorStack(err))
		return client, errors.Errorf("Rest is not accessible")
	}

	return client, nil
}

func createProductVMtag(client *tags.RestClient) (string, error) {
	// create category first, then create tag
	categoryId, err := client.CreateCategoryIfNotExist(VicProductCategory, VicProductDescription, VicProductType, false)
	if err != nil {
		return "", errors.Errorf("failed to create vic product category: %s", errors.ErrorStack(err))
	}

	tagId, err := client.CreateTagIfNotExist(ProductVMTag, ProductVMDescription, *categoryId)
	if err != nil {
		return "", errors.Errorf("failed to create product vm tag: %s", errors.ErrorStack(err))
	}

	return *tagId, nil
}

func attachTag(ctx context.Context, client *tags.RestClient, sess *session.Session, tagId string) error {
	if tagId == "" || sess == nil {
		return errors.Errorf("failed to attach product vm tag")
	}

	vm, err := guest.GetSelf(ctx, sess)
	if err != nil {
		return errors.Errorf("failed to get product vm : %s", errors.ErrorStack(err))
	}

	err = client.AttachTagToObject(tagId, vm.Reference().Value, vm.Reference().Type)
	if err != nil {
		return errors.Errorf("failed to apply the tag on product vm : %s", errors.ErrorStack(err))
	}

	log.Debugf("successfully attached the product tag")
	return nil
}

// Run takes in a url and session and tag the ova vm.
func Run(ctx context.Context, sess *session.Session) error {
	client, err := setupClient(sess)
	if err != nil {
		return err
	}

	tagId, err := createProductVMtag(client)
	if err != nil {
		return err
	}

	err = attachTag(ctx, client, sess, tagId)
	if err != nil {
		return err
	}

	return nil
}
