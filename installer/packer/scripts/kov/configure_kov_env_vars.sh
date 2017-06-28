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

data_dir=/data/kov
cert_dir=${data_dir}/cert
cert=${cert_dir}/server.crt
key=${cert_dir}/server.key
vmdk=${data_dir}/base_$(cat /etc/vmware/kov/kovd_revision).vmdk

port="$(ovfenv -k cluster_manager.port)"
mkdir -p /etc/vmware/kov

cat > /etc/vmware/kov/kov_env_vars <<EOF
KOVD_EXPOSED_PORT=${port}
KOVD_KEY_LOCATION=$key
KOVD_CERT_LOCATION=$cert
KOV_VMDK_LOCATION=$vmdk
KOVD_DATA_DIR=$data_dir
EOF
