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

if [[ -n "${SYSLOG_SRV_IP}" ]]; then
  cat <<EOF | tee /etc/rsyslog.d/local-files.conf
# Load the input file module.
\$ModLoad imfile

# Set the poll interval to 10 seconds
\$InputFilePollInterval 10

# Specify which files to be monitored
\$InputFileName /storage/log/admiral/xenonHost.0.log
\$InputFileTag admiral:
\$InputFileStateFile stat_admiral
\$InputFileSeverity info
\$InputFileFacility local7
\$InputRunFileMonitor

\$InputFileName /storage/log/vic-machine-server/vic-machine-server.log
\$InputFileTag vic-machine-server:
\$InputFileStateFile stat_vic_machine_server
\$InputFileSeverity info
\$InputFileFacility local7
\$InputRunFileMonitor
EOF
  systemctl restart rsyslog.service
fi
