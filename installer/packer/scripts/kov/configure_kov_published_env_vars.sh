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

# if you made a change on cert_dir, make the same change to CERT_FILES_DIR
# in packer/scripts/kov/configure_kov.sh
# so do following variables
cert_dir=certs
ca_cert=${cert_dir}/ca.crt
admin_cert=${cert_dir}/admin.crt
admin_key=${cert_dir}/admin.key

FILES_DIR="/opt/vmware/fileserver/files"
target_file="env.sh"
mkdir -p ${FILES_DIR}

ip="$(ifconfig eth0 | awk '/inet addr/ {print $2}' | awk -F ":" '{print $2}')"
port="$(ovfenv -k cluster_manager.port)"

cat > ${FILES_DIR}/${target_file} <<EOF
export KOV_CA_CERT=${ca_cert}
export KOV_CLIENT_CERT=${admin_cert}
export KOV_CLIENT_KEY=${admin_key}
export KOV_ENDPOINT="https://${ip}:${port}"
EOF

# KOV_VC_* are provided as literals because ${FILES_DIR} is going to be
# used by users and these variables should be set based on settings on
# user's local environment
cat >> ${FILES_DIR}/${target_file} <<'EOF'
export KOV_VC_ENDPOINT=${KOV_VC_ENDPOINT:?"KOV_VC_ENDPOINT is not set"}
export KOV_VC_USERNAME=${KOV_VC_USERNAME:?"KOV_VC_USERNAME is not set"}
export KOV_VC_PASSWORD=${KOV_VC_PASSWORD:?"KOV_VC_PASSWORD is not set"}
if [ -z "${KOV_VC_ENDPOINT}" ] || [ -z "$(which openssl)" ]; then
  export KOV_VC_THUMBPRINT=${KOV_VC_THUMBPRINT:?"KOV_VC_THUMBPRINT is not set. It will
  be automatically set if KOV_VC_ENDPOINT were set and openssl existed in $PATH"}
else
  export KOV_VC_THUMBPRINT=$(echo -n | openssl s_client -connect "${KOV_VC_ENDPOINT}":443 2>/dev/null | openssl x509 -noout -fingerprint -sha1 | awk -F"=" '{print $2}')
fi
EOF
