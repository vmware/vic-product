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

# Enable systemd services
systemctl enable toolbox.service
systemctl enable docker.service
systemctl enable data.mount repartition.service resizefs.service getty@tty2.service
systemctl enable sshd_permitrootlogin.service firstboot.service firstboot.path vic-appliance.target
systemctl enable ovf-network.service ova-firewall.service
systemctl enable harbor_startup.path admiral_startup.path get_token.timer
systemctl enable fileserver_startup.service fileserver.service
systemctl enable engine_installer_startup.service engine_installer.service

# Clean up temporary directories
rm -rf /tmp/* /var/tmp/*
tdnf clean all

