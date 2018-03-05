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

ENV_FILE="/etc/vmware/environment"

TLS_CERT="$(ovfenv -k appliance.tls_cert)"
TLS_PRIVATE_KEY="$(ovfenv -k appliance.tls_cert_key)"
TLS_CA_CERT="$(ovfenv -k appliance.ca_cert)"
ADMIRAL_PORT="$(ovfenv -k management_portal.port)"
REGISTRY_PORT="$(ovfenv -k registry.port)"
NOTARY_PORT="$(ovfenv -k registry.notary_port)"
FILESERVER_PORT="$(ovfenv -k appliance.config_port)"
HOSTNAME=""
IP_ADDRESS=""

function detectHostname {
  HOSTNAME=$(hostnamectl status --static) || true
  if [ -n "$HOSTNAME" ]; then
    echo "Using hostname from 'hostnamectl status --static': $HOSTNAME"
    return
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
  echo "TLS_CERT=${TLS_CERT}";
  echo "TLS_PRIVATE_KEY=${TLS_PRIVATE_KEY}";
  echo "TLS_CA_CERT=${TLS_CA_CERT}";
  echo "ADMIRAL_PORT=${ADMIRAL_PORT}";
  echo "REGISTRY_PORT=${REGISTRY_PORT}";
  echo "NOTARY_PORT=${NOTARY_PORT}";
  echo "FILESERVER_PORT=${FILESERVER_PORT}";
  echo "VIC_MACHINE_SERVER_PORT=8443";
  echo "APPLIANCE_SERVICE_UID=10000";
  echo "HOSTNAME=${HOSTNAME}";
  echo "IP_ADDRESS=${IP_ADDRESS}";
} > ${ENV_FILE}
