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
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/vmware/vic-product/installer/fileserver/tasks"
	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic/pkg/trace"
)

type pluginPayload struct {
	Vc        *targetParameters    `json:"vc"`
	Plugin    *pluginParameters    `json:"plugin"`
	Appliance *applianceParameters `json:"appliance"`
}

type targetParameters struct {
	Target     string `json:"target,omitempty"`
	User       string `json:"user,omitempty"`
	Password   string `json:"password,omitempty"`
	Thumbprint string `json:"thumbprint,omitempty"`
}

type pluginParameters struct {
	// If given, uses the H5 or Flex plugin presets
	Preset string `json:"preset,omitempty"`

	// Optional Parameters
	Force    bool `json:"force,omitempty"`
	Insecure bool `json:"insecure,omitempty"`

	// Mandatory Parameters
	Configure             bool   `json:"configure,omitempty"`
	Company               string `json:"company,omitempty"`
	HideInSolutionManager bool   `json:"hide,omitempty"`
	Key                   string `json:"key,omitempty"`
	Name                  string `json:"name,omitempty"`
	Summary               string `json:"summary,omitempty"`
	Version               string `json:"version,omitempty"`
	EntityType            string `json:"entityType,omitempty"`
}

type applianceParameters struct {
	Host             string `json:"host,omitempty"`
	URL              string `json:"url,omitempty"`
	ServerThumbprint string `json:"thumbprint,omitempty"`
	RootPassword     string `json:"vicpassword,omitempty"`
}

type httpError struct {
	ErrorType string `json:"type"`
	Title     string `json:"title"`
	code      int
}

// InstallPluginHandler unwraps a json body as a tasks.Plugin and preforms
// the InstallPlugin task
func InstallPluginHandler(resp http.ResponseWriter, req *http.Request) {
	defer trace.End(trace.Begin(""))

	switch req.Method {
	case http.MethodPost:
		op := trace.NewOperation(context.Background(), "InstallPluginHandler")
		if req.Body == nil {
			(&httpError{
				Title: "Request body not found.",
				code:  http.StatusBadRequest,
			}).Error(op, resp)
			return
		}

		plugin, err := decodePluginPayload(op, req)
		if err != nil {
			op.Errorf("Could not decode plugin payload: %s", err.Error())
			(&httpError{
				Title: "Could not decode body.",
				code:  http.StatusUnprocessableEntity,
			}).Error(op, resp)
			return
		}

		if err := verifyVICApplianceLogin(op, plugin.AppliancePassword); err != nil {
			(&httpError{
				Title: inValidVICPwd,
				code:  http.StatusUnauthorized,
			}).Error(op, resp)
			return
		}

		cancel, err := plugin.Target.VerifyLogin(op)
		defer cancel()
		if err != nil {
			op.Errorf("Could not login to vc: %s", err.Error())
			(&httpError{
				Title: "Error authenticating with vc.",
				code:  http.StatusUnauthorized,
			}).Error(op, resp)
			return
		}
		defer plugin.Target.Session.Logout(op)

		if err := plugin.Install(op); err != nil {
			op.Errorf("Could not install plugin: %s", err.Error())
			(&httpError{
				Title: "Error installing plugin.",
				code:  http.StatusInternalServerError,
			}).Error(op, resp)
			return
		}

		resp.WriteHeader(http.StatusNoContent)
	default:
		http.Error(resp, "only accepts POST", http.StatusMethodNotAllowed)
	}
}

// RemovePluginHandler unwraps a json body as a tasks.Plugin and preforms
// the RemovePlugin task
func RemovePluginHandler(resp http.ResponseWriter, req *http.Request) {
	defer trace.End(trace.Begin(""))

	switch req.Method {
	case http.MethodPost:
		op := trace.NewOperation(context.Background(), "RemovePluginHandler")
		if req.Body == nil {
			(&httpError{
				Title: "Request body not found.",
				code:  http.StatusBadRequest,
			}).Error(op, resp)
			return
		}

		plugin, err := decodePluginPayload(op, req)
		if err != nil {
			op.Errorf("Could not decode plugin payload: %s", err.Error())
			(&httpError{
				Title: "Could not decode body.",
				code:  http.StatusUnprocessableEntity,
			}).Error(op, resp)
			return
		}

		if err := verifyVICApplianceLogin(op, plugin.AppliancePassword); err != nil {
			(&httpError{
				Title: inValidVICPwd,
				code:  http.StatusUnauthorized,
			}).Error(op, resp)
			return
		}

		cancel, err := plugin.Target.VerifyLogin(op)
		defer cancel()
		if err != nil {
			op.Errorf("Could not login to vc: %s", err.Error())
			(&httpError{
				Title: "Error authenticating with vc.",
				code:  http.StatusUnauthorized,
			}).Error(op, resp)
			return
		}
		defer plugin.Target.Session.Logout(op)

		if err := plugin.Remove(op); err != nil {
			op.Errorf("Could not remove plugin: %s", err.Error())
			(&httpError{
				Title: "Error removing plugin.",
				code:  http.StatusInternalServerError,
			}).Error(op, resp)
			return
		}

		resp.WriteHeader(http.StatusNoContent)
	default:
		http.Error(resp, "only accepts POST", http.StatusMethodNotAllowed)
	}
}

// UpgradePluginHandler unwraps a json body as a tasks.Plugin and preforms
// the force InstallPlugin task
func UpgradePluginHandler(resp http.ResponseWriter, req *http.Request) {
	defer trace.End(trace.Begin(""))

	switch req.Method {
	case http.MethodPost:
		op := trace.NewOperation(context.Background(), "UpgradePluginHandler")
		if req.Body == nil {
			(&httpError{
				Title: "Request body not found.",
				code:  http.StatusBadRequest,
			}).Error(op, resp)
			return
		}

		plugin, err := decodePluginPayload(op, req)
		if err != nil {
			op.Errorf("Could not decode plugin payload: %s", err.Error())
			(&httpError{
				Title: "Could not decode body.",
				code:  http.StatusUnprocessableEntity,
			}).Error(op, resp)
			return
		}

		if err := verifyVICApplianceLogin(op, plugin.AppliancePassword); err != nil {
			(&httpError{
				Title: inValidVICPwd,
				code:  http.StatusUnauthorized,
			}).Error(op, resp)
			return
		}

		cancel, err := plugin.Target.VerifyLogin(op)
		defer cancel()
		if err != nil {
			op.Errorf("Could not login to vc: %s", err.Error())
			(&httpError{
				Title: "Error authenticating with vc.",
				code:  http.StatusUnauthorized,
			}).Error(op, resp)
			return
		}
		defer plugin.Target.Session.Logout(op)

		plugin.Force = true

		if err := plugin.Install(op); err != nil {
			op.Errorf("Could not upgrade plugin: %s", err.Error())
			(&httpError{
				Title: "Error upgrading plugin.",
				code:  http.StatusInternalServerError,
			}).Error(op, resp)
			return
		}

		resp.WriteHeader(http.StatusNoContent)
	default:
		http.Error(resp, "only accepts POST", http.StatusMethodNotAllowed)
	}
}

func decodePluginPayload(op trace.Operation, req *http.Request) (*tasks.Plugin, error) {
	defer trace.End(trace.Begin(""))

	var p pluginPayload
	err := json.NewDecoder(req.Body).Decode(&p)
	if err != nil {
		return nil, err
	}
	defer req.Body.Close()

	if p.Vc == nil {
		return nil, errors.New("Please supply a vCenter target object")
	}

	if p.Plugin == nil {
		return nil, errors.New("Please supply a Plugin object")
	}

	if p.Appliance == nil {
		p.Appliance = &applianceParameters{}
	}

	loginInfo := &lib.LoginInfo{
		Target:     p.Vc.Target,
		User:       p.Vc.User,
		Password:   p.Vc.Password,
		Thumbprint: p.Vc.Thumbprint,
	}

	var plugin *tasks.Plugin
	switch p.Plugin.Preset {
	case "H5":
		plugin = tasks.NewH5UIPlugin(loginInfo)
	default:
		plugin = tasks.NewUIPlugin(loginInfo)
		plugin.Configure = p.Plugin.Configure
		plugin.Company = p.Plugin.Company
		plugin.HideInSolutionManager = p.Plugin.HideInSolutionManager
		plugin.Key = p.Plugin.Key
		plugin.Name = p.Plugin.Name
		plugin.Summary = p.Plugin.Summary
		plugin.Version = p.Plugin.Version
		plugin.EntityType = p.Plugin.EntityType
	}

	plugin.Force = p.Plugin.Force
	plugin.Insecure = p.Plugin.Insecure

	plugin.ApplianceHost = p.Appliance.Host
	plugin.ApplianceServerThumbprint = p.Appliance.ServerThumbprint
	plugin.ApplianceURL = p.Appliance.URL
	plugin.AppliancePassword = p.Appliance.RootPassword

	return plugin, nil
}

func (e *httpError) Error(op trace.Operation, resp http.ResponseWriter) {
	if e.code == 0 {
		e.code = http.StatusBadRequest
	}
	if e.ErrorType == "" {
		e.ErrorType = "about:blank"
	}
	resp.WriteHeader(e.code)
	err := json.NewEncoder(resp).Encode(e)
	if err != nil {
		op.Errorf("Cannot send http error response: %s", err)
		fmt.Fprintln(resp, "Error serving json.")
	}
}
