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

TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
DIRNAME="vic_appliance_logs_$TIMESTAMP"
OUTFILE="$DIRNAME.tar.gz"
TMPDIR="/tmp/$DIRNAME"
OUTDIR="/storage/log/"

mkdir -p "$TMPDIR"

# commandToFile runs command $1 and writes the output to file $2 in $TMPDIR
function commandToFile {
  local OUTDIR
  local DIR="${3:-}"
  if [ -n "$DIR" ]; then
    OUTDIR="$TMPDIR/$DIR"
    mkdir -p "$OUTDIR"
  else
    OUTDIR="$TMPDIR"
  fi

  echo "Running $1"
  set +e
  $1 &> "$OUTDIR/$2"
  set -e
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
  set +e
  $1 | gzip > "$OUTDIR/$2.gz"
  set -e
}

# getLog copies files with suffix to component directory in $TMPDIR
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

# getPrivateFiles includes files that may contain secret values
function getPrivateFiles {
  echo "Including private values in log bundle"

  commandToFile "cat /storage/data/harbor/config/config.json" "harbor_config.json"
  commandToFile "openssl x509 -in /storage/data/certs/ca.crt -text -noout" "ca.crt" "certs"
  commandToFile "openssl x509 -in /storage/data/certs/server.cert.pem -text -noout" "server.cert.pem" "certs"
  commandToFile "cat /storage/data/certs/cert_gen_type" "cert_gen_type" "certs"
  commandToFile "cat /storage/data/certs/extfile.cnf" "extfile.cnf" "certs"
  commandToFile "openssl x509 -in /storage/data/admiral/cert/ca.crt -text -noout" "ca.crt" "admiral_certs"
  commandToFile "openssl x509 -in /storage/data/admiral/cert/server.crt -text -noout" "server.crt" "admiral_certs"
  commandToFile "cat /storage/data/admiral/cert/extfile.cnf" "extfile.cnf" "admiral_certs"
}

# getDiagInfo gathers diagnostic info and logs
function getDiagInfo {
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
  commandToFile "df -h" "df"
  commandToFile "docker ps -a" "docker_ps"
  commandToFile "docker images" "docker_images"

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

	commandToFile "cat /storage/data/admiral/configs/config.properties" "admiral_config.properties"
  commandToFile "cat /storage/data/admiral/8282/serviceHostState.json" "admiral_serviceHostState.json"

  # Gets the latest log for each component. Additional rotated logs must be retrieved manually.
  getLog "/storage/log/admiral" "*.log"
  getLog "/storage/log/harbor" "*.log"
  getLog "/storage/log/vic-machine-server" "*.log"

  getFailedLogs

  if [ "$INC_PRIVATE" == "true" ]; then
    getPrivateFiles
  fi
}

# compressBundle creates the log bundle tar
function compressBundle {
  checkStorage "$OUTDIR"
  # TODO ATC FIXME use RC to cleanup and exit
  local DIR
  echo "Creating log bundle $OUTDIR/$OUTFILE"
  tar -czvf "$OUTDIR/$OUTFILE" -C /tmp "$DIRNAME"
  echo "--------------------"
  echo "Created log bundle $OUTDIR/$OUTFILE"
  if [ "$INC_PRIVATE" == "true" ]; then
    echo "Log bundle contains files with private values"
  fi
  echo "--------------------"
}

# checkStorage checks that there is a reasonable amount of disk space left
# does not guarantee that there is enough space for the log bundle or temporary files
function checkStorage {
	local FREE
  FREE=$(df -k --output=avail "$1" | tail -n1)
  if [ "$FREE" -lt 100000000 ]; then
  # TODO ATC FIXME
  #if [ "$FREE" -lt 524288 ]; then
  echo "--------------------"
    echo "Warning: less than 512MB free on $1"
    if [ "$IGNORE_SPACE" == "true" ]; then
			echo "Ignoring low free space on $1"
      echo "--------------------"
      return 0
		else
	    echo "Free up space on $1 or override warning with --ignore-space"
      echo "--------------------"
      return 1
    fi
  fi
  return 0
}

# cleanup removes temporary files
function cleanup {
  echo "Removing $TMPDIR"
  rm -rf "$TMPDIR"
  echo "Removed $TMPDIR"
}

function usage {
  echo "Usage:"
  echo "$0 [--include-private] [--outdir <directory>]"
  echo ""
  echo "--include-private:    includes files containing private values in the log bundle"
  echo "--outdir <directory>: directory to store the resulting log bundle"
  echo ""
}

function main {
  while [[ $# -gt 0 ]]
  do
    key="$1"

    case $key in
      -h|--help)
        usage
        exit 0
        ;;
      --include-private)
        INC_PRIVATE="true"
        echo "Including files containing private values in log bundle"
        shift # past argument
        ;;
      --ignore-space)
        IGNORE_SPACE="true"
        echo "Bypassing warnings for low disk space"
        shift # past argument
        ;;
      --outdir)
        OUTDIR="$2"
        shift # past argument
        shift # past value
        ;;
      *)
        # unknown option
        echo "Unknown option"
        usage
        exit 1
        ;;
    esac
  done

  INC_PRIVATE=${INC_PRIVATE:-false}
  IGNORE_SPACE=${IGNORE_SPACE:-false}

	if [ ! -d "$OUTDIR" ]; then
		echo "--outdir $OUTDIR must exist"
    exit 1
	fi

  # TODO FIXME ATC use RC to exit
	checkStorage "$TMPDIR"
  checkStorage "$OUTDIR"
  getDiagInfo
  compressBundle
  cleanup
}

main "$@"
