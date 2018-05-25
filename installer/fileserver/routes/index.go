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

package routes

import (
	"fmt"
	"net/http"
	"os"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/fileserver/tasks"
	"github.com/vmware/vic/pkg/trace"
)

// IndexHTMLOptions contains fields for html templating in index.html
type IndexHTMLOptions struct {
	InitErrorFeedback   string
	InitSuccessFeedback string
	NeedLogin           bool
	AdmiralAddr         string
	FileserverAddr      string
	ValidationError     string
}

// IndexHTMLRenderer must be populated before the IndexHandler can render correctly
type IndexHTMLRenderer struct {
	ServerHostname string
	ServerAddress  string
	AdmiralPort    string
	VicTarName     string
}

// IndexHandler is an http.Handler for rendering the fileserver Getting Started Page
func (i *IndexHTMLRenderer) IndexHandler(resp http.ResponseWriter, req *http.Request) {
	defer trace.End(trace.Begin(""))

	html := &IndexHTMLOptions{
		NeedLogin:           needInitializationServices(req),
		InitErrorFeedback:   "",
		InitSuccessFeedback: "",
		ValidationError:     "",
	}

	if req.Method == http.MethodPost {
		// verify login
		PSCConfig := tasks.NewPSCRegistrationConfig()
		PSCConfig.Admin.Target = req.FormValue("target")
		PSCConfig.Admin.User = req.FormValue("user")
		PSCConfig.Admin.Password = req.FormValue("password")
		PSCConfig.PscInstance = req.FormValue("psc")
		PSCConfig.PscDomain = req.FormValue("pscDomain")

		// VerifyLogin populates Admin.Validator
		cancel, err := PSCConfig.Admin.VerifyLogin()
		defer cancel()

		if err != nil {
			log.Infof("Validation failed: %s", err.Error())
			html.ValidationError = err.Error()
		} else {
			log.Infof("Validation succeeded")
			html.NeedLogin = false

			if err := PSCConfig.RegisterAppliance(); err != nil {
				html.InitErrorFeedback = err.Error()
			} else {
				html.InitSuccessFeedback = "Installation successful. Refer to the Post-install and Deployment tasks below."
			}
		}
	}

	html.AdmiralAddr = fmt.Sprintf("https://%s:%s", i.ServerHostname, i.AdmiralPort)
	html.FileserverAddr = fmt.Sprintf("https://%s%s/files/%s", i.ServerHostname, i.ServerAddress, i.VicTarName)

	RenderTemplate(resp, "html/index.html", html)
}

func needInitializationServices(req *http.Request) bool {
	_, err := os.Stat(tasks.InitServicesTimestamp)
	return os.IsNotExist(err) || req.URL.Query().Get("login") == "true"
}
