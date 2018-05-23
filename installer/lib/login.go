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

package lib

import (
	"context"
	"fmt"
	"net/url"
	"time"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic/lib/install/data"
	"github.com/vmware/vic/lib/install/validate"
	"github.com/vmware/vic/pkg/trace"
)

const loginTimeout = 15 * time.Second

// LoginInfo represents credentials needed to access vSphere
type LoginInfo struct {
	Target     string `json:"target"`
	User       string `json:"user"`
	Password   string `json:"password"`
	Thumbprint string `json:"thumbprint"`
	URL        *url.URL
	Validator  *validate.Validator
}

// VerifyLogin based on info given, return non nil error if validation fails.
func (info *LoginInfo) VerifyLogin() (context.CancelFunc, error) {
	defer trace.End(trace.Begin(""))

	info.URL = &url.URL{}
	info.URL.User = url.UserPassword(info.User, info.Password)
	info.URL.Host = info.Target
	info.URL.Path = ""

	log.Infof("server URL: %v\n", info.URL.Host)

	input := data.NewData()

	username := info.URL.User.Username()
	input.OpsCredentials.OpsUser = &username
	passwd, _ := info.URL.User.Password()
	input.OpsCredentials.OpsPassword = &passwd
	input.URL = info.URL
	input.Force = true
	input.Thumbprint = info.Thumbprint
	input.User = username
	input.Password = &passwd

	ctx, cancel := context.WithTimeout(context.Background(), loginTimeout)
	loginResponse := make(chan error, 1)
	var v *validate.Validator
	var err error

	go func() {
		v, err = validate.NewValidator(ctx, input)
		info.Validator = v
		loginResponse <- err
	}()

	select {
	case <-ctx.Done():
		loginResponse <- fmt.Errorf("login failed; validator context exceeded")
	case err := <-loginResponse:
		if err != nil {
			log.Infof("validator: %s", err)
			loginResponse <- err
		} else {
			loginResponse <- nil
		}

	}

	return cancel, <-loginResponse
}
