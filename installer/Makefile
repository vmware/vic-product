# Copyright 2016 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL=/bin/bash

GO ?= go
SED ?= sed
RM ?= rm
OS := $(shell uname | tr '[:upper:]' '[:lower:]')

BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BIN ?= bin

export GOPATH ?= $(shell echo $(CURDIR) | sed -e 's,/src/.*,,')
DEP ?= $(GOPATH)/bin/dep$(BIN_ARCH)
GAS ?= $(GOPATH)/bin/gas$(BIN_ARCH)

.PHONY: gas ova

LDFLAGS := $(shell BUILD_NUMBER=${BUILD_NUMBER} $(BASE_DIR)/scripts/version-linker-flags.sh)

ovfenv := $(BIN)/ovfenv
vic-ova-ui := $(BIN)/vic-ova-ui
ova-webserver := $(BIN)/ova-webserver
ova-engine-installer := $(BIN)/ova-engine-installer
toolbox := $(BIN)/toolbox
rpctool := $(BIN)/rpctool
gas: $(GAS)
ovfenv: $(ovfenv)
vic-ova-ui: $(vic-ova-ui)
ova-webserver: $(ova-webserver)
ova-engine-installer: $(ova-engine-installer)
toolbox: $(toolbox)
rpctool: $(rpctool)

# Generate Go package dependency set, skipping if the only targets specified are clean and/or distclean
# Caches dependencies to speed repeated calls
define godeps
	$(call assert,$(call gmsl_compatible,1 1 7), Wrong GMSL version) \
	$(if $(filter-out clean distclean mrrobot mark sincemark .DEFAULT,$(MAKECMDGOALS)), \
		$(if $(call defined,dep_cache,$(dir $1)),,$(info Generating dependency set for $(dir $1))) \
		$(or \
			$(if $(call defined,dep_cache,$(dir $1)), $(info Using cached Go dependencies) $(wildcard $1) $(call get,dep_cache,$(dir $1))),
			$(call set,dep_cache,$(dir $1),$(shell $(BASE_DIR)scripts/go-deps.sh $(dir $1) $(MAKEFLAGS))),
			$(info Cached Go dependency for $(dir $1): $(call get,dep_cache,$(dir $1))),
			$(wildcard $1) $(call get,dep_cache,$(dir $1))
		) \
	)
endef

$(ovfenv): $(call godeps,ovatools/ovfenv/*.go)
	@echo building ovfenv linux...
	@echo build $(dir $<)
	@echo output $@
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -ldflags "$(LDFLAGS)" -o ./$@ ./$(dir $<)

$(vic-ova-ui): $(call godeps,ovatools/vic-ova-ui/*.go)
	@echo building vic-ova-ui
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -ldflags "$(LDFLAGS)" -o ./$@ ./$(dir $<)

$(ova-webserver): $(call godeps,fileserver/*.go)
	@echo building ova-webserver
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -ldflags "$(LDFLAGS)" -o ./$@ ./$(dir $<)

$(ova-engine-installer): $(call godeps,engine_installer/*.go)
	@echo building ova-engine-installer
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -ldflags "$(LDFLAGS)" -o ./$@ ./$(dir $<)

$(toolbox): $(call godeps,toolbox/*.go)
	@echo building toolbox
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -ldflags "$(LDFLAGS)" -o ./$@ ./$(dir $<)

$(rpctool): $(call godeps,ovatools/rpctool/*.go)
	@echo building rpctool
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -ldflags "$(LDFLAGS)" -o ./$@ ./$(dir $<)

ova: gas $(ovfenv) $(vic-ova-ui) $(ova-webserver) $(ova-engine-installer) $(toolbox) $(rpctool)

# utility targets
$(GAS): Gopkg.lock
	@echo building $(GAS)...
	@$(GO) build $(RACE) -o $(GAS) ./vendor/github.com/GoASTScanner/gas

$(DEP): Gopkg.lock
	@echo building $(DEP)...
	@$(GO) build $(RACE) -o $(DEP) ./vendor/github.com/golang/dep/cmd/dep

vendor: $(DEP)
	@echo restoring vendor
	$(DEP) ensure

gas: $(GAS)
	@echo running go AST tool
	@$(GAS) -quiet engine_installer/... fileserver/... lib/... ovatools/... pkg/... tagvm/... toolbox/... 2> /dev/null

clean:
	@echo removing binaries
	@rm -rf $(BIN)/*
	@echo removing OVA installer files...
	@rm -rf $(BASE_DIR)build/baseimage/cache
	@rm -f $(BASE_DIR)build/baseimage/*.img
	@rm -f build/baseimage/root/installer.env
	@$(BASE_DIR)build/cleanup.sh
