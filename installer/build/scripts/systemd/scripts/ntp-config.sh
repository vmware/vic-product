#!/usr/bin/bash
# Copyright 2018 VMware, Inc. All Rights Reserved.
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

time_conf_file=/etc/systemd/timesyncd.conf

ntp="$(ovfenv --key network.ntp | sed 's/,/ /g' | tr -s ' ')"

if [[ -n $ntp ]]; then
cat <<EOF | tee ${time_conf_file}
[Time]
NTP=$ntp
EOF
systemctl restart systemd-timesyncd.service
fi
