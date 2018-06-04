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

package plugin

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/vmware/govmomi/object"
	"github.com/vmware/govmomi/vim25/types"
	"github.com/vmware/vic/pkg/trace"
	"github.com/vmware/vic/pkg/vsphere/session"
)

type Info struct {
	*ManagedEntityInfo

	Company               string
	Key                   string
	Name                  string
	ServerThumbprint      string
	ShowInSolutionManager bool
	Summary               string
	Type                  string
	URL                   string
	Version               string
}

type ManagedEntityInfo struct {
	Description  string
	IconURL      string
	SmallIconURL string
	EntityType   string
}

type Pluginator struct {
	Session          *session.Session
	ExtensionManager *object.ExtensionManager
	Context          context.Context

	info *Info
	op   trace.Operation
}

func NewPluginator(op trace.Operation, sess *session.Session, i *Info) (*Pluginator, error) {
	defer trace.End(trace.Begin(""))

	p := &Pluginator{
		Session: sess,
		info:    i,
		op:      op,
	}
	p.Context = op

	err := p.connect()
	if err != nil {
		return nil, err
	}

	return p, nil
}

func (p *Pluginator) connect() error {
	defer trace.End(trace.Begin(""))

	em, err := object.GetExtensionManager(p.Session.Client.Client)
	if err != nil {
		return fmt.Errorf("failed to get extension manager: %s", err)
	}
	p.ExtensionManager = em

	return nil
}

// Register installs an extension to the target
func (p *Pluginator) Register() error {
	defer trace.End(trace.Begin(""))
	var err error

	desc := types.Description{
		Label:   p.info.Name,
		Summary: p.info.Summary,
	}

	e := types.Extension{
		Key:         p.info.Key,
		Version:     p.info.Version,
		Company:     p.info.Company,
		Description: &desc,
	}

	if p.info.ManagedEntityInfo != nil {
		e.Type = p.info.EntityType
	}

	eci := types.ExtensionClientInfo{
		Version:     p.info.Version,
		Company:     p.info.Company,
		Description: &desc,
		Type:        p.info.Type,
		Url:         p.info.URL,
	}
	e.Client = append(e.Client, eci)

	d := types.KeyValue{
		Key:   "name",
		Value: p.info.Name,
	}

	eri := types.ExtensionResourceInfo{
		Locale: "en_US",
		Module: "name",
	}

	if p.info.ManagedEntityInfo != nil {
		mei := types.ExtManagedEntityInfo{
			Description: p.info.ManagedEntityInfo.Description,
			Type:        p.info.ManagedEntityInfo.EntityType,
		}
		e.ManagedEntityInfo = append(e.ManagedEntityInfo, mei)
	}

	eri.Data = append(eri.Data, d)

	e.ResourceList = append(e.ResourceList, eri)

	// HTTPS requires extension server info
	if strings.HasPrefix(strings.ToLower(p.info.URL), "https://") {
		esi := types.ExtensionServerInfo{
			Url:              p.info.URL,
			Description:      &desc,
			Company:          p.info.Company,
			Type:             "HTTPS",
			AdminEmail:       []string{"noreply@vmware.com"},
			ServerThumbprint: p.info.ServerThumbprint,
		}
		e.Server = append(e.Server, esi)
	}

	e.ShownInSolutionManager = &p.info.ShowInSolutionManager

	e.LastHeartbeatTime = time.Now().UTC()

	err = p.ExtensionManager.Register(p.Context, e)
	if err != nil {
		return err
	}

	return nil
}

// Unregister removes an extension from the target
func (p *Pluginator) Unregister(key string) error {
	defer trace.End(trace.Begin(""))

	if err := p.ExtensionManager.Unregister(p.Context, key); err != nil {
		return err
	}
	return nil
}

// IsRegistered checks for presence of an extension on the target
func (p *Pluginator) IsRegistered(key string) (bool, error) {
	defer trace.End(trace.Begin(""))

	e, err := p.ExtensionManager.Find(p.Context, key)
	if err != nil {
		return false, err
	}
	if e != nil {
		p.op.Debugf("%q is registered", key)
		return true, nil
	}
	p.op.Debugf("%q is not registered", key)
	return false, nil
}

// IsRegistered checks for presence of an extension on the target
func (p *Pluginator) GetPlugin(key string) (*types.Extension, error) {
	defer trace.End(trace.Begin(""))

	return p.ExtensionManager.Find(p.Context, key)
}
