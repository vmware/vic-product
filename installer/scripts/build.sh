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

# exit on failure and configure debug, include util functions
set -euf -o pipefail

DRONE_BUILD_NUMBER="${DRONE_BUILD_NUMBER:-}"
BUILD_VICENGINE_REVISION="${BUILD_VICENGINE_REVISION:-}"
PACKER_ESX_HOST="${PACKER_ESX_HOST:-}"
PACKER_USER="${PACKER_USER:-}"
PACKER_PASSWORD="${PACKER_PASSWORD:-}"
ADMIRAL=""
VICENGINE=""
HARBOR=""
KOVD=""
KOV_CLI=""

if [ -z "${PACKER_ESX_HOST}" ] || [ -z "${PACKER_USER}" ] || [ -z "${PACKER_PASSWORD}" ]; then
  echo "Required Packer environment variables not set"
  exit 1
fi

function usage() {
    echo "Usage: $0" 1>&2
    exit 1
}

while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
    --admiral)
      ADMIRAL="$2"
      shift # past argument
      ;;
    --vicengine)
      VICENGINE="$2"
      shift # past argument
      ;;
    --harbor)
      HARBOR="$2"
      shift # past argument
      ;;
    --kovd)
      KOVD="$2"
      shift # past argument
      ;;
    --kov-cli)
      KOV_CLI="$2"
      shift # past argument
      ;;
    *)
      # unknown option
      usage
      exit 1
      ;;
  esac
  shift # past argument or value
done

# Check if it's a file in `packer/scripts`, URL, or REVISION
function setenv() {
  tmpvar=$1
  if [ -f "packer/scripts/${!tmpvar}" ]; then
    export BUILD_$1_FILE=${!tmpvar}
  elif [[ "${!tmpvar}" =~ ^http://|^https:// ]]; then
    export BUILD_$1_URL=${!tmpvar}
  else
    export BUILD_$1_REVISION=${!tmpvar}
  fi
}

if [ -n "${ADMIRAL}" ]; then
  setenv ADMIRAL
fi
if [ -n "${VICENGINE}" ]; then
  setenv VICENGINE
fi
if [ -n "${HARBOR}" ]; then
  setenv HARBOR
fi
if [ -n "${KOVD}" ]; then
  setenv KOVD
fi
if [ -n "${KOV_CLI}" ]; then
  setenv KOV_CLI
fi

# If not set, find the latest versions of each component
if [ -z "${ADMIRAL}" ]; then
  export BUILD_ADMIRAL_REVISION="dev"
fi
if [ -z "${VICENGINE}" ]; then
  url=$(gsutil ls -l "gs://vic-engine-builds" | grep -v TOTAL | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
  export BUILD_VICENGINE_URL=$url
fi
if [ -z "${HARBOR}" ]; then
  url=$(gsutil ls -l "gs://harbor-builds" | grep -v TOTAL | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
  export BUILD_HARBOR_URL=$url
fi

if [ -z "${BUILD_VICENGINE_REVISION}" ]; then
  echo "VIC Engine build must be set"
  exit 1
fi
if [ -z "${KOVD}" ]; then
  export BUILD_KOVD_REVISION="dev"
fi
if [ -z "${KOV_CLI}" ]; then
  export BUILD_KOV_CLI_REVISION="dev"
fi

make ova-release

OUTFILE=bin/$(ls -1 bin | grep "\.ova")

if [ -n "${DRONE_BUILD_NUMBER}" ]; then
  TMP=$(echo ${OUTFILE} | sed "s/-/-${DRONE_BUILD_NUMBER}-/")
  mv ${OUTFILE} ${TMP}
  OUTFILE=${TMP}
fi

shasum -a 256 $OUTFILE
shasum -a 1 $OUTFILE
md5sum $OUTFILE
du -ks $OUTFILE | awk '{print $1 / 1024}' | { read x; echo $x MB; }
