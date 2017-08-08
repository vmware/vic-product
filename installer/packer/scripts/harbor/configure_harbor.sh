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

data_dir="/data/harbor"
conf_dir="/etc/vmware/harbor"
script_dir="/etc/vmware"
harbor_compose_file="${conf_dir}/docker-compose.yml"

cert_dir="${data_dir}/cert"
flag="${conf_dir}/cert_gen_type"
cfg="${data_dir}/harbor.cfg"

ca_download_dir="${data_dir}/ca_download"
mkdir -p "${cert_dir}"
mkdir -p "${ca_download_dir}"

cert="${cert_dir}/server.crt"
key="${cert_dir}/server.key"
csr="${cert_dir}/server.csr"
ca_cert="${cert_dir}/ca.crt"
ca_key="${cert_dir}/ca.key"
ext="${cert_dir}/extfile.cnf"

MANAGED_KEY="# Managed by configure_harbor.sh"
export LC_ALL="C"

REGISTRY_PORT="$(ovfenv -k registry.port)"
NOTARY_PORT="$(ovfenv -k registry.notary_port)"

rm -rf "${ca_download_dir}"
mkdir -p "${ca_download_dir}"

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

# Format cert file
function formatCert {
  content=$1
  file=$2
  echo "$content" | sed -r 's/(-{5}BEGIN [A-Z ]+-{5})/&\n/g; s/(-{5}END [A-Z ]+-{5})/\n&\n/g' | sed -r 's/.{64}/&\n/g; /^\s*$/d' > "$file"
}

function genCert {
  if [ ! -e $ca_cert ] || [ ! -e $ca_key ]
  then
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout $ca_key \
      -x509 -days 365 -out $ca_cert -subj \
      "/C=US/ST=California/L=Palo Alto/O=VMware, Inc./OU=Containers on vSphere/CN=Self-signed by VMware, Inc."
  fi
  openssl req -newkey rsa:4096 -nodes -sha256 -keyout $key \
    -out $csr -subj \
    "/C=US/ST=California/L=Palo Alto/O=VMware/OU=Containers on vSphere/CN=$hostname"

  echo "Add subjectAltName = IP: $ip_address to certificate"
  echo subjectAltName = IP:"$ip_address" > $ext
  openssl x509 -req -days 365 -in $csr -CA $ca_cert -CAkey $ca_key -CAcreateserial -extfile $ext -out $cert

  echo "self-signed" > $flag
  echo "Copy CA certificate to $ca_download_dir"
  cp $ca_cert $ca_download_dir/
  $script_dir/set_guestinfo.sh -f $ca_cert "harbor.ca"
}

function secure {
  ssl_cert=$(ovfenv -k registry.ssl_cert)
  ssl_cert_key=$(ovfenv -k registry.ssl_cert_key)
  if [ -n "$ssl_cert" ] && [ -n "$ssl_cert_key" ]; then
    echo "ssl_cert and ssl_cert_key are both set, using customized certificate"
    formatCert "$ssl_cert" $cert
    formatCert "$ssl_cert_key" $key
    echo "customized" > $flag
    return
  fi

  if [ ! -e $ca_cert ] || [ ! -e $cert ] || [ ! -e $key ]; then
    echo "CA, Certificate or key file does not exist, will generate a self-signed certificate"
    genCert
    return
  fi

  if [ ! -e $flag ]; then
    echo "The file which records the way generating certificate does not exist, will generate a new self-signed certificate"
    genCert
    return
  fi

  if [ ! "$(cat $flag)" = "self-signed" ]; then
    echo "The way generating certificate changed, will generate a new self-signed certificate"
    genCert
    return
  fi

  cn=$(openssl x509 -noout -subject -in $cert | sed -n '/^subject/s/^.*CN=//p') || true
  if [ "$hostname" !=  "$cn" ]; then
    echo "Common name changed: $cn -> $hostname , will generate a new self-signed certificate"
    genCert
    return
  fi

  ip_in_cert=$(openssl x509 -noout -text -in $cert | sed -n '/IP Address:/s/.*IP Address://p') || true
  if [ "$ip_address" !=  "$ip_in_cert" ]; then
    echo "IP changed: $ip_in_cert -> $ip_address , will generate a new self-signed certificate"
    genCert
    return
  fi

  echo "Use the existing CA, certificate and key file"
  echo "Copy CA certificate to $ca_download_dir"
  cp $ca_cert $ca_download_dir/
}

function detectHostname {
  hostname=$(hostnamectl status --static) || true
  if [ -n "$hostname" ]; then
    if [ "$hostname" = "localhost.localdomain" ]; then
      hostname=""
      return
    fi
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
secure

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
