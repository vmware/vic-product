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

package routes

import (
	"encoding/json"
	"fmt"
	"net/http"

	log "github.com/Sirupsen/logrus"
	"github.com/vmware/vic-product/installer/fileserver/tasks"
)

type registerPayload struct {
	Target      string `json:"target"`
	User        string `json:"user"`
	Password    string `json:"password"`
	ExternalPSC string `json:"externalpsc"`
	PSCDomain   string `json:"pscdomain"`
}

// RegisterHandler unwraps a json body as a PSCRegistrationConfig and preforms
// the RegisterWithPSC task
func RegisterHandler(resp http.ResponseWriter, req *http.Request) {
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

		PSCConfig := tasks.NewPSCRegistrationConfig()
		PSCConfig.Admin.Target = r.Target
		PSCConfig.Admin.User = r.User
		PSCConfig.Admin.Password = r.Password
		cancel, err := PSCConfig.Admin.VerifyLogin()
		defer cancel()
		if err != nil {
			log.Infof("Validation failed")
			http.Error(resp, err.Error(), http.StatusUnauthorized)
			return
		}

		log.Infof("Validation succeeded")
		if err := tasks.RegisterAppliance(PSCConfig); err != nil {
			errMsg := fmt.Sprintf("Failed to write to register appliance: %s", err.Error())
			http.Error(resp, errMsg, http.StatusInternalServerError)
			return
		}

		http.Error(resp, "operation complete", http.StatusOK)
	default:
		http.Error(resp, "only accepts POST", http.StatusMethodNotAllowed)
	}
	return
}
