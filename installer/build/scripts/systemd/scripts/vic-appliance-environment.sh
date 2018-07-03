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

declare -r mask="*******"

umask 077

ENV_FILE="/etc/vmware/environment"

# Keep as one string, formatted in vic-appliance-tls
APPLIANCE_TLS_CERT="$(ovfenv -k appliance.tls_cert | sed -E ':a;N;$!ba;s/\r{0,1}\n//g')"
APPLIANCE_TLS_PRIVATE_KEY="$(ovfenv -k appliance.tls_cert_key | sed -E ':a;N;$!ba;s/\r{0,1}\n//g')"
APPLIANCE_TLS_CA_CERT="$(ovfenv -k appliance.ca_cert | sed -E ':a;N;$!ba;s/\r{0,1}\n//g')"

ADMIRAL_PORT="$(ovfenv -k management_portal.management_portal_port)"
REGISTRY_PORT="$(ovfenv -k registry.registry_port)"
NOTARY_PORT="$(ovfenv -k registry.notary_port)"
FILESERVER_PORT="$(ovfenv -k appliance.config_port)"
HOSTNAME=""
IP_ADDRESS=""
DEFAULT_USERS_CREATE_DEF_USERS="$(ovfenv -k default_users.create_def_users)"
DEFAULT_USERS_DEF_USER_PREFIX="$(ovfenv -k default_users.def_user_prefix)"
DEFAULT_USERS_DEF_USER_PASSWORD="$(ovfenv -k default_users.def_user_password)"
REGISTRY_GC_ENABLED="$(ovfenv --key registry.gc_enabled)"

# TODO split into separate unit to run before ovf-network and network-online
APPLIANCE_PERMIT_ROOT_LOGIN="$(ovfenv --key appliance.permit_root_login)"
NETWORK_FQDN="$(ovfenv --key network.fqdn)"
NETWORK_IP0="$(ovfenv --key network.ip0)"
NETWORK_NETMASK0="$(ovfenv --key network.netmask0)"
NETWORK_GATEWAY="$(ovfenv --key network.gateway)"
NETWORK_DNS="$(ovfenv --key network.DNS | sed 's/,/ /g' | tr -s ' ')"
NETWORK_SEARCHPATH="$(ovfenv --key network.searchpath)"

function detectHostname() {
  HOSTNAME=$(hostnamectl status --static) || true
  if [ -n "$HOSTNAME" ]; then
    echo "Using hostname from 'hostnamectl status --static': $HOSTNAME"
    return
  fi
}

function firstboot() {
  set +e
  local tmp
  tmp="$(ovfenv --key appliance.root_pwd)"
  if [[ "$tmp" == "$mask" ]]; then
    return
  fi

  echo "root:$tmp" | chpasswd
  # Reset password expiration to 90 days by default
  chage -d $(date +"%Y-%m-%d") -m 0 -M 90 root
  set -e
}

function clearPrivate() {
  # We then obscure the root password, if the VM is reconfigured with another
  # password after deployment, we don't act on it and keep obscuring it.
  if [[ "$(ovfenv --key appliance.root_pwd)" != "$mask" ]]; then
    ovfenv --key appliance.root_pwd --set "$mask"
  fi
}

# Wait for IP addr to show up
retry=45
while [ $retry -gt 0 ]; do
  IP_ADDRESS=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')
  if [ -n "$IP_ADDRESS" ]; then
    break
  fi
  let retry=retry-1
  echo "IP address is null, retrying"
  sleep 1
done

detectHostname

# Modify hostname
if [ -z "$HOSTNAME" ]; then
  echo "Hostname is null, using IP"
  HOSTNAME=${IP_ADDRESS}
fi
echo "Using hostname: ${HOSTNAME}"


{
  echo "VIC_MACHINE_SERVER_PORT=8443";
  echo "APPLIANCE_SERVICE_UID=10000";
  echo "HOSTNAME=${HOSTNAME}";
  echo "IP_ADDRESS=${IP_ADDRESS}";
  echo "ADMIRAL_PORT=${ADMIRAL_PORT}";
  echo "REGISTRY_PORT=${REGISTRY_PORT}";
  echo "NOTARY_PORT=${NOTARY_PORT}";
  echo "FILESERVER_PORT=${FILESERVER_PORT}";
  echo "APPLIANCE_TLS_CERT=${APPLIANCE_TLS_CERT}";
  echo "APPLIANCE_TLS_PRIVATE_KEY=${APPLIANCE_TLS_PRIVATE_KEY}";
  echo "APPLIANCE_TLS_CA_CERT=${APPLIANCE_TLS_CA_CERT}";
  echo "DEFAULT_USERS_CREATE_DEF_USERS=${DEFAULT_USERS_CREATE_DEF_USERS}";
  echo "DEFAULT_USERS_DEF_USER_PREFIX=${DEFAULT_USERS_DEF_USER_PREFIX}";
  echo "DEFAULT_USERS_DEF_USER_PASSWORD=${DEFAULT_USERS_DEF_USER_PASSWORD}";
  echo "REGISTRY_GC_ENABLED=${REGISTRY_GC_ENABLED}";
  echo "APPLIANCE_PERMIT_ROOT_LOGIN=${APPLIANCE_PERMIT_ROOT_LOGIN}";
  echo "NETWORK_FQDN=${NETWORK_FQDN}";
  echo "NETWORK_IP0=${NETWORK_IP0}";
  echo "NETWORK_NETMASK0=${NETWORK_NETMASK0}";
  echo "NETWORK_GATEWAY=${NETWORK_GATEWAY}";
  echo "NETWORK_DNS=${NETWORK_DNS}";
  echo "NETWORK_SEARCHPATH=${NETWORK_SEARCHPATH}";
} > ${ENV_FILE}

# Only run on first boot
if [[ ! -f /etc/vmware/firstboot ]]; then
  firstboot
fi
# Remove private values from ovfenv
clearPrivate
