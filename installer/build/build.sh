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

# this file is responsible for parsing cli args and spinning up a build container
# wraps bootable/build-main.sh in a docker container
DEBUG=${DEBUG:-}
set -e -o pipefail +h && [ -n "$DEBUG" ] && set -x
ROOT_DIR="$GOPATH/src/github.com/vmware/vic-product/"
ROOT_WORK_DIR="/go/src/github.com/vmware/vic-product/"

ROOT_INSTALLER_DIR="${ROOT_DIR}/installer"
ROOT_INSTALLER_WORK_DIR="${ROOT_WORK_DIR}/installer"

ADMIRAL=""
VICENGINE=""
VIC_MACHINE_SERVER=""
HARBOR=""
TAG=${DRONE_TAG:-$(git describe --abbrev=0 --tags)} # e.g. `v0.9.0`
REV=$(git rev-parse --short=8 HEAD)
DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER:-0}
BUILD_OVA_REVISION="${TAG}-${DRONE_BUILD_NUMBER}-${REV}"
BUILD_NUMBER=${DRONE_BUILD_NUMBER:-}
DRONE_BUILD_EVENT=${DRONE_BUILD_EVENT:-}
DRONE_DEPLOY_TO=${DRONE_DEPLOY_TO:-}

function usage() {
    echo -e "Usage:
      <ova-dev|ova-ci>
      [--admiral|--vicmachineserver] <given a revision, ie. 'dev', 'latest'>
      [--vicengine|--harbor|--vicui] <given a url, eg. 'https://storage.googleapis.com/vic-engine-builds/vic_13806.tar.gz'>
      [--vicengine|--harbor|--vicui] <given a file in cwd, eg. 'vic_13806.tar.gz'>
      [passthrough args for ./bootable/build-main.sh, eg. '-b bin/.vic-appliance-base.tar.gz']
    ie: $0 ova-dev --harbor v1.2.0-38-ge79334a --vicengine https://storage.googleapis.com/vic-engine-builds/vic_13806.tar.gz --admiral v1.2" >&2
    exit 1
}

[ $# -gt 0 ] || usage
step=$1; shift
[ ! "$step" == "ova-ci" ] || [ ! "$step" == "ova-dev" ] || usage

echo "--------------------------------------------------"
if [ "$step" == "ova-dev" ]; then
  echo "starting docker dev build container..."
  docker run -it --rm --privileged -v /dev:/dev \
    -v ${ROOT_DIR}/:/${ROOT_WORK_DIR}/:ro \
    -v ${ROOT_INSTALLER_DIR}/bin/:/${ROOT_INSTALLER_WORK_DIR}/bin/ \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e DEBUG=${DEBUG} \
    -e BUILD_OVA_REVISION=${BUILD_OVA_REVISION} \
    -e TAG=${TAG} \
    -e BUILD_NUMBER=${BUILD_NUMBER} \
    -e DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER} \
    -e DRONE_BUILD_EVENT=${DRONE_BUILD_EVENT} \
    -e DRONE_DEPLOY_TO=${DRONE_DEPLOY_TO} \
    -e TERM -w ${ROOT_INSTALLER_WORK_DIR} \
    gcr.io/eminent-nation-87317/vic-product-build ./build/build-ova.sh $*
elif [ "$step" == "ova-ci" ]; then
  echo "starting ci build..."
  export DEBUG=${DEBUG}
  export BUILD_OVA_REVISION=${BUILD_OVA_REVISION}
  export TAG=${TAG}
  export BUILD_NUMBER=${BUILD_NUMBER}
  export DRONE_BUILD_NUMBER=${DRONE_BUILD_NUMBER}
  export DRONE_BUILD_EVENT=${DRONE_BUILD_EVENT}
  export DRONE_DEPLOY_TO=${DRONE_DEPLOY_TO}
  echo "login to docker hub..."
  docker login -u $DOCKER_USER -p $DOCKER_PASSWORD
  ./build/build-ova.sh $*
else
  usage
fi
