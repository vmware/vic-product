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
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"syscall"
	"time"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic-product/installer/tagvm"
	"github.com/vmware/vic/pkg/certificate"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
)

type config struct {
	addr           string
	certPath       string
	keyPath        string
	cert           tls.Certificate
	serveDir       string
	serverHostname string
	admiralPort    string
	installerPort  string
	vicTarName     string
	logLevel       string
}

// IndexHTMLOptions contains fields for html templating in index.html
type IndexHTMLOptions struct {
	InitErrorFeedback   string
	InitSuccessFeedback string
	NeedLogin           bool
	AdmiralAddr         string
	DemoVCHAddr         string
	FileserverAddr      string
	ValidationError     string
}

var (
	admin = &lib.LoginInfo{}
	c     config

	// pscInstance holds the form input for the PSC field
	pscInstance string

	// pscDomain holds the form input for the PSC Admin Domain field
	pscDomain string
)

const initServicesTimestamp = "./registration-timestamps.txt"

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
	flag.StringVar(&conf.logLevel, "level", "debug", "Set's the log level to [info|debug|warning]; defaults to debug")

	flag.Parse()

	switch conf.logLevel {
	case "warning":
		log.SetLevel(log.WarnLevel)
	case "info":
		log.SetLevel(log.InfoLevel)
	default:
		log.SetLevel(log.DebugLevel)
	}

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

	ovf, err := lib.UnmarshaledOvfEnv()
	if err != nil {
		switch err.(type) {
		case lib.EnvFetchError:
			log.Fatalf("impossible to fetch ovf environment, exiting")
			os.Exit(1)
		case lib.UnmarshalError:
			log.Errorf("error: %s", err.Error())
		}
	}

	if ip, err := ip.FirstIPv4(ip.Eth0Interface); err == nil {
		conf.serverHostname = getHostname(ovf, ip)
		if port, ok := ovf.Properties["management_portal.port"]; ok {
			conf.admiralPort = port
		}
	}

	// get the fileserver vic tar location
	filepath.Walk("/opt/vmware/fileserver/files/", func(path string, f os.FileInfo, err error) error {
		if strings.HasSuffix(path, ".tar.gz") {
			c.vicTarName = f.Name()
			return fmt.Errorf("stop") // returning an error stops the file walk
		}
		return nil // vic tar not found, continue walking
	})
}

func main() {

	Init(&c)

	mux := http.NewServeMux()

	// attach static asset routes
	routes := []string{"css", "js", "images", "fonts"}
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
	s := lib.GetTLSServer(c.addr, mux, c.cert)

	log.Infof("Starting fileserver server on %s", s.Addr)
	// redirect port 80 to 9443 to improve ux on ova
	go http.ListenAndServe(":80", http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
		target := "https://" + req.Host + c.addr + req.URL.Path
		http.Redirect(w, req, target, http.StatusMovedPermanently)
	}))
	log.Fatal(s.ListenAndServeTLS("", ""))
}

func indexHandler(resp http.ResponseWriter, req *http.Request) {
	defer trace.End(trace.Begin(""))

	html := &IndexHTMLOptions{
		NeedLogin:           needInitializationServices(req),
		InitErrorFeedback:   "",
		InitSuccessFeedback: "",
		ValidationError:     "",
	}

	if req.Method == http.MethodPost {
		// verify login
		admin.Target = req.FormValue("target")
		admin.User = req.FormValue("user")
		admin.Password = req.FormValue("password")
		pscInstance = req.FormValue("psc")
		pscDomain = req.FormValue("pscDomain")
		cancel, err := admin.VerifyLogin()
		defer cancel()
		if err != nil {
			log.Infof("Validation failed: %s", err.Error())
			html.ValidationError = err.Error()
		} else {
			log.Infof("Validation succeeded")
			html.InitErrorFeedback = startInitializationServices()
			// Display success message upon init success.
			if html.InitErrorFeedback == "" {
				html.InitSuccessFeedback = "Installation successful. Refer to the Post-install and Deployment tasks below."
			}

			html.NeedLogin = false
		}
	}

	html.AdmiralAddr = fmt.Sprintf("https://%s:%s", c.serverHostname, c.admiralPort)
	html.DemoVCHAddr = fmt.Sprintf("https://%s:%s", c.serverHostname, c.installerPort)
	html.FileserverAddr = fmt.Sprintf("https://%s%s/files/%s", c.serverHostname, c.addr, c.vicTarName)

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
		errorMsg = append(errorMsg, "Failed to locate VIC Appliance. Please check the vCenter Server provided and try again")
	}

	if err := registerWithPSC(ctx); err != nil {
		log.Debug(errors.ErrorStack(err))
		errorMsg = append(errorMsg, "Failed to register with PSC. Please check the PSC settings provided and try again")
	}

	if len(errorMsg) == 0 {
		err := ioutil.WriteFile(initServicesTimestamp, []byte(time.Now().String()), 0644)
		if err != nil {
			log.Debug(errors.ErrorStack(err))
			errorMsg = append(errorMsg, "Failed to write to timestamp file: %s", err.Error())
		}
	}
	return strings.Join(errorMsg, "<br />")
}

func needInitializationServices(req *http.Request) bool {
	_, err := os.Stat(initServicesTimestamp)
	return os.IsNotExist(err) || req.URL.Query().Get("login") == "true"
}
