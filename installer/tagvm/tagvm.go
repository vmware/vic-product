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

	log "github.com/sirupsen/logrus"

	"github.com/vmware/vic-product/installer/rest"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/vsphere/guest"
	"github.com/vmware/vic/pkg/vsphere/session"
)

const (
	ovaCategory = "VsphereIntegratedContainers"
	ovaTag      = "ProductVM"
)

func setupClient(target *string) (*rest.RestClient, bool) {
	endpoint, err := url.Parse(*target)
	client := rest.NewClient(endpoint, true)
	err = client.Login()
	if err != nil {
		log.Debugf("failed to connect rest API for %s", errors.ErrorStack(err))
		return client, false
	} else {
		return client, true
	}
}

func createOVAtag(client *rest.RestClient) (*string, *string) {
	// create category first, then create tag
	categoryId, err := client.CreateCategoryIfNotExist(ovaCategory, "OVA", "VirtualMachine", false)
	if err != nil {
		log.Debugf("failed to create ova category: %s", errors.ErrorStack(err))
		return nil, nil
	}

	tagId, err := client.CreateTagIfNotExist(ovaTag, "OVA tag", *categoryId)
	if err != nil {
		log.Debugf("failed to create ova vm tag: %s", errors.ErrorStack(err))
		return nil, nil
	}

	return categoryId, tagId
}

func attachTag(client *rest.RestClient, sess *session.Session, categoryId *string, tagId *string) {
	if categoryId == nil || tagId == nil || sess == nil {
		log.Debug("failed to attach ova vm tag")
		return
	}

	ctx := context.Background()
	vm, err := guest.GetSelf(ctx, sess)
	if err != nil {
		log.Debugf("failed to get ova vm : %s", errors.ErrorStack(err))
		return
	}

	err = client.AttachTagToObject(*tagId, vm.Reference().Value, vm.Reference().Type)
	if err != nil {
		log.Debugf("failed to apply the tag on ova vm : %s", errors.ErrorStack(err))
	}
	log.Debugf("successfully attached the ova tag")
}

// given a url and session, run tag code
func Run(target string, sess *session.Session) {

	client, restAccessible := setupClient(&target)
	if restAccessible {
		categoryId, tagId := createOVAtag(client)
		attachTag(client, sess, categoryId, tagId)
	} else {
		log.Debugf("rest API is not accessible, cannot tag ova vm")
	}
}
