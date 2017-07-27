Build_OVA ()
{
# exit on failure and configure debug, include util functions
#set -euf -o pipefail

BUILD_VICENGINE_REVISION="${BUILD_VICENGINE_REVISION:-}"
PACKER_ESX_HOST="${PACKER_ESX_HOST:-}"
PACKER_USER="${PACKER_USER:-}"
PACKER_PASSWORD="${PACKER_PASSWORD:-}"
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
}

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

pipe=/tmp/ovapipe
ova_lock=/var/lock/mylock

#forcing the pipe and lock deletion.
#rm -f $pipe
#rm -rf $ova_lock

set -e

if [ ! -p $pipe ]; then
    echo "Pipe not present"
    mkfifo $pipe
else
    echo "Pipe already present exiting.."
    exit 0
fi

while true
do
    if mkdir $ova_lock; then
        # Delete the pipe
          rm -f $pipe

        # Do the job
          echo "Performing OVA build..."
          Build_OVA $1
          
          #trap "rm -f $pipe" EXIT
          #trap "rm -rf $ova_lock" EXIT

          echo "OVA build complete..."
          rm -rf $ova_lock
          exit 0
    else
        echo "Lock present waiting..."
        sleep 5s
        echo "Retrying..."   
    fi
done

if [ $? != 0 ] then
trap "rm -f $pipe" EXIT
trap "rm -rf $ova_lock" EXIT
fi
