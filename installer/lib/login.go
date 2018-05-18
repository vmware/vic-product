// Copyright 2017-2018 VMware, Inc. All Rights Reserved.
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

package lib

import (
	"context"
	"crypto/tls"
	"fmt"
	"net/url"
	"time"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic-product/installer/pkg/version"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/session"
)

const loginTimeout = 15 * time.Second

// LoginInfo represents credentials needed to access vSphere
type LoginInfo struct {
	Target     string `json:"target"`
	User       string `json:"user"`
	Password   string `json:"password"`
	Thumbprint string `json:"thumbprint"`
	URL        *url.URL
	Session    *session.Session
}

// VerifyLogin based on info given, return non nil error if validation fails.
func (info *LoginInfo) VerifyLogin(op trace.Operation) (context.CancelFunc, error) {
	defer trace.End(trace.Begin(""))

	info.URL = &url.URL{
		Scheme: "https",
		Host:   info.Target,
		User:   url.UserPassword(info.User, info.Password),
		Path:   "",
	}

	op.Infof("server URL: %v\n", info.URL.Host)

	ctx, cancel := context.WithTimeout(context.Background(), loginTimeout)
	loginResponse := make(chan error, 1)
	var err error

	go func() {
		if info.Thumbprint == "" {
			var cert object.HostCertificateInfo
			if err = cert.FromURL(info.URL, new(tls.Config)); err != nil {
				op.Errorf("failed to get host cert: %s", err)
				loginResponse <- err
				return
			}

			if cert.Err != nil {
				op.Errorf("Failed to verify certificate for target=%s (thumbprint=%s)",
					info.URL.Host, cert.ThumbprintSHA1)
				loginResponse <- cert.Err
				return
			}

			info.Thumbprint = cert.ThumbprintSHA1
			op.Debugf("Accepting host %q thumbprint %s", info.URL.Host, info.Thumbprint)
		}

		sessionconfig := &session.Config{
			Thumbprint: info.Thumbprint,
			UserAgent:  version.UserAgent("vic-appliance"),
			Service:    info.URL.String(),
		}

		info.Session = session.NewSession(sessionconfig)
		info.Session, err = info.Session.Connect(op)
		if err != nil {
			op.Errorf("failed to connect: %s", err)
			loginResponse <- err
			return
		}

		// #nosec: Errors unhandled.
		info.Session.Populate(op)
		loginResponse <- err
	}()

	select {
	case <-ctx.Done():
		loginResponse <- fmt.Errorf("login failed; session context deadline exceeded")
	case err := <-loginResponse:
		if err != nil {
			op.Infof("session: %s", err)
			loginResponse <- err
		} else {
			loginResponse <- nil
		}

	}

	return cancel, <-loginResponse
}
