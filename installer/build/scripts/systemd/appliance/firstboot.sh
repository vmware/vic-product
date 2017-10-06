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
  # change root password
  set +e
  echo "root:$(ovfenv --key appliance.root_pwd)" | chpasswd
  # Reset password expiration to 90 days by default
  chage -d $(date +"%Y-%m-%d") -m 0 -M 90 root

  # Only load the docker images if it's the first time booting
  ls "/etc/cache/docker/" | while read line; do
    docker load -i "/etc/cache/docker/$line"
  done;
  set -e

  # Load harbor
  mkdir -p /tmp/harbor
  harbor_file=$(ls /etc/cache | grep harbor)
  cat /etc/cache/${BUILD_HARBOR_FILE} | tar xz -C /tmp/harbor
  harbor_containers_bundle=$(find /tmp/harbor -size +20M -type f -regextype sed -regex ".*/harbor\..*\.t.*z$")
  docker load -i "$harbor_containers_bundle"
  rm -r /tmp/harbor
  rm -r /etc/cache

  # tag admiral as :ova
  ADMIRAL_IMAGE="vmware/admiral:vic_${BUILD_ADMIRAL_REVISION}"
  ADMIRAL_IMAGE_ID=$(docker images vmware/admiral:ova -q)
  
  docker tag $ADMIRAL_IMAGE vmware/admiral:ova
  # Write version files
  echo "admiral=${ADMIRAL_IMAGE} ${ADMIRAL_IMAGE_ID}" >> /data/version
  echo "admiral=${ADMIRAL_IMAGE} ${ADMIRAL_IMAGE_ID}" >> /etc/vmware/version
  date -u +"%Y-%m-%dT%H:%M:%SZ" > /etc/vmware/firstboot
fi

# We then obscure the root password, if the VM is reconfigured with another
# password after deployment, we don't act on it and keep obscuring it.
if [[ $(ovfenv --key appliance.root_pwd) != '*******' ]]; then
  ovfenv --key appliance.root_pwd --set '*******'
fi