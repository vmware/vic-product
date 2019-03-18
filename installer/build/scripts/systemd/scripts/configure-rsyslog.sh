#!/usr/bin/bash
# Copyright 2019 VMware, Inc. All Rights Reserved.
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

# Configure remote system log server if it is specified in ova properties. Clean up auto generated conf files if it is
# removed from ova properties.
RSYSLOG_FORWARD_CONF=/etc/rsyslog.d/forward.conf
if [[ -n "${SYSLOG_SRV_HOST}" ]]; then
  cat <<EOF | tee "${RSYSLOG_FORWARD_CONF}"
action(type="omfwd" Target="${SYSLOG_SRV_HOST}" Port="${SYSLOG_SRV_PORT}" Protocol="${SYSLOG_SRV_PROTOCOL}" Template="RSYSLOG_ForwardFormat")
EOF
else
  rm -f "${RSYSLOG_FORWARD_CONF}"
  rm -f /etc/rsyslog.d/local-files.conf
fi
