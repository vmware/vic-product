#!/usr/bin/bash
# Copyright 2018 VMware, Inc. All Rights Reserved.
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

echo "Provisioning VIC Engine ${BUILD_VICENGINE_FILE}"
cp "/etc/cache/${BUILD_VICENGINE_FILE}" ${FILES_DIR}

echo "Provisioning VIC UI ${BUILD_VICUI_FILE}"

TMP_FOLDER=/tmp/vic-ui
mkdir -p ${TMP_FOLDER}
cd ${TMP_FOLDER}
tar -xzf /etc/cache/${BUILD_VICUI_FILE} -C "${TMP_FOLDER}" # creates ${TMP_FOLDER}/bin/ui/....

# get version strings
VIC_BIN_ROOT="${TMP_FOLDER}/bin/"
FULL_VER_STRING=$(echo "${BUILD_OVA_REVISION}" | sed -e 's/\-rc[[:digit:]]//g')
MAJOR_MINOR_PATCH=$(echo $FULL_VER_STRING | awk -F- '{print $1}' | cut -c 2-)
BUILD_NUMBER=$(echo $FULL_VER_STRING | awk -F- '{print $2}')
VIC_ENGINE_VER_STRING=${MAJOR_MINOR_PATCH}.${BUILD_NUMBER}
VIC_UI_VER_STRING=$(ls -l ${VIC_BIN_ROOT}ui/plugin-packages | grep '^d' | head -1 | awk '{print $9}' | awk -F- '{print substr($0, index($0,$2))}')

# update plugin-package.xml for H5 Client plugin
echo "Updating description for H5 Client plugin to \"vSphere Client Plugin for vSphere Integrated Containers Engine (v${VIC_ENGINE_VER_STRING})"\"
cd ${VIC_BIN_ROOT}ui/plugin-packages/com.vmware.vic-${VIC_UI_VER_STRING}
sed -i "s/H5 Client Plugin for vSphere Integrated Containers Engine/vSphere Client Plugin for vSphere Integrated Containers Engine \(v${VIC_ENGINE_VER_STRING}\)/" plugin-package.xml
zip -9 -r ${VIC_BIN_ROOT}ui/plugin-packages/com.vmware.vic-${VIC_UI_VER_STRING}.zip ./*
cd ${TMP_FOLDER}

# update plugin-package.xml for Flex Client plugin
echo "Updating description for Flex Client plugin to \"vSphere Client Plugin for vSphere Integrated Containers Engine (v${VIC_ENGINE_VER_STRING})\""
cd ${VIC_BIN_ROOT}ui/vsphere-client-serenity/com.vmware.vic.ui-${VIC_UI_VER_STRING}
sed -i "s/Flex Client Plugin for vSphere Integrated Containers Engine/vSphere Client Plugin for vSphere Integrated Containers Engine \(v${VIC_ENGINE_VER_STRING}\)/" plugin-package.xml 
zip -9 -r ${VIC_BIN_ROOT}ui/vsphere-client-serenity/com.vmware.vic.ui-${VIC_UI_VER_STRING}.zip ./*
cd ${TMP_FOLDER}

echo "version from the vic-ui repo is:  ${VIC_UI_VER_STRING}"
echo "version from vic-engine is:    ${VIC_ENGINE_VER_STRING}"

find . -iname "*.zip" -exec cp {} ${FILES_DIR} \;

# clean up scratch folders
rm -rf ${TMP_FOLDER}

ls -l ${FILES_DIR}

# Write version files
echo "engine=${BUILD_VICENGINE_FILE}" >> /data/version
echo "engine=${BUILD_VICENGINE_FILE}" >> /etc/vmware/version
