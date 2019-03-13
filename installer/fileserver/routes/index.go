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

package routes

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"os/exec"

	"github.com/vmware/vic-product/installer/fileserver/tasks"
	"github.com/vmware/vic/pkg/trace"
)

const inValidVICPwd = "VIC appliance password is incorrect." // #nosec
const vicPwdMaxLength = 30

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
	op := trace.NewOperation(context.Background(), "IndexHandler")
	if rejectRestrictedRequest(op, resp, req) {
		return
	}
	html := &IndexHTMLOptions{
		NeedLogin:           needInitializationServices(req),
		InitErrorFeedback:   "",
		InitSuccessFeedback: "",
		ValidationError:     "",
	}

	if req.Method == http.MethodPost {
		if err := indexFormHandler(op, req, html); err != nil {
			op.Errorf("Install failed: %s", err.Error())
			html.InitErrorFeedback = fmt.Sprintf("Installation failed: %s", err.Error())
		} else if req.FormValue("needuiplugin") == "true" {
			html.InitSuccessFeedback = "Installation successful. Refer to the Post-install and Deployment tasks below. All vSphere Client users must log out and log back in again twice to see the vSphere Integrated Containers plug-in."
		} else {
			html.InitSuccessFeedback = "Installation successful. Refer to the Post-install and Deployment tasks below."
		}
	}

	html.AdmiralAddr = fmt.Sprintf("https://%s:%s", i.ServerHostname, i.AdmiralPort)
	html.FileserverAddr = fmt.Sprintf("https://%s%s/files/%s", i.ServerHostname, i.ServerAddress, i.VicTarName)

	RenderTemplate(op, resp, "html/index.html", html)
}

// indexFormHandler registers the appliance using post form values
func indexFormHandler(op trace.Operation, req *http.Request, html *IndexHTMLOptions) error {
	vicPasswd := req.FormValue("appliancePwd")
	if err := verifyVICApplianceLogin(op, vicPasswd); err != nil {
		html.ValidationError = inValidVICPwd
		return err
	}

	// verify vc login
	PSCConfig := tasks.NewPSCRegistrationConfig()
	PSCConfig.Admin.Target = req.FormValue("target")
	PSCConfig.Admin.User = req.FormValue("user")
	PSCConfig.Admin.Password = req.FormValue("password")
	PSCConfig.Admin.Thumbprint = req.FormValue("thumbprint")
	PSCConfig.PscInstance = req.FormValue("psc")
	PSCConfig.PscDomain = req.FormValue("pscDomain")

	// VerifyLogin populates Admin.Validator
	cancel, err := PSCConfig.Admin.VerifyLogin(op)
	defer cancel()
	if err != nil {
		op.Infof("Validation failed: %s", err.Error())
		html.ValidationError = err.Error()
		return err
	}
	defer PSCConfig.Admin.Session.Logout(op)

	op.Infof("Validation succeeded")
	html.NeedLogin = false

	if err := PSCConfig.RegisterAppliance(op); err != nil {
		return err
	}

	if req.FormValue("needuiplugin") == "true" {
		h5 := tasks.NewH5UIPlugin(PSCConfig.Admin)
		h5.Force = true
		if err := h5.Install(op); err != nil {
			return err
		}
	}

	return nil
}

func needInitializationServices(req *http.Request) bool {
	_, err := os.Stat(tasks.InitServicesTimestamp)
	return os.IsNotExist(err) || req.URL.Query().Get("login") == "true"
}

func rejectRestrictedRequest(op trace.Operation, resp http.ResponseWriter, req *http.Request) bool {
	paths := map[string]struct{}{
		"/":           {},
		"/index.html": {},
	}
	if _, ok := paths[req.URL.Path]; !ok {
		op.Errorf("Request path %s not found in %-v", req.URL.Path, paths)
		http.NotFound(resp, req)
		return true
	}
	return false
}

func verifyVICApplianceLogin(op trace.Operation, vicPasswd string) error {
	if len(vicPasswd) > vicPwdMaxLength {
		op.Infof("VIC appliance password length is more than %d.", vicPwdMaxLength)
		return fmt.Errorf(inValidVICPwd)
	}

	cmd := exec.Command("/etc/vmware/verify.py", vicPasswd) // #nosec
	if err := cmd.Run(); err != nil {
		op.Infof("VIC password validation failed: %s", err.Error())
		return err
	}

	return nil
}
