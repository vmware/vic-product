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

echo -e "BRANCH = $DRONE_BRANCH\nEVENT = $DRONE_BUILD_EVENT\nTAG = $DRONE_TAG\n"

# set options based on drone args, if present
if [ -n "${ADMIRAL}" ]; then
  OPTIONS="--admiral $ADMIRAL"
fi
if [ -n "${HARBOR}" ]; then
  OPTIONS="$OPTIONS --harbor $HARBOR"
fi
if [ -n "${VICENGINE}" ]; then
  OPTIONS="$OPTIONS --vicengine $VICENGINE"
fi
if [ -n "${VIC_MACHINE_SERVER}" ]; then
  OPTIONS="$OPTIONS --vicmachineserver $VIC_MACHINE_SERVER"
fi

# set release options if drone args not present
if [[ ( "$DRONE_BUILD_EVENT" == "tag" && "$DRONE_TAG" != *"dev"* ) || "$DRONE_BRANCH" == *"releases/"* ]]; then
  if [ -z "${ADMIRAL}" ]; then
    admiral_release=$(curl -s https://hub.docker.com/v2/repositories/vmware/admiral/tags/\?page\=1\&page_size\=250 | jq '.results[] | .name'| cut -d "\"" -f2 | grep '^vic_v' | head -n 1 | cut -d'_' -f2)
    OPTIONS="--admiral $admiral_release"
  fi
  if [ -z "${HARBOR}" ]; then
    harbor_release=$(gsutil ls -l "gs://harbor-releases" | grep -v TOTAL | grep offline-installer | sort -k2 -r | (trap '' PIPE; head -n1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
    OPTIONS="$OPTIONS --harbor $harbor_release"
  fi
  if [ -z "${VICENGINE}" ]; then
    vicengine_release=$(gsutil ls -l "gs://vic-engine-builds/$DRONE_BRANCH" | grep -v TOTAL | grep vic_ | sort -k2 -r | (trap '' PIPE; head -1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
    OPTIONS="$OPTIONS --vicengine $vicengine_release"
  fi
  if [ -z "${VIC_MACHINE_SERVER}" ]; then
    # Listing container tags requires permissions
    if [ -z "$(gcloud auth list --filter=status:ACTIVE --format='value(account)')" ]; then
      if [ -z "${GS_TOKEN_KEY}" ]; then
        echo "No google service account key found..."
        exit 1
      fi
      echo "Attempting to login with google account service key"
      KEY_FILE=".tmp.token"
      echo "${GS_TOKEN_KEY}" > ${KEY_FILE}
      gcloud auth activate-service-account --key-file ${KEY_FILE} || (echo "Login with service account key failed..." && exit 1)
      rm -f ${KEY_FILE}
    fi

    version="${DRONE_BRANCH##.*/}"
    vicmachineserver_release="$(gcloud container images list-tags gcr.io/eminent-nation-87317/vic-machine-server --filter='tags~.' | grep -v DIGEST | awk '{print $2}' | sed -rn 's/^(.*,)?v'"${version}"'-.*(,.*)?$/\2/p' | head -n 1)"
    OPTIONS="$OPTIONS --vicmachineserver $vicmachineserver_release"
  fi
fi

echo "OPTIONS = $OPTIONS"

# invoke build script
$INSTALLER_DIR/build/build.sh ova-ci $OPTIONS
