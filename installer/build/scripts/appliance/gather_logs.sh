#!/usr/bin/env bash
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

TIMESTAMP=$(date +"%Y-%m-%d:%H:%M:%S%z")
OUTDIR="/tmp/vic_appliance_logs_$TIMESTAMP"

mkdir -p "$OUTDIR"

# commandToFile runs command $1 and writes the output to file $2 in $OUTDIR
function commandToFile {
  echo "Running $1"
  $1 &> "$OUTDIR/$2"
}

# getLog copies the latest log from the directory
function getLog {
  return
}

# getFailedLogs gets the journal for failed units
function getFailedLogs {
  local UNITS
  UNITS=$(systemctl list-units --state=failed --no-legend --no-pager | cut -d ' ' -f1 | grep -E '(service|target|path)')

  for unit in $UNITS; do
    commandToFile "journalctl -u $unit --no-pager" "journal_$unit"
  done
}

function main {
  commandToFile "hostnamectl" "hostnamectl"
  commandToFile "ip address show" "ip_addr"
  commandToFile "ovfenv" "appliance_ovfenv"
  commandToFile "cat /etc/vmware/environment" "appliance_environment"
  commandToFile "cat /etc/vmware/firstboot" "appliance_firstboot"
  commandToFile "uptime" "appliance_uptime"
  commandToFile "cat /etc/vmware/version" "appliance_version"
  commandToFile "cat /storage/data/version" "data_version"
  commandToFile "systemctl status --no-pager" "systemctl_status"
  commandToFile "systemctl list-jobs --no-pager" "systemctl_list-jobs"
  commandToFile "systemctl list-units --state=failed --no-pager" "systemctl_failed"
  commandToFile "iptables -L -n" "journal_iptables"
  commandToFile "df -h" "storage"
  commandToFile "docker ps -a" "docker_ps"

  commandToFile "journalctl -u admiral_startup --no-pager" "journal_admiral_startup"
  commandToFile "journalctl -u admiral --no-pager" "journal_admiral"
  commandToFile "journalctl -u harbor_startup --no-pager" "journal_harbor_startup"
  commandToFile "journalctl -u harbor --no-pager" "journal_harbor"
  commandToFile "journalctl -u fileserver --no-pager" "journal_fileserver"
  commandToFile "journalctl -u vic_machine_server --no-pager" "journal_vic_machine_server"

  commandToFile "cat /storage/data/admiral/configs/psc-config.properties" "admiral_data_psc-config"
  commandToFile "cat /etc/vmware/psc/admiral/psc-config.properties" "admiral_psc-config"
  commandToFile "du -k /etc/vmware/psc/admiral/tokens.properties" "admiral_psc-token"
  commandToFile "cat /etc/vmware/psc/engine/psc-config.properties" "engine_psc-config"
  commandToFile "du -k /etc/vmware/psc/engine/tokens.properties" "engine_psc-token"
  commandToFile "cat /etc/vmware/psc/harbor/psc-config.properties" "harbor_psc-config"
  commandToFile "du -k /etc/vmware/psc/harbor/tokens.properties" "harbor_psc-token"


  # files from /storage/log/*

  getFailedLogs

  compressBundle
}

main
