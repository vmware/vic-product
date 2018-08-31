// Copyright 2018 VMware, Inc. All Rights Reserved.
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
	"testing"

	"github.com/stretchr/testify/assert"

	"github.com/vmware/vic/pkg/trace"
)

func TestFlexInstallWithBadVersions(t *testing.T) {
	op := trace.NewOperation(context.Background(), "TestFlexInstallWithBadVersions")
	tests := map[string]bool{
		"6.0":   false,
		"6.0.0": false,
		"6.0.1": false,
		"6.5":   false,
		"6.5.0": false,
		"6.5.1": false,
		"6.7":   true,
		"6.7.0": true,
		"6.7.1": true,
		"7.0":   true,
		"7.0.0": true,
		"7.0.1": true,
	}

	p := NewUIPlugin(nil)
	p.Key = flexClientPluginKey
	for k, v := range tests {
		assert.Equal(t, p.denyInstall(op, k), v, "Plugin version %s", k)
	}
}

func TestH5InstallWithAnyVersion(t *testing.T) {
	op := trace.NewOperation(context.Background(), "TestH5InstallWithAnyVersion")
	tests := map[string]bool{
		"6.0":   false,
		"6.0.0": false,
		"6.0.1": false,
		"6.5":   false,
		"6.5.0": false,
		"6.5.1": false,
		"6.7":   false,
		"6.7.0": false,
		"6.7.1": false,
		"7.0":   false,
		"7.0.0": false,
		"7.0.1": false,
	}

	p := NewUIPlugin(nil)
	p.Key = h5ClientPluginKey
	for k, v := range tests {
		assert.Equal(t, p.denyInstall(op, k), v, "Plugin version %s", k)
	}
}
