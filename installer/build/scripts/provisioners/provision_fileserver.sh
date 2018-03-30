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

DATA_DIR="/opt/vmware/fileserver"
FILES_DIR="${DATA_DIR}/files"

mkdir -p /etc/vmware/fileserver # Fileserver config scripts
mkdir -p ${FILES_DIR}           # Files to serve
mkdir -p ${DATA_DIR}            # Backup of the original vic tar

cd /var/tmp

echo "Provisioning VIC Engine ${BUILD_VICENGINE_FILE}"
cp /etc/cache/${BUILD_VICENGINE_FILE} .

# Copy UI plugin zip files to fileserver directory
tar tf "${BUILD_VICENGINE_FILE}" | grep "vic/ui" | grep ".zip" | xargs  -I '{}' tar xzf "${BUILD_VICENGINE_FILE}" -C ${FILES_DIR} '{}' --strip-components=3

mv "${BUILD_VICENGINE_FILE}" ${DATA_DIR}
touch "${FILES_DIR}/${BUILD_VICENGINE_FILE}"

# Write version files
echo "engine=${BUILD_VICENGINE_FILE}" >> /data/version
echo "engine=${BUILD_VICENGINE_FILE}" >> /etc/vmware/version
