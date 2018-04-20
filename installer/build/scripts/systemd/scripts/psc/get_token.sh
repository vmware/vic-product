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

umask 0077

# Prepare paths for token files
mkdir -p /etc/vmware/psc/harbor
mkdir -p /etc/vmware/psc/engine
mkdir -p /etc/vmware/psc/admiral

PSC_BINARY="/etc/vmware/admiral/admiral-auth-psc-1.3.2-SNAPSHOT-command.jar"

function getToken() {
  /usr/bin/java -jar ${PSC_BINARY} --command=get-token --configFile="$1" --tokenFile="$2"
}

# Generate token files
getToken /etc/vmware/psc/harbor/psc-config.properties /etc/vmware/psc/harbor/tokens.properties
getToken /etc/vmware/psc/engine/psc-config.properties /etc/vmware/psc/engine/tokens.properties
getToken /etc/vmware/psc/admiral/psc-config.properties /etc/vmware/psc/admiral/tokens.properties

# Put the engine token in guestinfo
/etc/vmware/set_guestinfo.sh -f /etc/vmware/psc/engine/tokens.properties "engine.token"

# Copy harbor token to container mount path
mkdir -p /storage/data/harbor/psc
cp /etc/vmware/psc/harbor/tokens.properties /storage/data/harbor/psc/tokens.properties
chown --recursive 10000:10000 /storage/data/harbor/psc

# Set PSC dir permissions if not set
dirs=("/etc/vmware/psc/admiral" "/etc/vmware/psc/engine" "/etc/vmware/psc/harbor")
files=("psc-config.keystore" "psc-config.properties" "tokens.properties")
for dir in "${dirs[@]}"; do
  while [ ! -d "$dir" ]; do
    echo "Waiting for $dir"
    sleep 1
  done
  for file in "${files[@]}"; do
    perms="$(stat -c %a "$dir/$file")"
    if [ "$perms" != "600" ]; then
      chmod 0600 "$dir/$file"
      echo "set perms for $dir/$file"
    else
      echo "perms ok for $dir/$file"
    fi
    owner="$(stat -c %u:%g "$dir/$file")"
    if [ "$owner" != "10000:10000" ]; then
      chown 10000:10000 "$dir/$file"
      echo "set owner for $dir/$file"
    else
      echo "owner ok for $dir/$file"
    fi
  done
done
