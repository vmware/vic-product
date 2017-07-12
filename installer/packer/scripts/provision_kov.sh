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

KOV_CONF_DIR="/etc/vmware/kov"
KOV_DATA_DIR="/data/kov"
KOV_ENV_DIR="/usr/lib/systemd/user-environment-generators"
mkdir -p $KOV_CONF_DIR
mkdir -p $KOV_DATA_DIR
mkdir -p $KOV_ENV_DIR

[[ x$BUILD_KOVD_REVISION == "x" ]] && ( echo "Kovd build not set, failing"; exit 1 )
echo $BUILD_KOVD_REVISION > $KOV_CONF_DIR/kovd_revision

set +u
KOVD_FILE="kovd_${BUILD_KOVD_REVISION}"
KOV_VMDK="base_${BUILD_KOVD_REVISION}.vmdk"
KOVD_BUCKET="kovd-releases"
if [ ${BUILD_KOVD_REVISION} = "dev" ]; then
    KOVD_BUCKET="kovd-builds"
fi
KOVD_URL="https://storage.googleapis.com/${KOVD_BUCKET}/kovd/${KOVD_FILE}"
KOV_VMDK_URL="https://storage.googleapis.com/${KOVD_BUCKET}/vmdk/${KOV_VMDK}"
set -u

echo "Downloading Kovd ${KOVD_FILE}: ${KOVD_URL}"
curl -o /usr/bin/kovd ${KOVD_URL}
chmod +x /usr/bin/kovd
echo "Downloading Kov vmdk ${KOV_VMDK}: ${KOV_VMDK_URL}"
# download vmdk to kov_conf_dir firstly
curl -o ${KOV_CONF_DIR}/${KOV_VMDK} ${KOV_VMDK_URL}

# kovd assumes kubectl exists
# Provision kubectl
ver=$(curl -sL https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo "Downloading kubectl $ver"

curl -o ${KOV_DATA_DIR}/kubectl -L'#' https://storage.googleapis.com/kubernetes-release/release/$ver/bin/linux/amd64/kubectl
cp ${KOV_DATA_DIR}/kubectl /usr/bin/kubectl
chmod +x /usr/bin/kubectl
