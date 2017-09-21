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
PACKER ?= packer
OVFTOOL ?= ovftool
SHA256SUM ?= sha256sum
SED ?= sed
RM ?= rm
CP ?= cp
OS := $(shell uname | tr '[:upper:]' '[:lower:]')

REV :=$(shell git describe --tags)

BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PHOTON_ISO := https://storage.googleapis.com/vic-product-ova-build-deps/photon-1.0-62c543d.iso
PHOTON_ISO_SHA1SUM := c4c6cb94c261b162e7dac60fdffa96ddb5836d66

BIN ?= bin

export GOPATH ?= $(shell echo $(CURDIR) | sed -e 's,/src/.*,,')
GVT ?= $(GOPATH)/bin/gvt$(BIN_ARCH)
GAS ?= $(GOPATH)/bin/gas$(BIN_ARCH)

.PHONY: ova-release ova-debug vagrant-local gas packerless-ova upload-packerless-ova

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
	@echo --------------------------------------------------
	@echo preparing for ova build...
	@$(BASE_DIR)build/cleanup.sh
	@echo --------------------------------------------------
	@echo caching build dependencies...
	@mkdir -p $(BASE_DIR)build/baseimage/{bin,cache}
	@$(BASE_DIR)build/cache.sh
	@echo --------------------------------------------------
	@echo building vm template...
	@docker pull vmware/photon
	@docker run --rm -v /dev:/dev --privileged -v $(BASE_DIR):/work -w /work \
		-e BUILD_HARBOR_FILE=${BUILD_HARBOR_FILE} \
		-e BUILD_VICENGINE_FILE=${BUILD_VICENGINE_FILE} \
		-e BUILD_ADMIRAL_REVISION=${BUILD_ADMIRAL_REVISION} \
		-e BUILD_ADMIRAL_RELEASE=${BUILD_ADMIRAL_RELEASE} \
		-e BUILD_OVA_REVISION=${BUILD_OVA_REVISION} \
		-e BUILD_DCHPHOTON_VERSION=${BUILD_DCHPHOTON_VERSION} \
		-e DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER} \
		-e TERM vmware/photon ./build/baseimage/stage.sh
	@echo --------------------------------------------------
	@echo packaging OVA...
	@cp $(BASE_DIR)build/vic-unified.ovf $(BASE_DIR)build/baseimage/bin/vic-$(REV).ovf
	@cd $(BASE_DIR)build/baseimage/bin/ && $(SED) -i -e s~--version--~$(BUILD_OVA_REVISION)~ vic-$(REV).ovf
ifeq ($(OS),darwin)
	@echo rebuilding OVF manifest in darwin...
	@cd$(BASE_DIR)build/baseimage/bin/ && shasum -a 256 * | $(AWK) '{print "SHA256("$$2") = "$$1}' > vic-$(REV).mf
else
	@echo rebuilding OVF manifest in linux...
	@cd $(BASE_DIR)build/baseimage/bin/ && $(SHA256SUM) --tag * | $(SED) s/SHA256\ \(/SHA256\(/ > vic-$(REV).mf
endif
	@cd $(BASE_DIR)build/baseimage/bin/ && tar -cvf $(BASE_DIR)bin/vic-$(REV).ova vic-$(REV).ovf vic-$(REV).mf *.vmdk
	@echo --------------------------------------------------
	@echo cleaning up...
	@$(BASE_DIR)build/cleanup.sh

ova-build: $(ova)
	@echo uploading vm template
	@gsutil cp -va public-read $(BASE_DIR)bin/vic-$(REV).ova gs://vic-product-ova-builds

ova-release: $(ova)
	@echo uploading vm template
	@gsutil cp -va public-read $(BASE_DIR)bin/vic-$(REV).ova gs://vic-product-ova-releases

# utility targets
$(GAS): vendor/manifest
	@echo building $(GAS)...
	@$(GO) build $(RACE) -o $(GAS) ./vendor/github.com/GoASTScanner/gas

$(GVT): vendor/manifest
	@echo building $(GVT)...
	@$(GO) build $(RACE) -o $(GVT) ./vendor/github.com/FiloSottile/gvt

vendor: $(GVT)
	  @echo restoring vendor
		  $(GVT) restore

gas: $(GAS)
	@echo running go AST tool
	@$(GAS) -quiet engine_installer/... fileserver/... lib/... ovatools/... pkg/... tagvm/... toolbox/... 2> /dev/null

clean:
	@echo removing binaries
	@rm -rf $(BIN)/*
	@echo removing OVA installer files...
	@rm -rf $(BASE_DIR)build/baseimage/cache
	@$(BASE_DIR)build/cleanup.sh
