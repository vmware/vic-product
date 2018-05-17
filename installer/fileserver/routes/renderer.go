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
	"fmt"
	"html/template"
	"net/http"

	log "github.com/Sirupsen/logrus"
	"github.com/vmware/vic/pkg/trace"
)

var (
	// Share the renderer between the whole package. Set the rootPath before use if needed.
	renderer *templateRenderer
)

type templateRenderer struct {
	rootPath string
}

func init() {
	renderer = &templateRenderer{}
}

// SetRenderPath sets the render path of the global renderer var
func SetRenderPath(path string) {
	renderer.rootPath = path
}

// RenderTemplate writes a golang html template to an http response
func RenderTemplate(resp http.ResponseWriter, filename string, data interface{}) {
	defer trace.End(trace.Begin(""))

	log.Infof("render: %s", filename)
	filename = fmt.Sprintf("%s/%s", renderer.rootPath, filename)
	tmpl, err := template.ParseFiles(filename)
	if err != nil {
		http.Error(resp, err.Error(), http.StatusInternalServerError)
		return
	}
	if err := tmpl.Execute(resp, data); err != nil {
		http.Error(resp, err.Error(), http.StatusInternalServerError)
		return
	}
}
