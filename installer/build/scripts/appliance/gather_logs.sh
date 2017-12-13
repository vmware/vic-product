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

TIMESTAMP=$(date +"%Y-%m-%d:%H:%M:%S")
DIRNAME="vic_appliance_logs_$TIMESTAMP"
OUTFILE="$DIRNAME.tar.gz"
TMPDIR="/tmp/$DIRNAME"
OUTDIR="/storage/log/"

mkdir -p "$TMPDIR"

# commandToFile runs command $1 and writes the output to file $2 in $TMPDIR
function commandToFile {
  echo "Running $1"
  $1 &> "$TMPDIR/$2"
}

# commandToCompressed runs command $1 and writes gzipped output to file $2 in $TMPDIR
function commandToCompressed {
  local OUTDIR
  local DIR="${3:-}"
  if [ -n "$DIR" ]; then
    OUTDIR="$TMPDIR/$DIR"
    mkdir -p "$OUTDIR"
  else
    OUTDIR="$TMPDIR"
  fi

  echo "Running $1, compressing output"
  $1 | gzip > "$OUTDIR/$2.gz"
}

# getLog copies files with suffix to $TMPDIR
function getLog {
  local FILES
  FILES=$(find "$1" -name "$2")
  local DIR
  DIR=$(basename "$1")

  for file in $FILES; do
    commandToCompressed "cat $file" "$(basename "$file")" "$DIR"
  done
}

# getFailedLogs gets the journal for failed units
function getFailedLogs {
  echo "Getting logs for failed units"
  local UNITS
  UNITS=$(systemctl list-units --state=failed --no-legend --no-pager | cut -d ' ' -f1 | grep -E '(service|target|path)') || true
  local LEN
  LEN=$(echo "$UNITS" | wc -l)
  LEN=$((LEN - 1))
  echo "Found $LEN failed units"
  if [ $LEN -eq 0 ]; then
    return
  fi
  for unit in $UNITS; do
    commandToCompressed "journalctl -u $unit --no-pager" "journal_$unit"
  done
  echo "Finished getting logs for failed units"
}

# compressBundle creates the log bundle tar
function compressBundle {
  # TODO Check available space

  local DIR
  echo "Creating log bundle $OUTDIR/$OUTFILE"
  tar -czvf "$OUTDIR/$OUTFILE" -C /tmp "$DIRNAME"
  echo "--------------------"
  echo "Created log bundle $OUTDIR/$OUTFILE"
  echo "--------------------"
}

# cleanup removes temporary files
function cleanup {
  echo "Removing $TMPDIR"
  rm -rf "$TMPDIR"
  echo "Removed $TMPDIR"
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
  commandToFile "iptables -L -n" "iptables"
  commandToFile "df -h" "storage"
  commandToFile "docker ps -a" "docker_ps"

  commandToCompressed "journalctl -u admiral_startup --no-pager" "journal_admiral_startup"
  commandToCompressed "journalctl -u admiral --no-pager" "journal_admiral"
  commandToCompressed "journalctl -u harbor_startup --no-pager" "journal_harbor_startup"
  commandToCompressed "journalctl -u harbor --no-pager" "journal_harbor"
  commandToCompressed "journalctl -u fileserver --no-pager" "journal_fileserver"
  commandToCompressed "journalctl -u vic_machine_server --no-pager" "journal_vic_machine_server"

  commandToFile "cat /storage/data/admiral/configs/psc-config.properties" "admiral_data_psc-config"
  commandToFile "cat /etc/vmware/psc/admiral/psc-config.properties" "admiral_psc-config"
  commandToFile "du -k /etc/vmware/psc/admiral/tokens.properties" "admiral_psc-token"
  commandToFile "cat /etc/vmware/psc/engine/psc-config.properties" "engine_psc-config"
  commandToFile "du -k /etc/vmware/psc/engine/tokens.properties" "engine_psc-token"
  commandToFile "cat /etc/vmware/psc/harbor/psc-config.properties" "harbor_psc-config"
  commandToFile "du -k /etc/vmware/psc/harbor/tokens.properties" "harbor_psc-token"


  # Gets the latest log for each component. Additional rotated logs must be retrieved manually.
  # files from /storage/log/*
  getLog "/storage/log/admiral" "*.log"
  getLog "/storage/log/harbor" "*.log"
  getLog "/storage/log/vic-machine-server" "*.log"

  getFailedLogs

  compressBundle
  cleanup
}

main
