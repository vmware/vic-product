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

ca_download_dir="${data_dir}/ca_download"
rm -rf "${ca_download_dir}"
mkdir -p "${ca_download_dir}"

# From vic-appliance-tls
appliance_tls_cert="/storage/data/certs/server.crt"
appliance_tls_key="/storage/data/certs/server.key"
appliance_ca_cert="/storage/data/certs/ca.crt"


# Configure attr in harbor.cfg
MANAGED_KEY="# Managed by configure_harbor.sh"
export LC_ALL="C"
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


# Check permissions on config file
if [ "$(stat -c "%a" "$cfg")" != "600" ]; then
  echo "Permissions on $cfg must be 600"
  exit 1
fi

echo "Copying CA certificate to ${ca_download_dir}"
cp ${appliance_ca_cert} ${ca_download_dir}
chown --recursive 10000:10000 ${ca_download_dir}

if [ "${REGISTRY_PORT}" == "443" ] || [ "${REGISTRY_PORT}" == "80" ]; then
  configureHarborCfg "hostname" "${HOSTNAME}"
else
  configureHarborCfg "hostname" "${HOSTNAME}":"${REGISTRY_PORT}"
fi

configureHarborCfg ui_url_protocol https

configureHarborCfg ssl_cert $appliance_tls_cert
configureHarborCfg ssl_cert_key $appliance_tls_key
configureHarborCfg secretkey_path $data_dir

# Set Harbor DB and Clair DB passwords on first boot
random_pwd=$(genPass)
configureHarborCfgOnce db_password "$random_pwd"
configureHarborCfgOnce clair_db_password "$random_pwd"

setPortInYAML $harbor_compose_file "${REGISTRY_PORT}" "${NOTARY_PORT}"

# Configure the integration URL
configureHarborCfg admiral_url https://"${HOSTNAME}":"${ADMIRAL_PORT}"

# Open port for Harbor
iptables -w -A INPUT -j ACCEPT -p tcp --dport "${REGISTRY_PORT}"

# Open port for Notary
iptables -w -A INPUT -j ACCEPT -p tcp --dport "${NOTARY_PORT}"

# cleanup common/config directory in preparation for running the harbor "prepare" script
rm -rf /etc/vmware/harbor/common/config

echo "Finished Harbor configuration"
