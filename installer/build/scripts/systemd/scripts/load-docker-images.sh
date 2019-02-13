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
source /installer.env

if [[ ! -f /etc/vmware/firstboot ]]; then
  set +e
  # Only load the docker images if it's the first time booting
  ls "/etc/cache/docker/" | while read line; do
    docker load -i "/etc/cache/docker/$line"
  done;
  set -e

  # Load harbor
  echo "Loading Harbor"
  harbor_containers_bundle=$(find /var/tmp/harbor -size +20M -type f -regextype sed -regex ".*/harbor\..*\.t.*z$")
  docker load -i "$harbor_containers_bundle"
  rm -r /var/tmp/harbor
  rm -r /etc/cache

  echo "Loading Admiral"
  # tag admiral as :ova
  ADMIRAL_IMAGE="vmware/admiral:vic_${BUILD_ADMIRAL_REVISION}"
  docker tag "$ADMIRAL_IMAGE" vmware/admiral:ova
  ADMIRAL_IMAGE_ID=$(docker images vmware/admiral:ova -q)

  # Write version files
  echo "admiral=${ADMIRAL_IMAGE} ${ADMIRAL_IMAGE_ID}" >> /storage/data/version
  echo "admiral=${ADMIRAL_IMAGE} ${ADMIRAL_IMAGE_ID}" >> /etc/vmware/version

  echo "Loading vic-machine-server"
  # tag vic-machine-server as :ova
  VIC_MACHINE_SERVER_IMAGE="gcr.io/eminent-nation-87317/vic-machine-server:${BUILD_VIC_MACHINE_SERVER_REVISION}"
  docker tag "$VIC_MACHINE_SERVER_IMAGE" vmware/vic-machine-server:ova
  VIC_MACHINE_SERVER_IMAGE_ID="$(docker images vmware/vic-machine-server:ova -q)"

  # Write version files
  echo "vic-machine-server=${VIC_MACHINE_SERVER_IMAGE} ${VIC_MACHINE_SERVER_IMAGE_ID}" >> /storage/data/version
  echo "vic-machine-server=${VIC_MACHINE_SERVER_IMAGE} ${VIC_MACHINE_SERVER_IMAGE_ID}" >> /etc/vmware/version
  date -u +"%Y-%m-%dT%H:%M:%SZ" > /etc/vmware/firstboot
else
  echo "No images to load...."
fi
