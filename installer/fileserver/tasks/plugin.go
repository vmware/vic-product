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

package tasks

import (
	"context"
	"crypto/tls"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/vic-product/installer/fileserver/tasks/ova"
	"github.com/vmware/vic-product/installer/fileserver/tasks/plugin"
	"github.com/vmware/vic-product/installer/lib"
	"github.com/vmware/vic-product/installer/pkg/ip"
	"github.com/vmware/vic/pkg/errors"
	"github.com/vmware/vic/pkg/trace"
)

const (
	h5ClientPluginName      = "vSphere Integrated Containers-H5Client"
	h5ClientPluginSummary   = "Plugin for vSphere Integrated Containers-H5Client"
	h5ClientPluginKey       = "com.vmware.vic"
	flexClientPluginName    = "vSphere Integrated Containers-FlexClient"
	flexClientPluginSummary = "Plugin for vSphere Integrated Containers-FlexClient"
	flexClientPluginKey     = "com.vmware.vic.ui"
	pluginCompany           = "VMware"
	pluginEntityType        = "VicApplianceVM"
	fileserverPluginsPath   = "/opt/vmware/fileserver/files/"
)

var (
	pluginVersion string
)

func init() {
	op := trace.NewOperation(context.Background(), "Init")
	// Match the com.vmware.vic-vX.X.X.X.zip file
	re := regexp.MustCompile(`com\.vmware\.vic-v(\d+\.\d+\.\d+\.\d+)\.zip`)
	filepath.Walk(fileserverPluginsPath, func(path string, f os.FileInfo, err error) error {
		// First match from FindStringSubmatch is always the full match
		if f == nil || f.IsDir() {
			return nil
		}
		match := re.FindStringSubmatch(f.Name())
		if len(match) > 1 {
			pluginVersion = match[1]
			op.Debugf("found plugin '%s' with version '%s'", f.Name(), match[1])
			return fmt.Errorf("stop") // returning an error stops the file walk
		}
		return nil
	})
}

// Plugin has all input parameters for vic-ui ui command
type Plugin struct {
	Target *lib.LoginInfo

	Force    bool
	Insecure bool

	Company               string
	HideInSolutionManager bool
	Configure             bool
	Key                   string
	Name                  string
	Summary               string
	Version               string
	EntityType            string

	ApplianceHost             string
	ApplianceURL              string
	ApplianceServerThumbprint string
}

// NewUIPlugin Returns a UI Plugin struct with the given target
func NewUIPlugin(target *lib.LoginInfo) *Plugin {
	if target == nil {
		return &Plugin{Target: &lib.LoginInfo{}}
	}
	return &Plugin{Target: target}
}

// NewH5UIPlugin Returns a UI Plugin struct populated defaults for an H5 Client install
func NewH5UIPlugin(target *lib.LoginInfo) *Plugin {
	p := NewUIPlugin(target)
	p.Version = pluginVersion
	p.EntityType = pluginEntityType
	p.Company = pluginCompany
	p.Key = h5ClientPluginKey
	p.Name = h5ClientPluginName
	p.Summary = h5ClientPluginSummary
	p.Configure = true
	p.Insecure = true

	return p
}

// NewFlexUIPlugin Returns a UI Plugin struct populated defaults for an Flex Client install
func NewFlexUIPlugin(target *lib.LoginInfo) *Plugin {
	p := NewUIPlugin(target)
	p.Version = pluginVersion
	p.EntityType = pluginEntityType
	p.Company = pluginCompany
	p.Key = flexClientPluginKey
	p.Name = flexClientPluginName
	p.Summary = flexClientPluginSummary
	p.Configure = true
	p.Insecure = true

	return p
}

func (p *Plugin) Install(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	var err error
	if err = p.processInstallParams(op); err != nil {
		op.Error(err)
		return err
	}
	vCenterVersion := p.Target.Session.Client.ServiceContent.About.Version
	if p.denyInstall(op, vCenterVersion) {
		op.Warnf("Refusing to install Flex plugin on vSphere %s", vCenterVersion)
		return nil
	}

	op.Infof("### Installing UI Plugin against vSphere %s ####", vCenterVersion)
	op.Infof("%+v", p.Target.URL)
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

	pl, err := plugin.NewPluginator(op, p.Target.Session, pInfo)
	if err != nil {
		op.Error(err)
		return err
	}

	reg, err := pl.IsRegistered(pInfo.Key)
	if err != nil {
		op.Error(err)
		return err
	}
	if reg {
		if p.Force {
			op.Info("Removing existing plugin to force install")
			err = pl.Unregister(pInfo.Key)
			if err != nil {
				op.Error(err)
				return err
			}
			op.Info("Removed existing plugin")
		} else {
			msg := fmt.Sprintf("plugin (%s) is already registered", pInfo.Key)
			op.Errorf("Install failed: %s", msg)
			return errors.New(msg)
		}
	}

	op.Info("Installing plugin")
	err = pl.Register()
	if err != nil {
		op.Error(err)
		return err
	}

	reg, err = pl.IsRegistered(pInfo.Key)
	if err != nil {
		op.Error(err)
		return err
	}
	if !reg {
		msg := fmt.Sprintf("post-install check failed to find %s registered", pInfo.Key)
		op.Errorf("Install failed: %s", msg)
		return errors.New(msg)
	}

	op.Info("Installed UI plugin")

	if p.Configure {
		// Configure the OVA vm to be managed by this plugin
		if err = ova.ConfigureManagedByInfo(op, p.Target.Session, pInfo.URL); err != nil {
			op.Error(err)
			return err
		}
	}

	return nil
}

func (p *Plugin) Remove(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	var err error
	if err = p.processRemoveParams(op); err != nil {
		op.Error(err)
		return err
	}

	if p.Force {
		op.Info("Ignoring --force")
	}

	op.Infof("### Removing UI Plugin ####")

	pInfo := &plugin.Info{
		Key: p.Key,
	}

	pl, err := plugin.NewPluginator(op, p.Target.Session, pInfo)
	if err != nil {
		op.Error(err)
		return err
	}
	reg, err := pl.IsRegistered(pInfo.Key)
	if err != nil {
		op.Error(err)
		return err
	}
	if reg {
		op.Infof("Found target plugin: %s", pInfo.Key)
	} else {
		msg := fmt.Sprintf("failed to find target plugin (%s)", pInfo.Key)
		op.Errorf("Remove failed: %s", msg)
		return errors.New(msg)
	}

	op.Info("Removing plugin")
	err = pl.Unregister(pInfo.Key)
	if err != nil {
		op.Error(err)
		return err
	}

	reg, err = pl.IsRegistered(pInfo.Key)
	if err != nil {
		op.Error(err)
		return err
	}
	if reg {
		msg := fmt.Sprintf("post-remove check found %s still registered", pInfo.Key)
		op.Errorf("Remove failed: %s", msg)
		return errors.New(msg)
	}

	op.Info("Removed UI plugin")
	return nil
}

func (p *Plugin) Info(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	var err error
	if err = p.processInfoParams(op); err != nil {
		op.Error(err)
		return err
	}

	pInfo := &plugin.Info{
		Key: p.Key,
	}

	pl, err := plugin.NewPluginator(op, p.Target.Session, pInfo)
	if err != nil {
		op.Error(err)
		return err
	}

	reg, err := pl.GetPlugin(p.Key)
	if err != nil {
		op.Error(err)
		return err
	}
	if reg == nil {
		return errors.Errorf("%s is not registered", p.Key)
	}

	op.Infof("%s is registered", p.Key)
	op.Info("")
	op.Infof("Key: %s", reg.Key)
	op.Infof("Name: %s", reg.Description.GetDescription().Label)
	op.Infof("Summary: %s", reg.Description.GetDescription().Summary)
	op.Infof("Company: %s", reg.Company)
	op.Infof("Version: %s", reg.Version)
	return nil
}

func (p *Plugin) processInstallParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if p.Target.Session == nil {
		cancel, err := p.Target.VerifyLogin(op)
		defer cancel()

		if err != nil {
			op.Error(err)
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
			op.Error(err)
			return errors.Errorf("Cannot generate appliance ip: %s", errors.ErrorStack(err))
		}
		// Fetch the OVF env to get the fileserver port
		ovf, err := lib.UnmarshaledOvfEnv()
		if err != nil {
			op.Error(err)
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
			op.Error(err)
			return errors.Errorf("Error getting thumbprint for %s: %s", p.ApplianceHost, errors.ErrorStack(err))
		}
		p.ApplianceServerThumbprint = cert.ThumbprintSHA1
		op.Debugf("server-thumbprint not specified with HTTPS plugin URL. generated thumbprint: %s", p.ApplianceServerThumbprint)
	}

	return nil
}

func (p *Plugin) processRemoveParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if p.Target.Session == nil {
		cancel, err := p.Target.VerifyLogin(op)
		defer cancel()

		if err != nil {
			op.Error(err)
			return err
		}
	}

	if p.Key == "" {
		return errors.New("key must be specified")
	}

	return nil
}

func (p *Plugin) processInfoParams(op trace.Operation) error {
	defer trace.End(trace.Begin("", op))

	if p.Target.Session == nil {
		cancel, err := p.Target.VerifyLogin(op)
		defer cancel()

		if err != nil {
			op.Error(err)
			return err
		}
	}

	if p.Key == "" {
		return errors.New("key must be specified")
	}
	return nil
}

func (p *Plugin) denyInstall(op trace.Operation, version string) bool {
	vCenterVersion := strings.Split(version, ".")

	if len(vCenterVersion) < 2 {
		op.Debugf("Cannot filter vSphere version (%s) because it is not a semantic version", strings.Join(vCenterVersion, "."))
		return false
	}
	semver := map[string]string{
		"major": vCenterVersion[0],
		"minor": vCenterVersion[1],
	}
	// Deny install if:
	// Plugin is the flex plugin AND
	// -- major version us 6 AND
	// -- -- minor version is greater than Or equal to 7 OR
	// -- major version is greater than or equal to 7
	return p.Key == flexClientPluginKey &&
		((semver["major"] == "6" && semver["minor"] == "7") ||
			(semver["major"] == "6" && strings.Compare(semver["minor"], "7") == 1) ||
			(strings.Compare(semver["major"], "6") == 1))

}
