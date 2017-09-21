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
set -eu -o pipefail +h

DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER:-}
ADMIRAL=""
VICENGINE=""
HARBOR=""
step="ova"

function usage() {
    echo -e "Usage:
      [REVISION]: --[admiral] dev
      [URL]: --[vicengine|harbor] https://storage.googleapis.com/vic-engine-builds/vic_13806.tar.gz
      FILE]:  --[vicengine|harbor] vic_13806.tar.gz
    ie: $0 --harbor v1.2.0-38-ge79334a --vicengine https://storage.googleapis.com/vic-engine-builds/vic_13806.tar.gz --admiral v1.2" >&2
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
    --step)
      STEP="$2"
      shift
      ;;
    *)
      # unknown option
      usage
      exit 1
      ;;
  esac
  shift # past argument or value
done

# Check if it's a file in `scripts`, URL, or REVISION
function setenv() {
  tmpvar=$1
  fallback=$2
  # if a cli argument was specified, it's a local file, gcloud bucket upload, or admiral revision number.
  if [ -n "${!tmpvar}" ]; then
    if [ -f "$(pwd)/build/${!tmpvar}" ]; then
      export BUILD_$1_FILE="${!tmpvar}"
      export BUILD_$1_URL="$(pwd)/build/${!tmpvar}"
    elif [[ "${!tmpvar}" =~ ^http://|^https:// ]]; then
      export BUILD_$1_URL="${!tmpvar}"
      export BUILD_$1_FILE="$(basename "${!tmpvar}")"
    else
      export BUILD_$1_REVISION="${!tmpvar}"
    fi
  else   # if a cli argument was NOT specified, use the most recent version specified by $fallback
    if [[ "${fallback}" =~ ^http://|^https:// ]]; then
      export BUILD_$1_URL="${fallback}"
      export BUILD_$1_FILE=$(basename "${fallback}")
    else
      export BUILD_$1_REVISION="${fallback}"
    fi
  fi
}

export BUILD_OVA_REVISION=$(git describe --tags)
export BUILD_DCHPHOTON_VERSION="1.13"
export BUILD_ADMIRAL_RELEASE="v1.1.1"

# set Admiral
setenv ADMIRAL "dev"

# set Vic-Engine
url=$(gsutil ls -l "gs://vic-engine-builds" | grep -v TOTAL | grep vic_ | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
setenv VICENGINE "$url"

#set Harbor
url=$(gsutil ls -l "gs://harbor-builds" | grep -v TOTAL | sort -k2 -r | head -n1 | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
setenv HARBOR "$url"


ENV_FILE=build/baseimage/root/installer.env
touch $ENV_FILE
cat > $ENV_FILE <<EOF
export BUILD_HARBOR_FILE=${BUILD_HARBOR_FILE:-}
export BUILD_HARBOR_URL=${BUILD_HARBOR_URL:-}
export BUILD_VICENGINE_FILE=${BUILD_VICENGINE_FILE:-}
export BUILD_VICENGINE_URL=${BUILD_VICENGINE_URL:-}
export BUILD_ADMIRAL_REVISION=${BUILD_ADMIRAL_REVISION:-}
export BUILD_OVA_REVISION=${BUILD_OVA_REVISION:-}
export BUILD_DCHPHOTON_VERSION=${BUILD_DCHPHOTON_VERSION-}
export DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER:-}
EOF

echo -e "--------------------------------------------------
buidling ova with env...\n
$(cat $ENV_FILE | sed 's/export //g')
--------------------------------------------------"

make $step

OUTFILE=bin/$(ls -1t bin | grep "\.ova")

if [ -n "${DRONE_BUILD_NUMBER}" ]; then
  TMP=$(echo "${OUTFILE}" | sed "s/-/-${DRONE_BUILD_NUMBER}-/")
  mv "${OUTFILE}" "${TMP}"
  OUTFILE=${TMP}
fi

echo "build complete"
echo "  SHA256: $(shasum -a 256 $OUTFILE)"
echo "  SHA1: $(shasum -a 1 $OUTFILE)"
echo "  MD5: $(md5sum $OUTFILE)"
du -ks $OUTFILE | awk '{printf "%sMB", $1/1024}'
