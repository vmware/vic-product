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
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	"github.com/vmware/vic-product/installer/tagvm"
)

type registerPayload struct {
	Target      string `json:"target"`
	User        string `json:"user"`
	Password    string `json:"password"`
	ExternalPSC string `json:"externalpsc"`
	PSCDomain   string `json:"pscdomain"`
}

func registerHandler(resp http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case http.MethodPost:

		if req.Body == nil {
			http.Error(resp, "Please send a request body", http.StatusBadRequest)
			return
		}

		var r registerPayload
		err := json.NewDecoder(req.Body).Decode(&r)
		if err != nil {
			http.Error(resp, err.Error(), http.StatusBadRequest)
			return
		}

		defer req.Body.Close()
		admin.Target = r.Target
		admin.User = r.User
		admin.Password = r.Password
		cancel, err := admin.VerifyLogin()
		defer cancel()
		if err != nil {
			http.Error(resp, err.Error(), http.StatusUnauthorized)
			return
		}

		ctx := context.TODO()
		if err := tagvm.Run(ctx, admin.Validator.Session); err != nil {
			http.Error(resp, err.Error(), http.StatusServiceUnavailable)
			return
		}

		pscInstance = r.ExternalPSC
		pscDomain = r.PSCDomain
		if err := registerWithPSC(ctx); err != nil {
			http.Error(resp, err.Error(), http.StatusServiceUnavailable)
			return
		}

		if err := ioutil.WriteFile(initServicesTimestamp, []byte(time.Now().String()), 0644); err != nil {
			errMsg := fmt.Sprintf("Failed to write to timestamp file: %s", err.Error())
			http.Error(resp, errMsg, http.StatusServiceUnavailable)
			return
		}

		http.Error(resp, "operation complete", http.StatusOK)
	default:
		http.Error(resp, "only accepts POST", http.StatusMethodNotAllowed)
	}
	return
}
