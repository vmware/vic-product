// Copyright 2016 VMware, Inc. All Rights Reserved.
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

package ui

import (
	"context"
	"fmt"
	"strings"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/vic/cmd/vic-machine/common"
	"github.com/vmware/vic/lib/install/ova"
	"github.com/vmware/vic/lib/install/plugin"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/version"
	"github.com/vmware/vic/pkg/vsphere/session"
)

// Plugin has all input parameters for vic-ui ui command
type Plugin struct {
	*common.Target

	Force     bool
	Configure bool
	Insecure  bool

	Company               string
	HideInSolutionManager bool
	Key                   string
	Name                  string
	ServerThumbprint      string
	Summary               string
	Type                  string
	URL                   string
	Version               string
	EntityType            string
}

func NewUI() *Plugin {
	p := &Plugin{Target: common.NewTarget()}
	return p
}

func (p *Plugin) processInstallParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if err := p.HasCredentials(op); err != nil {
		return err
	}

	if p.Company == "" {
		return errors.New("company must be specified")
	}

	if p.Key == "" {
		return errors.New("key must be specified")
	}

	if p.Name == "" {
		return errors.New("name must be specified")
	}

	if p.Summary == "" {
		return errors.New("summary must be specified")
	}

	if p.URL == "" {
		return errors.New("url must be specified")
	}

	if p.Version == "" {
		return errors.New("version must be specified")
	}

	if strings.HasPrefix(strings.ToLower(p.URL), "https://") && p.ServerThumbprint == "" {
		return errors.New("server-thumbprint must be specified when using HTTPS plugin URL")
	}

	p.Insecure = true
	return nil
}

func (p *Plugin) processRemoveParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if err := p.HasCredentials(op); err != nil {
		return err
	}

	if p.Key == "" {
		return errors.New("key must be specified")
	}

	p.Insecure = true
	return nil
}

func (p *Plugin) processInfoParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if err := p.HasCredentials(op); err != nil {
		return err
	}

	if p.Key == "" {
		return errors.New("key must be specified")
	}
	return nil
}

func (p *Plugin) Install(ctx context.Context) error {
	op := trace.NewOperation(ctx, "Install")

	var err error
	if err = p.processInstallParams(op); err != nil {
		return err
	}

	log.Infof("### Installing UI Plugin ####")

	pInfo := &plugin.Info{
		Company:               p.Company,
		Key:                   p.Key,
		Name:                  p.Name,
		ServerThumbprint:      p.ServerThumbprint,
		ShowInSolutionManager: !p.HideInSolutionManager,
		Summary:               p.Summary,
		Type:                  "vsphere-client-serenity",
		URL:                   p.URL,
		Version:               p.Version,
	}

	if p.EntityType != "" {
		pInfo.ManagedEntityInfo = &plugin.ManagedEntityInfo{
			Description: p.Summary,
			EntityType:  p.EntityType,
		}
	}

	pl, err := plugin.NewPluginator(context.TODO(), p.Target.URL, p.Target.Thumbprint, pInfo)
	if err != nil {
		return err
	}

	reg, err := pl.IsRegistered(pInfo.Key)
	if err != nil {
		return err
	}
	if reg {
		if p.Force {
			log.Info("Removing existing plugin to force install")
			err = pl.Unregister(pInfo.Key)
			if err != nil {
				return err
			}
			log.Info("Removed existing plugin")
		} else {
			msg := fmt.Sprintf("plugin (%s) is already registered", pInfo.Key)
			log.Errorf("Install failed: %s", msg)
			return errors.New(msg)
		}
	}

	log.Info("Installing plugin")
	err = pl.Register()
	if err != nil {
		return err
	}

	reg, err = pl.IsRegistered(pInfo.Key)
	if err != nil {
		return err
	}
	if !reg {
		msg := fmt.Sprintf("post-install check failed to find %s registered", pInfo.Key)
		log.Errorf("Install failed: %s", msg)
		return errors.New(msg)
	}

	log.Info("Installed UI plugin")

	if p.Configure {
		sessionConfig := &session.Config{
			Service:    p.Target.URL.Scheme + "://" + p.Target.URL.Host,
			User:       p.Target.URL.User,
			Thumbprint: p.Thumbprint,
			Insecure:   true,
			UserAgent:  version.UserAgent("vic-ui-installer"),
		}

		// Configure the OVA vm to be managed by this plugin
		if err = ova.ConfigureManagedByInfo(context.TODO(), sessionConfig, pInfo.URL); err != nil {
			return err
		}
	}

	return nil
}

func (p *Plugin) Remove(ctx context.Context) error {
	op := trace.NewOperation(context.Background(), "Remove")

	var err error
	if err = p.processRemoveParams(op); err != nil {
		return err
	}

	if p.Force {
		log.Info("Ignoring --force")
	}

	log.Infof("### Removing UI Plugin ####")

	pInfo := &plugin.Info{
		Key: p.Key,
	}

	pl, err := plugin.NewPluginator(context.TODO(), p.Target.URL, p.Target.Thumbprint, pInfo)
	if err != nil {
		return err
	}
	reg, err := pl.IsRegistered(pInfo.Key)
	if err != nil {
		return err
	}
	if reg {
		log.Infof("Found target plugin: %s", pInfo.Key)
	} else {
		msg := fmt.Sprintf("failed to find target plugin (%s)", pInfo.Key)
		log.Errorf("Remove failed: %s", msg)
		return errors.New(msg)
	}

	log.Info("Removing plugin")
	err = pl.Unregister(pInfo.Key)
	if err != nil {
		return err
	}

	reg, err = pl.IsRegistered(pInfo.Key)
	if err != nil {
		return err
	}
	if reg {
		msg := fmt.Sprintf("post-remove check found %s still registered", pInfo.Key)
		log.Errorf("Remove failed: %s", msg)
		return errors.New(msg)
	}

	log.Info("Removed UI plugin")
	return nil
}

func (p *Plugin) Info(ctx context.Context) error {
	op := trace.NewOperation(context.Background(), "Info")

	var err error
	if err = p.processInfoParams(op); err != nil {
		return err
	}

	pInfo := &plugin.Info{
		Key: p.Key,
	}

	pl, err := plugin.NewPluginator(context.TODO(), p.Target.URL, p.Target.Thumbprint, pInfo)
	if err != nil {
		return err
	}

	reg, err := pl.GetPlugin(p.Key)
	if err != nil {
		return err
	}
	if reg == nil {
		return errors.Errorf("%s is not registered", p.Key)
	}

	log.Infof("%s is registered", p.Key)
	log.Info("")
	log.Infof("Key: %s", reg.Key)
	log.Infof("Name: %s", reg.Description.GetDescription().Label)
	log.Infof("Summary: %s", reg.Description.GetDescription().Summary)
	log.Infof("Company: %s", reg.Company)
	log.Infof("Version: %s", reg.Version)
	return nil
}
