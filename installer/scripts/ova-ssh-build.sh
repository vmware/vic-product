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

keyfile=$1

if [ -z "${PACKER_ESX_HOST}" ] || [ -z "${PACKER_USER}" ]; then
  echo "Required Packer env variables not set"
  exit 1
fi

echo "Cleaning up the bin folder..."
rm -rf bin
mkdir bin

echo "Starting ssh to the OVA Builder vm.."
ssh -t -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE_IP "export PACKER_ESX_HOST=$PACKER_ESX_HOST && export PACKER_USER=$PACKER_USER && export PACKER_PASSWORD=$PACKER_PASSWORD && export BUILD_PORTGROUP=$BUILD_PORTGROUP && export DRONE_BUILD_NUMBER=$DRONE_BUILD_NUMBER && export BUILD_VICENGINE_REVISION=$BUILD_VICENGINE_REVISION && cd ~/go/src/github.com/vmware/vic-product/installer/ && sudo make clean && sudo -E scripts/build.sh"

ssh -t -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE_IP "sudo chown $OVA_BUILD_USER:$OVA_BUILD_USER ~/go/src/github.com/vmware/vic-product/installer/bin/vic-*.ova"

ssh -t -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE_IP "ping -c 3 $OVA_BUILD_MACHINE_IP && traceroute $OVA_BUILD_MACHINE_IP"

echo "Copying the ova from the ovabuilder.."
scp -v -r -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE_IP:"~/go/src/github.com/vmware/vic-product/installer/bin/vic-*.ova" bin/

ssh -t -o StrictHostKeyChecking=no -i $keyfile $OVA_BUILD_USER@$OVA_BUILD_MACHINE_IP "sudo rm -rf ~/go/src/github.com/vmware/vic-product/installer/bin/vic-*.ova"
