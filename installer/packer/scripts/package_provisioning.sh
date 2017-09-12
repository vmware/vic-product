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

# Remove old kernel
tdnf remove -y linux
# Update packages
tdnf distro-sync -y --refresh
# Install sudo and ESX-optimized kernel
tdnf install -y sudo linux-esx rsync lvm2 gawk parted tar openjre cdrkit xfsprogs docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.11.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Remove unused packages
tdnf remove -y cloud-init open-vm-tools

# Reboot to load new kernel
systemctl --no-wall reboot
