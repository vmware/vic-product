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

VER :=$(shell git describe --abbrev=0 --tags)

BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PHOTON_ISO := https://storage.googleapis.com/vic-product-ova-build-deps/photon-1.0-62c543d.iso
PHOTON_ISO_SHA1SUM := c4c6cb94c261b162e7dac60fdffa96ddb5836d66

BIN ?= bin

.PHONY: ova-release ova-debug vagrant-local

ovfenv := $(BIN)/ovfenv
vic-ova-ui := $(BIN)/vic-ova-ui
ova-webserver := $(BIN)/ova-webserver
ova-engine-installer := $(BIN)/ova-engine-installer
ovfenv: $(ovfenv)
vic-ova-ui: $(vic-ova-ui)
ova-webserver: $(ova-webserver)
ova-engine-installer: $(ova-engine-installer)

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
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -o ./$@ ./$(dir $<)

$(vic-ova-ui): $(call godeps,ovatools/vic-ova-ui/*.go)
	@echo building vic-ova-ui
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -o ./$@ ./$(dir $<)

$(ova-webserver): $(call godeps,fileserver/*.go)
	@echo building ova-webserver
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -o ./$@ ./$(dir $<)

$(ova-engine-installer): $(call godeps,engine_installer/*.go)
	@echo building ova-engine-installer
	@GOARCH=amd64 GOOS=linux $(TIME) $(GO) build $(RACE) -o ./$@ ./$(dir $<)

ova-release: $(ovfenv) $(vic-ova-ui) $(ova-webserver) $(ova-engine-installer)
	@echo building vic-unified-installer OVA using packer...
	@cd $(BASE_DIR)packer && $(PACKER) build \
			-only=ova-release \
			-var 'iso_sha1sum=$(PHOTON_ISO_SHA1SUM)'\
			-var 'iso_file=$(PHOTON_ISO)'\
			-var 'esx_host=$(PACKER_ESX_HOST)'\
			-var 'remote_username=$(PACKER_USERNAME)'\
			-var 'remote_password=$(PACKER_PASSWORD)'\
			-var 'build_vicengine_revision=$(BUILD_VICENGINE_REVISION)' \
			-var 'build_vicengine_dev_revision=$(BUILD_VICENGINE_DEV_REVISION)' \
			-var 'build_admiral_revision=$(BUILD_ADMIRAL_REVISION)' \
			-var 'build_harbor_revision=$(BUILD_HARBOR_REVISION)' \
			-var 'build_harbor_dev_revision=$(BUILD_HARBOR_DEV_REVISION)' \
			packer-vic.json
	@echo adding proper vic OVF file...
	@cd $(BASE_DIR)packer/vic/vic && $(RM) vic.ovf && $(CP) ../../vic-unified.ovf vic.ovf
	@echo rebuilding OVF manifest...
	@cd $(BASE_DIR)packer/vic/vic && $(RM) vic.mf && $(SHA256SUM) --tag * | $(SED) s/SHA256\ \(/SHA256\(/ > vic.mf
	@echo packaging OVA...
	@$(OVFTOOL) -st=ovf -tt=ova $(BASE_DIR)packer/vic/vic/vic.ovf $(BASE_DIR)$(BIN)/vic-$(VER)-$(REV).ova
	@echo cleaning packer directory...
	@cd $(BASE_DIR)packer && $(RM) -rf vic

ova-debug: $(ovfenv) $(vic-ova-ui) $(ova-webserver) $(ova-engine-installer)
	@echo building vic-unified-installer OVA using packer...
	cd $(BASE_DIR)packer && PACKER_LOG=1 $(PACKER) build \
			-only=ova-release \
			-var 'iso_sha1sum=$(PHOTON_ISO_SHA1SUM)'\
			-var 'iso_file=$(PHOTON_ISO)'\
			-var 'esx_host=$(PACKER_ESX_HOST)'\
			-var 'remote_username=$(PACKER_USERNAME)'\
			-var 'remote_password=$(PACKER_PASSWORD)'\
			-var 'build_vicengine_revision=$(BUILD_VICENGINE_REVISION)' \
			-var 'build_vicengine_dev_revision=$(BUILD_VICENGINE_DEV_REVISION)' \
			-var 'build_admiral_revision=$(BUILD_ADMIRAL_REVISION)' \
			-var 'build_harbor_revision=$(BUILD_HARBOR_REVISION)' \
			-var 'build_harbor_dev_revision=$(BUILD_HARBOR_DEV_REVISION)' \
			--on-error=abort packer-vic.json
	@echo adding proper vic OVF file...
	cd $(BASE_DIR)packer/vic/vic && $(RM) vic.ovf && $(CP) ../../vic-unified.ovf vic.ovf
	@echo rebuilding OVF manifest...
	cd $(BASE_DIR)packer/vic/vic && $(RM) vic.mf && $(SHA256SUM) --tag * | $(SED) s/SHA256\ \(/SHA256\(/ > vic.mf
	@echo packaging OVA...
	$(OVFTOOL) -st=ovf -tt=ova $(BASE_DIR)packer/vic/vic/vic.ovf $(BASE_DIR)$(BIN)/vic-$(VER)-$(REV).ova
	@echo cleaning packer directory...
	cd $(BASE_DIR)packer && $(RM) -rf vic

vagrant-local: $(ovfenv) $(vic-ova-ui) $(ova-webserver) $(ova-engine-installer)
	@echo building vic-unified-installer Vagrant box using packer...
	@cd $(BASE_DIR)packer && $(PACKER) build \
			-only=vagrant-local \
			-var 'iso_sha1sum=$(PHOTON_ISO_SHA1SUM)'\
			-var 'iso_file=$(PHOTON_ISO)'\
			-var 'build_vicengine_revision=$(BUILD_VICENGINE_REVISION)' \
			-var 'build_vicengine_dev_revision=$(BUILD_VICENGINE_DEV_REVISION)' \
			-var 'build_admiral_revision=$(BUILD_ADMIRAL_REVISION)' \
			-var 'build_harbor_revision=$(BUILD_HARBOR_REVISION)' \
			-var 'build_harbor_dev_revision=$(BUILD_HARBOR_DEV_REVISION)' \
			--on-error=abort packer-vic.json

clean:
	@echo removing binaries
	@rm -rf $(BIN)/*
	@echo removing OVA installer files...
	@rm -rf packer/vic
