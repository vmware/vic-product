// Copyright 2018 VMware, Inc. All Rights Reserved.
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

package routes

import (
	"context"
	"crypto/tls"
	"net/http"
	"net/url"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic/pkg/trace"
)

const (
	targetKey = "target"
)

// ThumbprintHandler returns the thumbprint of the ip/fqdn given by the get parameter targetKey
func ThumbprintHandler(resp http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case http.MethodPost:
		op := trace.NewOperation(context.Background(), "ThumbprintHandler")
		target := req.FormValue(targetKey)
		if target == "" {
			op.Infof("Target not supplied")
			http.Error(resp, "Please supply a target", http.StatusUnprocessableEntity)
			return
		}

		// see https://github.com/vmware/govmomi/blob/master/govc/flags/host_connect.go#L70-L85
		var cert object.HostCertificateInfo
		if err := cert.FromURL(&url.URL{Host: target}, &tls.Config{}); err != nil {
			op.Errorf("Error getting thumbprint for %s: %s", target, err.Error())
			http.Error(resp, "Error getting thumbprint", http.StatusInternalServerError)
			return
		}

		op.Infof("Thumbprint found")
		http.Error(resp, cert.ThumbprintSHA1, http.StatusOK)
	default:
		http.Error(resp, "only accepts POST", http.StatusMethodNotAllowed)
	}
	return
}
