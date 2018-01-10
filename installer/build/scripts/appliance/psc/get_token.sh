#!/usr/bin/bash
# Copyright 2017 VMware, Inc. All Rights Reserved.
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
set -euf -o pipefail

# Prepare paths for token files
mkdir -p /etc/vmware/psc/harbor
mkdir -p /etc/vmware/psc/engine
mkdir -p /etc/vmware/psc/admiral

version=$(grep "version" /etc/vmware/psc/admiral/psc-config.properties | awk -F= '{print $2}')

# Generate token files
/usr/bin/java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar --command=get-token --version=$version --configFile=/etc/vmware/psc/harbor/psc-config.properties --tokenFile=/etc/vmware/psc/harbor/tokens.properties
/usr/bin/java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar --command=get-token --version=$version --configFile=/etc/vmware/psc/engine/psc-config.properties --tokenFile=/etc/vmware/psc/engine/tokens.properties
/usr/bin/java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar --command=get-token --version=$version --configFile=/etc/vmware/psc/admiral/psc-config.properties --tokenFile=/etc/vmware/psc/admiral/tokens.properties

# Put the engine token in guestinfo
/etc/vmware/set_guestinfo.sh -f /etc/vmware/psc/engine/tokens.properties "engine.token"

# Copy harbor token to container mount path
mkdir -p /storage/data/harbor/psc
cp /etc/vmware/psc/harbor/tokens.properties /storage/data/harbor/psc/tokens.properties