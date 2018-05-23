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

package tasks

import (
	"context"
	"crypto/tls"
	"fmt"
	"net/url"

	log "github.com/Sirupsen/logrus"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic-product/installer/fileserver/tasks/ova"
	"github.com/vmware/vic-product/installer/fileserver/tasks/plugin"
	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic-product/installer/pkg/version"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/session"
)

// Plugin has all input parameters for vic-ui ui command
type Plugin struct {
	Target *lib.LoginInfo

	Force     bool
	Configure bool
	Insecure  bool

	Company               string
	HideInSolutionManager bool
	Key                   string
	Name                  string
	Summary               string
	Version               string
	EntityType            string

	ApplianceHost             string
	ApplianceURL              string
	ApplianceServerThumbprint string
}

// NewUIPlugin Returns a UI Plugin struct with an empty target
func NewUIPlugin() *Plugin {
	return &Plugin{Target: &lib.LoginInfo{}}
}

func (p *Plugin) processInstallParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if p.Target.Validator == nil {
		cancel, err := p.Target.VerifyLogin()
		defer cancel()

		if err != nil {
			log.Error(err.Error())
			return err
		}
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

	if p.Version == "" {
		return errors.New("version must be specified")
	}

	if p.ApplianceHost == "" {
		// Obtain the OVA VM's IP
		vmIP, err := ip.FirstIPv4(ip.Eth0Interface)
		if err != nil {
			log.Error(err.Error())
			return errors.Errorf("Cannot generate appliance ip: %s", errors.ErrorStack(err))
		}
		// Fetch the OVF env to get the fileserver port
		ovf, err := lib.UnmarshaledOvfEnv()
		if err != nil {
			log.Error(err.Error())
			return errors.Errorf("Cannot get appliance ovfenv: %s", errors.ErrorStack(err))
		}
		p.ApplianceHost = fmt.Sprintf("%s:%s", GetHostname(ovf, vmIP), ovf.Properties["appliance.config_port"])
		op.Debugf("appliance host not specified. generated host: %s", p.ApplianceHost)

	}
	if p.ApplianceURL == "" {
		p.ApplianceURL = fmt.Sprintf("https://%s/files/%s-v%s.zip", p.ApplianceHost, p.Key, p.Version)
		op.Debugf("https plugin url not specified. generated plugin url: %s", p.ApplianceURL)
	}

	if p.ApplianceServerThumbprint == "" {
		var cert object.HostCertificateInfo
		if err := cert.FromURL(&url.URL{Host: p.ApplianceHost}, &tls.Config{}); err != nil {
			log.Error(err.Error())
			return errors.Errorf("Error getting thumbprint for %s: %s", p.ApplianceHost, errors.ErrorStack(err))
		}
		p.ApplianceServerThumbprint = cert.ThumbprintSHA1
		op.Debugf("server-thumbprint not specified with HTTPS plugin URL. generated thumbprint: %s", p.ApplianceServerThumbprint)
	}

	p.Insecure = true
	return nil
}

func (p *Plugin) processRemoveParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if p.Target.Validator == nil {
		cancel, err := p.Target.VerifyLogin()
		defer cancel()

		if err != nil {
			log.Error(err.Error())
			return err
		}
	}

	if p.Key == "" {
		return errors.New("key must be specified")
	}

	p.Insecure = true
	return nil
}

func (p *Plugin) processInfoParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if p.Target.Validator == nil {
		cancel, err := p.Target.VerifyLogin()
		defer cancel()

		if err != nil {
			log.Error(err.Error())
			return err
		}
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
		log.Error(err.Error())
		return err
	}

	log.Infof("### Installing UI Plugin ####")
	log.Infof("%+v", p.Target.URL)
	pInfo := &plugin.Info{
		Company:               p.Company,
		Key:                   p.Key,
		Name:                  p.Name,
		ServerThumbprint:      p.ApplianceServerThumbprint,
		ShowInSolutionManager: !p.HideInSolutionManager,
		Summary:               p.Summary,
		Type:                  "vsphere-client-serenity",
		URL:                   p.ApplianceURL,
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
		log.Error(err.Error())
		return err
	}

	reg, err := pl.IsRegistered(pInfo.Key)
	if err != nil {
		log.Error(err.Error())
		return err
	}
	if reg {
		if p.Force {
			log.Info("Removing existing plugin to force install")
			err = pl.Unregister(pInfo.Key)
			if err != nil {
				log.Error(err.Error())
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
		log.Error(err.Error())
		return err
	}

	reg, err = pl.IsRegistered(pInfo.Key)
	if err != nil {
		log.Error(err.Error())
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
			Thumbprint: p.Target.Thumbprint,
			Insecure:   true,
			UserAgent:  version.UserAgent("vic-ui-installer"),
		}

		// Configure the OVA vm to be managed by this plugin
		if err = ova.ConfigureManagedByInfo(context.TODO(), sessionConfig, pInfo.URL); err != nil {
			log.Error(err.Error())
			return err
		}
	}

	return nil
}

func (p *Plugin) Remove(ctx context.Context) error {
	op := trace.NewOperation(context.Background(), "Remove")

	var err error
	if err = p.processRemoveParams(op); err != nil {
		log.Error(err.Error())
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
		log.Error(err.Error())
		return err
	}
	reg, err := pl.IsRegistered(pInfo.Key)
	if err != nil {
		log.Error(err.Error())
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
		log.Error(err.Error())
		return err
	}

	reg, err = pl.IsRegistered(pInfo.Key)
	if err != nil {
		log.Error(err.Error())
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
		log.Error(err.Error())
		return err
	}

	pInfo := &plugin.Info{
		Key: p.Key,
	}

	pl, err := plugin.NewPluginator(context.TODO(), p.Target.URL, p.Target.Thumbprint, pInfo)
	if err != nil {
		log.Error(err.Error())
		return err
	}

	reg, err := pl.GetPlugin(p.Key)
	if err != nil {
		log.Error(err.Error())
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
