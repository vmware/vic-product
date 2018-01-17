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

TLS_CERT="$(ovfenv -k management_portal.ssl_cert)"
TLS_PRIVATE_KEY="$(ovfenv -k management_portal.ssl_cert_key)"
TLS_CA_CERT="$(ovfenv -k management_portal.ca_cert)"
ADMIRAL_PORT="$(ovfenv -k management_portal.port)"
REGISTRY_PORT="$(ovfenv -k registry.port)"
NOTARY_PORT="$(ovfenv -k registry.notary_port)"
FILESERVER_PORT="$(ovfenv -k fileserver.port)"

ENV_FILE="/etc/vmware/environment"

{
  echo "TLS_CERT=${TLS_CERT}";
  echo "TLS_PRIVATE_KEY=${TLS_PRIVATE_KEY}";
  echo "TLS_CA_CERT=${TLS_CA_CERT}";
  echo "ADMIRAL_PORT=${ADMIRAL_PORT}";
  echo "REGISTRY_PORT=${REGISTRY_PORT}";
  echo "NOTARY_PORT=${NOTARY_PORT}";
  echo "FILESERVER_PORT=${FILESERVER_PORT}";
  echo "VIC_MACHINE_SERVER_PORT=8443";
} > ${ENV_FILE}
