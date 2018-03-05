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

# utility functions that may be used by multiple component upgrade scripts

# Check if directory is present, prompt user to continue
function checkDir {
  if [ -d "$1" ]; then
    echo "Directory $1 already exists. If upgrade to this version is already running or previously completed, data corruption may occur if you proceed." | tee /dev/fd/3
    while true; do
      echo "" | tee /dev/fd/3
      echo "Do you wish to proceed? [y/n]" | tee /dev/fd/3
      read response
      case $response in
          [Yy] )
              echo "Continuing with upgrade" | tee /dev/fd/3
              echo "" | tee /dev/fd/3
              break
              ;;
          [Nn] )
              echo "Exiting without performing upgrade" | tee /dev/fd/3
              exit 1
              ;;
          *)
              # unknown option
              echo "Please enter [y/n]" | tee /dev/fd/3
              ;;
      esac
    done
  fi
}

function readFile {
 cat "$1" ; echo
}

# Check status file, prompt user to continue
function checkUpgradeStatus {
  if [ -f "$2" ]; then
    echo "Detected $1 upgrade was previously completed" | tee /dev/fd/3
    echo "If upgrade to this version is already running or previously completed, data corruption may occur if you proceed." | tee /dev/fd/3
    while true; do
      echo "" | tee /dev/fd/3
      echo "Do you wish to proceed? [y/n]" | tee /dev/fd/3
      read response
      case $response in
          [Yy] )
              echo "Continuing with upgrade" | tee /dev/fd/3
              echo "" | tee /dev/fd/3
              break
              ;;
          [Nn] )
              echo "Exiting without performing upgrade" | tee /dev/fd/3
              exit 1
              ;;
          *)
              # unknown option
              echo "Please enter [y/n]" | tee /dev/fd/3
              ;;
      esac
    done
  fi
  return 0
}

# Generate random password
function genPass {
  openssl rand -base64 32 | shasum -a 256 | head -c 32 ; echo
}

# Return value from key in file
function readKeyValue() {
  local key=$1
  local infile=$2
  local value=""

  if [ ! -f "$infile" ]; then
    echo "$infile does not exist"
    return 1
  fi
  value=$(grep "^$key" "$infile" | cut -d'=' -f2-)
  echo "$value"
}

# Return only the tag version
function getTagVersion() {
  local in=$1
  local value=""
  value=$(echo "$in" | cut -d'-' -f1)
  echo "$value"
}

# Determine appliance version
function getApplianceVersion() {
  local VER_UNKNOWN="unknown"
  local VER_1_1_1="v1.1.1"
  local VER_1_2_0="v1.2.0"
  local VALID_VER=("v1.3.0" "v1.3.1")
  local COPIED_DIR="$1"

  # Appliance is older than 1.2.0, could be 1.0.x or 1.1.x, refer to these as v1.1.1
  if [ ! -f "$COPIED_DIR/storage/data/admiral/configs/psc-config.properties" ]; then
    echo $VER_1_1_1
    return
  fi

  # PSC file exists, but no version file
  if [ ! -f "$COPIED_DIR/storage/data/version" ]; then
    echo $VER_1_2_0
    return
  fi

  local ver=""
  ver=$(readKeyValue "appliance" "$COPIED_DIR/storage/data/version")
  root_ver=$(readKeyValue "appliance" "$COPIED_DIR/etc/vmware/version")
  if [ "${root_ver}" != "${ver}" ]; then
    echo -e "Appliance versions to not match in /storage/data/version and /etc/vmware/version\nExiting..." tee /dev/fd/3 
    exit 1
  fi
  
  tag=$(getTagVersion "$ver")

  # Check for known versions
  for valid in ${VALID_VER[*]}
  do
    test "$tag" == "$valid" && { echo "$tag"; return; }
  done
  # Version not found
  echo $VER_UNKNOWN
  return
}

function timecho {
  echo -e "$(date +"%Y-%m-%d %H:%M:%S") [==] $*"
}
