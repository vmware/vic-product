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

FILES_DIR="/opt/vmware/fileserver/files"

mkdir -p /etc/vmware/fileserver  # Fileserver config scripts
mkdir -p ${FILES_DIR}            # Files to serve

if [ -z "${BUILD_VICENGINE_REVISION}" ]; then
  echo "VIC Engine build must be set"
  exit 1
fi

cd /var/tmp
VIC_ENGINE_FILE=""
VIC_ENGINE_URL=""

# Use file if specified, otherwise download
set +u
if [ -n "${BUILD_VICENGINE_FILE}" ]; then
  echo "Using Packer served VIC Engine file: ${BUILD_VICENGINE_FILE}"
  VIC_ENGINE_FILE=${BUILD_VICENGINE_FILE}
  VIC_ENGINE_URL=${PACKER_HTTP_ADDR}/${VIC_ENGINE_FILE}
elif [ -n "${BUILD_VICENGINE_URL}" ]; then
  VIC_ENGINE_FILE="$(basename ${BUILD_VICENGINE_URL})"
  VIC_ENGINE_URL=${BUILD_VICENGINE_URL}
  echo "Using VIC Engine URL: ${VIC_ENGINE_URL}"
else
  VIC_ENGINE_FILE="vic_${BUILD_VICENGINE_REVISION}.tar.gz"
  VIC_ENGINE_URL="https://storage.googleapis.com/vic-engine-releases/${VIC_ENGINE_FILE}"
  echo "Using VIC Engine URL: ${VIC_ENGINE_URL}"
fi
set -u

echo "Downloading VIC Engine ${VIC_ENGINE_FILE}: ${VIC_ENGINE_URL}"
VIC_ENGINE_BUILD="$(echo ${VIC_ENGINE_FILE} | sed  's/vic_//' | sed 's/.tar.gz//')"
curl -LO ${VIC_ENGINE_URL}
tar xzf ${VIC_ENGINE_FILE} -C ${FILES_DIR} vic/ui/vsphere-client-serenity/com.vmware.vic.ui-v${BUILD_VICENGINE_REVISION}.${VIC_ENGINE_BUILD}.zip vic/ui/plugin-packages/com.vmware.vic-v${BUILD_VICENGINE_REVISION}.${VIC_ENGINE_BUILD}.zip --strip-components=3
mv ${VIC_ENGINE_FILE} ${FILES_DIR}
