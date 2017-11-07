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
export BUILD_NUMBER=${DRONE_BUILD_NUMBER:-}
ADMIRAL=""
VICENGINE=""
VIC_MACHINE_SERVER=""
HARBOR=""

function usage() {
    echo -e "Usage:
      <ova-dev|ova-ci>
      [--admiral|--vicmachineserver] <given a revision, eg. 'dev', 'latest'>
      [--vicengine|--harbor] <given a url, eg. 'https://storage.googleapis.com/vic-engine-builds/vic_13806.tar.gz'>
      [--vicengine|--harbor] <given a file in cwd, eg. 'vic_13806.tar.gz'>
    ie: $0 ova-dev --harbor v1.2.0-38-ge79334a --vicengine https://storage.googleapis.com/vic-engine-builds/vic_13806.tar.gz --admiral v1.2" >&2
    exit 1
}

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

function cleanup() {
  echo "--------------------------------------------------"
  echo "cleaning up..."
  ./build/cleanup.sh
}

trap cleanup EXIT

GIT_TAG="$(git describe --tags)"
export BUILD_OVA_REVISION=${GIT_TAG}
export BUILD_DCHPHOTON_VERSION="1.13"

[ $# -gt 0 ] || usage
step=$1; shift
[ ! "$step" == "ova-ci" ] || [ ! "$step" == "ova-dev" ] || usage

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
    --vicmachineserver)
      VIC_MACHINE_SERVER="$2"
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

# set Admiral
setenv ADMIRAL "dev"

# set vic-machine-server
setenv VIC_MACHINE_SERVER "latest"

# set Vic-Engine
url=$(gsutil ls -l "gs://vic-engine-builds" | grep -v TOTAL | grep vic_ | sort -k2 -r | (trap '' PIPE; head -1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
setenv VICENGINE "$url"

#set Harbor
url=$(gsutil ls -l "gs://harbor-builds" | grep -v TOTAL | sort -k2 -r | (trap '' PIPE; head -n1) | xargs | cut -d ' ' -f 3 | sed 's/gs:\/\//https:\/\/storage.googleapis.com\//')
setenv HARBOR "$url"


ENV_FILE=build/baseimage/root/installer.env
touch $ENV_FILE
cat > $ENV_FILE <<EOF
export BUILD_HARBOR_FILE=${BUILD_HARBOR_FILE:-}
export BUILD_HARBOR_URL=${BUILD_HARBOR_URL:-}
export BUILD_VICENGINE_FILE=${BUILD_VICENGINE_FILE:-}
export BUILD_VICENGINE_URL=${BUILD_VICENGINE_URL:-}
export BUILD_VIC_MACHINE_SERVER_REVISION=${BUILD_VIC_MACHINE_SERVER_REVISION:-}
export BUILD_ADMIRAL_REVISION=${BUILD_ADMIRAL_REVISION:-}
export BUILD_OVA_REVISION=${BUILD_OVA_REVISION:-}
export BUILD_DCHPHOTON_VERSION=${BUILD_DCHPHOTON_VERSION-}
export DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER:-}
EOF

echo -e "--------------------------------------------------
buidling ova with env...\n
$(cat $ENV_FILE | sed 's/export //g')
--------------------------------------------------"

echo "--------------------------------------------------"
echo "caching build dependencies..."
mkdir -p build/baseimage/{bin,cache,cache/docker}
make all
./build/cache.sh

echo "--------------------------------------------------"
echo "packaging OVA..."

if [ "$step" == "ova-dev" ]; then
docker run -it --rm --privileged -v /dev:/dev -v $(pwd):/work -w /work \
    -e BUILD_HARBOR_FILE=${BUILD_HARBOR_FILE} \
    -e BUILD_VICENGINE_FILE=${BUILD_VICENGINE_FILE} \
    -e BUILD_VIC_MACHINE_SERVER_REVISION=${BUILD_VIC_MACHINE_SERVER_REVISION} \
    -e BUILD_ADMIRAL_REVISION=${BUILD_ADMIRAL_REVISION} \
    -e BUILD_OVA_REVISION=${BUILD_OVA_REVISION} \
    -e BUILD_DCHPHOTON_VERSION=${BUILD_DCHPHOTON_VERSION} \
    -e DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER} \
    -e TERM vmware/photon ./build/baseimage/stage.sh
elif [ "$step" == "ova-ci" ]; then
  ./build/baseimage/stage.sh
else
  usage
fi

cp build/vic-unified.ovf build/baseimage/bin/vic-${BUILD_OVA_REVISION}.ovf
cd build/baseimage/bin/
sed -i -e s~--version--~${BUILD_OVA_REVISION}~ vic-${BUILD_OVA_REVISION}.ovf
echo "rebuilding OVF manifest"
sha256sum --tag * | sed s/SHA256\ \(/SHA256\(/ > vic-${BUILD_OVA_REVISION}.mf
tar -cvf ../../../bin/vic-${BUILD_OVA_REVISION}.ova vic-${BUILD_OVA_REVISION}.ovf vic-${BUILD_OVA_REVISION}.mf *.vmdk
cd ../../../

OUTFILE=bin/$(ls -1t bin | grep "\.ova")

echo "build complete"
echo "  SHA256: $(shasum -a 256 $OUTFILE)"
echo "  SHA1: $(shasum -a 1 $OUTFILE)"
echo "  MD5: $(md5sum $OUTFILE)"
du -ks $OUTFILE | awk '{printf "%sMB\n", $1/1024}'
