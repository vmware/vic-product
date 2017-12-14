#!/usr/bin/env bash
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

data_dir="/storage/data/admiral"
script_dir="/etc/vmware"
admiral_psc_dir="/etc/vmware/psc/admiral"
admiral_start_script="/etc/vmware/admiral/start_admiral.sh"
admiral_add_default_users_script="/etc/vmware/admiral/add_default_users.sh"

ca_download_dir="${data_dir}/ca_download"
rm -rf "${ca_download_dir}"
mkdir -p "${ca_download_dir}"

log_dir="/storage/log/admiral"
mkdir -p "${log_dir}"

config_dir="$data_dir/configs"
mkdir -p "$config_dir"

# From vic-appliance-tls
appliance_jks="/storage/data/certs/trustedcertificates.jks"
appliance_tls_cert="/storage/data/certs/server.crt"
appliance_tls_key="/storage/data/certs/server.key"
appliance_ca_cert="/storage/data/certs/ca.crt"


# Configure attr in script
function configureScript {
  script_name=$1
  cfg_key=$2
  cfg_value=$3

  if [ -n "$cfg_key" ]; then
    cfg_value=$(echo "$cfg_value" | sed -r -e 's%[\/&%]%\\&%g')
    sed -i -r "s%#?$cfg_key\s*=\s*.*%$cfg_key=$cfg_value%" $script_name
  fi
}


# put admiral endpoint in guestinfo
$script_dir/set_guestinfo.sh admiral.endpoint https://"${IP_ADDRESS}":"${ADMIRAL_PORT}"

if [ "${HOSTNAME}" != "${IP_ADDRESS}" ]; then
  configureScript $admiral_start_script "hostname" "${HOSTNAME}"
fi

configureScript $admiral_start_script ADMIRAL_DATA_LOCATION $data_dir
configureScript $admiral_start_script ADMIRAL_EXPOSED_PORT "${ADMIRAL_PORT}"
configureScript $admiral_start_script OVA_VM_IP "${HOSTNAME}"

configureScript $admiral_add_default_users_script ADMIRAL_DATA_LOCATION $data_dir
configureScript $admiral_add_default_users_script ADMIRAL_EXPOSED_PORT "${ADMIRAL_PORT}"
configureScript $admiral_add_default_users_script OVA_VM_IP "${HOSTNAME}"

iptables -w -A INPUT -j ACCEPT -p tcp --dport "${ADMIRAL_PORT}"

touch $data_dir/custom.conf

# Configure the integration URL
echo "harbor.tab.url=https://${HOSTNAME}:${REGISTRY_PORT}" > $data_dir/custom.conf

# Copy files needed by Admiral into one directory
cp $appliance_jks $config_dir
cp $appliance_tls_key $config_dir
cp $appliance_tls_cert $config_dir
cp $data_dir/custom.conf $config_dir/config.properties
cp $admiral_psc_dir/psc-config.keystore $config_dir
cp $admiral_psc_dir/psc-config.properties $config_dir

echo "Copying CA certificate to $ca_download_dir"
cp $appliance_ca_cert $ca_download_dir/
$script_dir/set_guestinfo.sh -f $appliance_ca_cert "admiral.ca"

# Change Admiral's keystore.file value to point to mounted path in container
sed -i "/\b\(keystore.file\)\b/d" $config_dir/psc-config.properties
echo "keystore.file=/configs/psc-config.keystore" >> $config_dir/psc-config.properties

# Set access for UID 10000 used by Admiral container
chown -R 10000:10000 $data_dir
chown -R 10000:10000 $log_dir

echo "Finished Admiral configuration"
