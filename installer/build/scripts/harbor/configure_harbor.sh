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

umask 077

data_dir="/storage/data/harbor"
conf_dir="/etc/vmware/harbor"
harbor_compose_file="${conf_dir}/docker-compose.yml"

cfg="${data_dir}/harbor.cfg"

# Copy CA cert to be downloaded from UI
ca_download_dir="${data_dir}/ca_download"
rm -rf "${ca_download_dir}"
mkdir -p "${ca_download_dir}"
ca_cert="/storage/data/admiral/cert/ca.crt"
cp ${ca_cert} ${ca_download_dir}


cert_dir="/storage/data/admiral/cert"
cert="${cert_dir}/server.crt"
key="${cert_dir}/server.key"

MANAGED_KEY="# Managed by configure_harbor.sh"
export LC_ALL="C"

REGISTRY_PORT="$(ovfenv -k registry.port)"
NOTARY_PORT="$(ovfenv -k registry.notary_port)"

# Configure attr in harbor.cfg
function configureHarborCfg {
  local cfg_key=$1
  local cfg_value=$2
  local managed="${3:-false}"
  local line
  line=$(sed -n "/^$cfg_key\s*=/p" $cfg)

  if [ -z "$line" ]; then
    echo "Key not found: $cfg_key"
    return
  fi
  if [ -n "$cfg_key" ]; then
    cfg_value=$(echo "$cfg_value" | sed -r -e 's%[\/&%]%\\&%g')
    if [ "$managed" = true ]; then
      echo "Setting managed key $cfg_key"
      sed -i -r "s/^$cfg_key\s*=.*/${MANAGED_KEY}\n$cfg_key = $cfg_value/g" $cfg
    else
      echo "Setting $cfg_key"
      sed -i -r "s%#?$cfg_key\s*=\s*.*%$cfg_key = $cfg_value%" $cfg
    fi
  fi
}

# Configure attr only once in harbor.cfg
function configureHarborCfgOnce {
  local cfg_key=$1
  local cfg_value="$2"
  local prev_line
  prev_line=$(sed -n "/^$cfg_key\s*=/{x;p;d;}; x" $cfg)

  if [[ $prev_line != *"${MANAGED_KEY}"* ]]; then
    configureHarborCfg "$cfg_key" "$cfg_value" true
  else
    echo "Skipping existing managed key $cfg_key"
  fi
}

function detectHostname {
  hostname=$(hostnamectl status --static) || true
  if [ -n "$hostname" ]; then
    echo "Get hostname from command 'hostnamectl status --static': $hostname"
    return
  fi
}

# Generate random password
function genPass {
  openssl rand -base64 32 | shasum -a 256 | head -c 32 ; echo
}

function setPortInYAML {
FILE="$1" HPORT="$2" NPORT="$3" python - <<END
import yaml, os
harbor_port = os.environ['HPORT']
notary_port = os.environ['NPORT']
file = os.environ['FILE']
f = open(file, "r+")
dataMap = yaml.safe_load(f)
newports = ['{0}:443'.format(harbor_port),'{0}:4443'.format(notary_port)]
dataMap["services"]["proxy"]["ports"] = newports
f.seek(0)
yaml.dump(dataMap, f, default_flow_style=False)
f.truncate()
f.close()
END
}

hostname=""
ip_address=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

# Modify hostname
detectHostname
if [[ x$hostname != "x" ]]; then
  echo "Hostname: ${hostname}"
else
  echo "Hostname is null, set it to IP"
  hostname=${ip_address}
fi

# Check permissions on config file
if [ "$(stat -c "%a" "$cfg")" != "600" ]; then
  echo "Permissions on $cfg must be 600"
  exit 1
fi

if [ "${REGISTRY_PORT}" == "443" ] || [ "${REGISTRY_PORT}" == "80" ]; then
  configureHarborCfg "hostname" "${hostname}"
else
  configureHarborCfg "hostname" "${hostname}":"${REGISTRY_PORT}"
fi

configureHarborCfg ui_url_protocol https

configureHarborCfg ssl_cert $cert
configureHarborCfg ssl_cert_key $key
configureHarborCfg secretkey_path $data_dir

# Set MySQL and Clair DB passwords on first boot
configureHarborCfgOnce db_password "$(genPass)"
configureHarborCfgOnce clair_db_password "$(genPass)"

setPortInYAML $harbor_compose_file "${REGISTRY_PORT}" "${NOTARY_PORT}"

# Configure the integration URL
configureHarborCfg admiral_url https://"${hostname}":"$(ovfenv -k management_portal.port)"

# Open port for Harbor
iptables -w -A INPUT -j ACCEPT -p tcp --dport "${REGISTRY_PORT}"

# Open port for Notary
iptables -w -A INPUT -j ACCEPT -p tcp --dport "${NOTARY_PORT}"

# Start on startup
echo "Enable harbor startup"
systemctl enable harbor_startup.service
systemctl enable harbor.service

# cleanup common/config directory in preparation for running the harbor "prepare" script
rm -rf /etc/vmware/harbor/common/config
