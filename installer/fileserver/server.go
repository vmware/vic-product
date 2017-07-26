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

package main

import (
	"context"
	"crypto/tls"
	"flag"
	"fmt"
	"html/template"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"syscall"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/tagvm"
	"github.com/vmware/vic/pkg/certificate"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
)

type config struct {
	addr     string
	certPath string
	keyPath  string
	cert     tls.Certificate
	serveDir string
}

// IndexHTMLOptions contains fields for html templating in index.html
type IndexHTMLOptions struct {
	InvalidLogin bool
	Feedback     string
}

var (
	admin = &lib.LoginInfo{}
	c     config
)

func Init(conf *config) {
	ud := syscall.Getuid()
	gd := syscall.Getgid()
	log.Info(fmt.Sprintf("Current UID/GID = %d/%d", ud, gd))
	/* TODO FIXME
	if ud == 0 {
		log.Error("Error: must not run as root.")
		os.Exit(1)
	}
	*/

	flag.StringVar(&conf.addr, "addr", ":9443", "Listen address - must include host and port (addr:port)")
	flag.StringVar(&conf.certPath, "cert", "", "Path to server certificate in PEM format")
	flag.StringVar(&conf.keyPath, "key", "", "Path to server certificate key in PEM format")
	flag.StringVar(&conf.serveDir, "dir", "/opt/vmware/fileserver", "Directory to serve and contain html data")

	flag.Parse()

	if (conf.certPath == "" && conf.keyPath != "") || (conf.certPath != "" && conf.keyPath == "") {
		log.Errorf("Both certificate and key must be specified")
	}

	var err error
	if conf.certPath != "" {
		log.Infof("Loading certificate %s and key %s", conf.certPath, conf.keyPath)
		conf.cert, err = tls.LoadX509KeyPair(conf.certPath, conf.keyPath)
		if err != nil {
			log.Fatalf("Failed to load certificate %s and key %s: %s", conf.certPath, conf.keyPath, err)
		}
	} else {
		log.Info("Generating self signed certificate")
		c, k, err := certificate.CreateSelfSigned(conf.addr, []string{"VMware, Inc."}, 2048)
		if err != nil {
			log.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
		conf.cert, err = tls.X509KeyPair(c.Bytes(), k.Bytes())
		if err != nil {
			log.Errorf("Failed to load generated self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
	}
	log.Infof("Loaded certificate")
}

func main() {

	Init(&c)

	mux := http.NewServeMux()

	// attach static asset routes
	routes := []string{"css", "images", "fonts"}
	for _, route := range routes {
		httpPath := fmt.Sprintf("/%s/", route)
		dirPath := filepath.Join(c.serveDir, "/html/", route)
		mux.Handle(httpPath, http.StripPrefix(httpPath, http.FileServer(http.Dir(dirPath))))
	}

	// attach fileserver route
	dirPath := filepath.Join(c.serveDir, "files")
	mux.Handle("/files/", http.StripPrefix("/files/", http.FileServer(http.Dir(dirPath))))

	// attach register route, for registration automation
	mux.Handle("/register", http.HandlerFunc(registerHandler))

	// attach root index route
	mux.Handle("/", http.HandlerFunc(indexHandler))

	// start the web server
	t := &tls.Config{}
	t.Certificates = []tls.Certificate{c.cert}
	s := &http.Server{
		Addr:      c.addr,
		Handler:   mux,
		TLSConfig: t,
	}

	log.Infof("Starting fileserver server on %s", s.Addr)
	log.Fatal(s.ListenAndServeTLS("", ""))
}

func indexHandler(resp http.ResponseWriter, req *http.Request) {
	defer trace.End(trace.Begin(""))

	html := &IndexHTMLOptions{InvalidLogin: true}

	if req.Method == http.MethodPost {
		// verify login
		admin.Target = req.FormValue("target")
		admin.User = req.FormValue("user")
		admin.Password = req.FormValue("password")

		if err := admin.VerifyLogin(); err != nil {
			log.Infof("Validation failed")
		} else {
			log.Infof("validation succeeded")
			html.Feedback = startInitializationServices()
			html.InvalidLogin = false
		}
	}

	renderTemplate(resp, "html/index.html", html)
}

func renderTemplate(resp http.ResponseWriter, filename string, data interface{}) {
	defer trace.End(trace.Begin(""))

	log.Infof("render: %s", filename)
	filename = fmt.Sprintf("%s/%s", c.serveDir, filename)
	log.Infof("render: %s", filename)
	tmpl, err := template.ParseFiles(filename)
	if err != nil {
		http.Error(resp, err.Error(), http.StatusInternalServerError)
	}
	if err := tmpl.Execute(resp, data); err != nil {
		http.Error(resp, err.Error(), http.StatusInternalServerError)
	}
}

// startInitializationServices performs some OVA init tasks - tagging the OVA VM
// registering Admiral with PSC. Errors, if any, are concatenated and returned.
func startInitializationServices() string {
	var errorMsg []string

	ctx := context.TODO()
	if err := tagvm.Run(ctx, admin.Validator.Session); err != nil {
		log.Debug(errors.ErrorStack(err))
		errorMsg = append(errorMsg, "Failed to locate productVM, trusted content is not available")
	}

	if err := registerWithPSC(ctx); err != nil {
		log.Debug(errors.ErrorStack(err))
		errorMsg = append(errorMsg, "Failed to register with PSC: %s", err.Error())
	}

	return strings.Join(errorMsg, "\n")
}
