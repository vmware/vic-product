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
	"net/url"

	log "github.com/sirupsen/logrus"

	"github.com/vmware/vic/lib/install/data"
	"github.com/vmware/vic/lib/install/validate"
	"github.com/vmware/vic/pkg/trace"
)

type LoginInfo struct {
	Target    string `json:"target"`
	User      string `json:"user"`
	Password  string `json:"password"`
	Validator *validate.Validator
}

// Verify login based on info given, return non nil error if validation fails.
func (info *LoginInfo) VerifyLogin() error {
	defer trace.End(trace.Begin(""))

	ctx := context.TODO()

	var u url.URL
	u.User = url.UserPassword(info.User, info.Password)
	u.Host = info.Target
	u.Path = ""
	log.Infof("server URL: %v\n", u.Host)

	input := data.NewData()

	username := u.User.Username()
	input.OpsCredentials.OpsUser = &username
	passwd, _ := u.User.Password()
	input.OpsCredentials.OpsPassword = &passwd
	input.URL = &u
	input.Force = true

	input.User = username
	input.Password = &passwd

	v, err := validate.NewValidator(ctx, input)
	if err != nil {
		log.Infof("validator: %s", err)
		return err
	}

	info.Validator = v

	return nil
}
