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

package main

import (
	"context"
	"crypto/tls"
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"syscall"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic-product/installer/fileserver/routes"
	"github.com/vmware/vic-product/installer/fileserver/tasks"
	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic/pkg/certificate"
	"github.com/vmware/vic/pkg/trace"
)

type serverConfig struct {
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

type serverRoute struct {
	route   string
	handler http.Handler
}

func parseServerConfig(op trace.Operation, conf *serverConfig) {
	ud := syscall.Getuid()
	gd := syscall.Getgid()
	op.Info(fmt.Sprintf("Current UID/GID = %d/%d", ud, gd))
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

	routes.SetRenderPath(conf.serveDir)

	switch conf.logLevel {
	case "warning":
		trace.Logger.Level = log.WarnLevel
	case "info":
		trace.Logger.Level = log.InfoLevel
	default:
		trace.Logger.Level = log.DebugLevel
	}

	if (conf.certPath == "" && conf.keyPath != "") || (conf.certPath != "" && conf.keyPath == "") {
		op.Errorf("Both certificate and key must be specified")
	}

	var err error
	if conf.certPath != "" {
		op.Infof("Loading certificate %s and key %s", conf.certPath, conf.keyPath)
		conf.cert, err = tls.LoadX509KeyPair(conf.certPath, conf.keyPath)
		if err != nil {
			op.Fatalf("Failed to load certificate %s and key %s: %s", conf.certPath, conf.keyPath, err)
		}
	} else {
		op.Info("Generating self signed certificate")
		c, k, err := certificate.CreateSelfSigned(conf.addr, []string{"VMware, Inc."}, 2048)
		if err != nil {
			op.Errorf("Failed to generate a self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
		conf.cert, err = tls.X509KeyPair(c.Bytes(), k.Bytes())
		if err != nil {
			op.Errorf("Failed to load generated self-signed certificate: %s. Exiting.", err.Error())
			os.Exit(1)
		}
	}
	op.Infof("Loaded certificate")

	ovf, err := lib.UnmarshaledOvfEnv()
	if err != nil {
		switch err.(type) {
		case lib.EnvFetchError:
			op.Fatalf("impossible to fetch ovf environment, exiting")
			os.Exit(1)
		case lib.UnmarshalError:
			op.Errorf("error: %s", err.Error())
		}
	}

	if ip, err := ip.FirstIPv4(ip.Eth0Interface); err == nil {
		conf.serverHostname = tasks.GetHostname(ovf, ip)
		if port, ok := ovf.Properties["management_portal.management_portal_port"]; ok {
			conf.admiralPort = port
		}
	}

	// get the fileserver vic tar location
	filepath.Walk("/opt/vmware/fileserver/files/", func(path string, f os.FileInfo, err error) error {
		if strings.HasSuffix(path, ".tar.gz") && !strings.Contains(path, "vic_ui") {
			conf.vicTarName = f.Name()
			return fmt.Errorf("stop") // returning an error stops the file walk
		}
		return nil // vic tar not found, continue walking
	})
}

// cspMiddleware sets the Content-Security-Policy header to prevent clickjacking
// https://www.owasp.org/index.php/Content_Security_Policy_Cheat_Sheet#Preventing_Clickjacking
func cspMiddleware() func(next http.Handler) http.Handler {
	header := "Content-Security-Policy"
	value := "frame-ancestors 'none';"
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Add(header, value)
			next.ServeHTTP(w, r)
		})
	}
}

func main() {
	op := trace.NewOperation(context.Background(), "Main")
	var c serverConfig
	parseServerConfig(op, &c)

	mux := http.NewServeMux()

	// attach static asset routes
	staticAssets := []string{"css", "js", "images", "fonts"}
	for _, asset := range staticAssets {
		httpPath := fmt.Sprintf("/%s/", asset)
		dirPath := filepath.Join(c.serveDir, "/html/", asset)
		mux.Handle(httpPath, http.StripPrefix(httpPath, http.FileServer(http.Dir(dirPath))))
	}

	indexRenderer := &routes.IndexHTMLRenderer{
		ServerHostname: c.serverHostname,
		ServerAddress:  c.addr,
		AdmiralPort:    c.admiralPort,
		VicTarName:     c.vicTarName,
	}
	// attach fileserver route
	routes := []*serverRoute{
		{"/plugin/install", http.HandlerFunc(routes.InstallPluginHandler)},
		{"/plugin/remove", http.HandlerFunc(routes.RemovePluginHandler)},
		{"/plugin/upgrade", http.HandlerFunc(routes.UpgradePluginHandler)},
		{"/register", http.HandlerFunc(routes.RegisterHandler)},
		{"/thumbprint", http.HandlerFunc(routes.ThumbprintHandler)},
		{"/files/", http.StripPrefix("/files/", http.FileServer(http.Dir(filepath.Join(c.serveDir, "files"))))},
		{"/", http.HandlerFunc(indexRenderer.IndexHandler)},
	}

	for _, route := range routes {
		mux.Handle(route.route, route.handler)
	}

	// start the web server
	fileserver := &http.Server{
		Addr:      c.addr,
		Handler:   cspMiddleware()(mux),
		TLSConfig: lib.GetTLSServerConfig(c.cert),
	}

	redirectServer := &http.Server{
		Addr: ":80",
		Handler: http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			target := "https://" + req.Host + c.addr + req.URL.Path
			http.Redirect(w, req, target, http.StatusMovedPermanently)
		}),
	}
	// collect signals and errors to stop the fileserver
	signals := make(chan os.Signal, 1)
	errors := make(chan error, 1)

	go func() {
		// redirect port 80 to 9443 to improve ux on ova
		op.Infof("Starting redirect server on %s", redirectServer.Addr)
		if err := redirectServer.ListenAndServe(); err != nil {
			errors <- err
		}
	}()
	go func() {
		op.Infof("Starting fileserver server on %s", fileserver.Addr)
		if err := fileserver.ListenAndServeTLS("", ""); err != nil {
			errors <- err
		}
	}()

	signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)

	select {
	case sig := <-signals:
		op.Fatalf("signal %s received", sig)
	case err := <-errors:
		op.Fatalf("error %s received", err)
	}
	fileserver.Close()
	redirectServer.Close()
	close(signals)
	close(errors)
}
