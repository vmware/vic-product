#!/bin/bash
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

set -e

# set variables
cd installer
INSTALLER_DIR=$(pwd)
OPTIONS=""

echo "BRANCH = $DRONE_BRANCH"

# set options
if [ -n "${ADMIRAL}" ]; then
  OPTIONS="--admiral $ADMIRAL"
elif [[ "$DRONE_BRANCH" == *"releases/"* ]]; then
  admiral_release=$(curl -s https://hub.docker.com/v2/repositories/vmware/admiral/tags/\?page\=1\&page_size\=250 | jq '.results[] | .name'| cut -d "\"" -f2 | grep '^vic_v' | head -n 1 | cut -d'_' -f2)
  OPTIONS="--admiral $admiral_release"
fi

if [ -n "${HARBOR}" ]; then
  OPTIONS="$OPTIONS --harbor $HARBOR"
elif [[ "$DRONE_BRANCH" == *"releases/"* ]]; then
  harbor_release=$(gsutil ls -l "gs://harbor-releases" | grep -v TOTAL | grep offline-installer | sort -k2 -r | (trap '' PIPE; head -n1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
  OPTIONS="$OPTIONS --harbor $harbor_release"
fi

if [ -n "${VICENGINE}" ]; then
  OPTIONS="$OPTIONS --vicengine $VICENGINE"
elif [[ "$DRONE_BRANCH" == *"releases/"* ]]; then
  vicengine_release=$(gsutil ls -l "gs://vic-engine-releases" | grep -v TOTAL | grep vic_ | sort -k2 -r | (trap '' PIPE; head -1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
  OPTIONS="$OPTIONS --vicengine $vicengine_release"
fi

if [ -n "${VIC_MACHINE_SERVER}" ]; then
  OPTIONS="$OPTIONS --vicmachineserver $VIC_MACHINE_SERVER"
elif [[ "$DRONE_BRANCH" == *"releases/"* ]]; then
  vicmachineserver_release="latest"
  OPTIONS="$OPTIONS --vicmachineserver $vicmachineserver_release"
fi

echo "OPTIONS = $OPTIONS"

# invoke build script
$INSTALLER_DIR/build/build.sh ova-ci $OPTIONS