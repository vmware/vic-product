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

BUILD_VICENGINE_REVISION="${BUILD_VICENGINE_REVISION:-}"
PACKER_ESX_HOST="${PACKER_ESX_HOST:-}"
PACKER_USER="${PACKER_USER:-}"
PACKER_PASSWORD="${PACKER_PASSWORD:-}"
keyfile=$1

if [ -z "${PACKER_ESX_HOST}" ] || [ -z "${PACKER_USER}" ]; then
  echo "Required Packer environment variables not set"
  exit 1
fi

rm -rf bin
mkdir bin
mkdir /root/.ssh/
touch /root/.ssh/known_hosts
pwd
ls -al .
ls -al /root/.ssh/known_hosts

ssh -t -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE "export PACKER_ESX_HOST=$PACKER_ESX_HOST && export PACKER_USER=$PACKER_USER && export PACKER_PASSWORD=$PACKER_PASSWORD && export BUILD_VICENGINE_REVISION=$BUILD_VICENGINE_REVISION && cd ~/go/src/github.com/vmware/vic-product/installer/ && sudo -E scripts/build.sh"

ssh -t -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE "sudo chown $OVA_BUILD_USER:$OVA_BUILD_USER ~/go/src/github.com/vmware/vic-product/installer/bin/vic-*.ova"

scp -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE:"~/go/src/github.com/vmware/vic-product/installer/bin/vic-*.ova" bin/
