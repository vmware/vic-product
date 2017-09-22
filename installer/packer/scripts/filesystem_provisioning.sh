#!/usr/bin/bash
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
set -euf -o pipefail

if [ -z "${BUILD_OVA_REVISION}" ]; then
  echo "BUILD_OVA_REVISION must be set"
  exit 1
fi

# Create directory to host VMware-specific scripts
mkdir /etc/vmware
mkdir /etc/vmware/upgrade
mkdir "/usr/lib/systemd/system/getty@tty2.service.d"

# Create directories for PSC token
mkdir -p /etc/vmware/psc/admiral
mkdir -p /etc/vmware/psc/harbor
mkdir -p /etc/vmware/psc/engine

# Create Data Dir
mkdir /data

# Create filesystem on /dev/sdb to be mounted as /data
parted -a optimal --script /dev/sdb 'mklabel gpt mkpart primary ext4 0% 100%'
mkfs.ext4 /dev/sdb1
tune2fs -L vic-data-v1 /dev/sdb1

# Seed directories in /data
mount /dev/sdb1 /data -t ext4
mkdir -p /data/{admiral,harbor,fileserver}

# Write version files
echo "ova=${BUILD_OVA_REVISION}" > /data/version
echo "ova=${BUILD_OVA_REVISION}" > /etc/vmware/version
