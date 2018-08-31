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

# this file sets vic-product specific variables for the build configuration
set -e -o pipefail +h && [ -n "$DEBUG" ] && set -x
DIR=$(pwd)
CACHE=${DIR}/bin/.cache/
mkdir -p ${CACHE}

# Check if it's a file in `scripts`, URL, or REVISION
function setenv() {
  tmpvar=$1
  fallback=$2
  # if a cli argument was specified, it's a local file, gcloud bucket upload, or revision number.
  if [ -n "${!tmpvar}" ]; then
    if [ -f "${DIR}/build/${!tmpvar}" ]; then
      export BUILD_$1_FILE="${!tmpvar}"
      export BUILD_$1_URL="${DIR}/build/${!tmpvar}"
    elif [[ "${!tmpvar}" =~ ^http://|^https:// ]]; then
      export BUILD_$1_URL="${!tmpvar}"
      export BUILD_$1_FILE="$(basename "${!tmpvar}")"
    else
      export BUILD_$1_REVISION="${!tmpvar}"
    fi
  else   # if a cli argument was NOT specified, use the version specified by $fallback
    if [[ "${fallback}" =~ ^http://|^https:// ]]; then
      export BUILD_$1_URL="${fallback}"
      export BUILD_$1_FILE=$(basename "${fallback}")
    else
      export BUILD_$1_REVISION="${fallback}"
    fi
  fi
}

while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
    --admiral)
      ADMIRAL="$2"
      shift 2 # past argument
      ;;
    --vicengine)
      VICENGINE="$2"
      shift 2 # past argument
      ;;
    --vicui)
      VICUI="$2"
      shift 2 # past argument
      ;;
    --vicmachineserver)
      VIC_MACHINE_SERVER="$2"
      shift 2 # past argument
      ;;
    --harbor)
      HARBOR="$2"
      shift 2 # past argument
      ;;
    *)
      # unknown
      break; break;
  esac
done

# set Admiral
setenv ADMIRAL "dev"

# set vic-machine-server
setenv VIC_MACHINE_SERVER "dev"

# set Vic-Engine
url=""
if [ -z "${VICENGINE}" ]; then
    url=$(gsutil ls -l "gs://vic-engine-builds" | grep -v TOTAL | grep vic_ | sort -k2 -r | (trap '' PIPE; head -1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
fi
setenv VICENGINE "$url"

url=""
if [ -z "${VICUI}" ]; then
    url=$(gsutil ls -l "gs://vic-ui-builds" | grep -v TOTAL | grep vic_ | sort -k2 -r | (trap '' PIPE; head -1) | xargs | cut -d " " -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
fi
setenv VICUI "$url"

#set Harbor
url=""
if [ -z "${HARBOR}" ]; then
    url=$(curl --silent https://storage.googleapis.com/harbor-builds/master.stable)
    if [[ ! "$url" =~ ^http://|^https:// ]]; then
        echo "Cannot find proper harbor archive for link '$url'"
        exit 1
    fi
fi
setenv HARBOR "$url"

export BUILD_DCHPHOTON_VERSION="1.13"

ENV_FILE="${CACHE}/installer.env"
touch $ENV_FILE
cat > $ENV_FILE <<EOF
export BUILD_HARBOR_FILE=${BUILD_HARBOR_FILE:-}
export BUILD_HARBOR_URL=${BUILD_HARBOR_URL:-}
export BUILD_VICENGINE_FILE=${BUILD_VICENGINE_FILE:-}
export BUILD_VICENGINE_URL=${BUILD_VICENGINE_URL:-}
export BUILD_VICUI_FILE=${BUILD_VICUI_FILE:-}
export BUILD_VICUI_URL=${BUILD_VICUI_URL:-}
export BUILD_VIC_MACHINE_SERVER_REVISION=${BUILD_VIC_MACHINE_SERVER_REVISION:-}
export BUILD_ADMIRAL_REVISION=${BUILD_ADMIRAL_REVISION:-}
export BUILD_OVA_REVISION=${BUILD_OVA_REVISION:-}
export BUILD_DCHPHOTON_VERSION=${BUILD_DCHPHOTON_VERSION-}
export DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER:-}
EOF

echo -e "--------------------------------------------------
buidling ova with env...\n
$(cat $ENV_FILE | sed 's/export //g')"

echo "--------------------------------------------------"
echo "building make dependencies"
make all
echo "--------------------------------------------------"
echo "caching build dependencies..."
${DIR}/build/build-cache.sh -c "${CACHE}"

echo "--------------------------------------------------"
echo "building OVA..."
${DIR}/build/bootable/build-main.sh -m "${DIR}/build/ova-manifest.json" -r "${DIR}/bin" -c "${CACHE}" $@

if [ "tag" == "${DRONE_BUILD_EVENT}" ]; then
    echo "--------------------------------------------------"
    echo "Command to stage this tag build for release:"
    cat <<EOF
drone deploy --param VICENGINE=${BUILD_VICENGINE_URL:-} \\
             --param VIC_MACHINE_SERVER=${BUILD_VIC_MACHINE_SERVER_REVISION:-} \\
             --param ADMIRAL=${BUILD_ADMIRAL_REVISION:-} \\
             --param HARBOR=${BUILD_HARBOR_URL:-} \\
             --param VICUI=${BUILD_VICUI_URL:-} \\
             vmware/vic-product ${DRONE_BUILD_NUMBER:-} staging
EOF
elif [ "deployment" == "${DRONE_BUILD_EVENT}" -a "staging" == "${DRONE_DEPLOY_TO}" ]; then
    echo "--------------------------------------------------"
    echo "Command to release this tag staged build:"
    cat <<EOF
drone deploy --param VICENGINE=${BUILD_VICENGINE_URL:-} \\
             --param VIC_MACHINE_SERVER=${BUILD_VIC_MACHINE_SERVER_REVISION:-} \\
             --param ADMIRAL=${BUILD_ADMIRAL_REVISION:-} \\
             --param HARBOR=${BUILD_HARBOR_URL:-} \\
             --param VICUI=${BUILD_VICUI_URL:-} \\
             vmware/vic-product ${DRONE_BUILD_NUMBER:-} release
EOF
fi
