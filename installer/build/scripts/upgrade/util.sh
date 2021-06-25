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
    log "Directory $1 already exists. If upgrade to this version is already running or previously completed, data corruption may occur if you proceed."
    while true; do
      log ""
      log "Do you wish to proceed? [y/n]"
      read response
      case $response in
          [Yy] )
              log "Continuing with upgrade"
              log ""
              break
              ;;
          [Nn] )
              log "Exiting without performing upgrade"
              exit 1
              ;;
          *)
              # unknown option
              log "Please enter [y/n]"
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
    log "Detected $1 upgrade was previously completed"
    log "If upgrade to this version is already running or previously completed, data corruption may occur if you proceed."
    while true; do
      log ""
      log "Do you wish to proceed? [y/n]"
      read response
      case $response in
          [Yy] )
              log "Continuing with upgrade"
              log ""
              break
              ;;
          [Nn] )
              log "Exiting without performing upgrade"
              exit 1
              ;;
          *)
              # unknown option
              log "Please enter [y/n]"
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
  local VER_1_2_1="v1.2.1"
  local VALID_VER=($VER_1_2_1 "v1.3.0" "v1.3.1" "v1.4.0" "v1.4.1" "v1.4.2" "v1.4.3" "v1.4.4" "v1.5.0" "v1.5.1" "v1.5.2" "v1.5.3" "v1.5.4" "v1.5.5" "v1.5.6" "v1.5.7")
  local COPIED_DIR="$1"
  local ver=""
  local tag=""

  # No PSC config -> appliance is older than 1.2.0, could be 1.0.x or 1.1.x, refer to these as v1.1.1
  # Remove check for /data after end of 1.2.1 support
  if [ ! -f "$COPIED_DIR/storage/data/admiral/configs/psc-config.properties" ] && [ ! -f "$COPIED_DIR/data/admiral/configs/psc-config.properties" ]; then
    echo $VER_1_1_1
    return
  fi

  # Handle automated disk move check for v1.2.1
  # Remove after end of 1.2.1 support
  if [ -f "$COPIED_DIR/data/version" ]; then
    ver=$(readKeyValue "appliance" "$COPIED_DIR/data/version")
    tag=$(getTagVersion "$ver")
    if [ "$tag" != $VER_1_2_1 ]; then
      log "Invalid version detected from old VIC appliance"
      log "Please contact VMware support"
      exit 1
    fi

    echo $VER_1_2_1
    return
  fi

  # PSC file exists, but no version file in either /storage/data or /data
  if [ ! -f "$COPIED_DIR/storage/data/version" ]; then
    echo $VER_1_2_0
    return
  fi

  ver=$(readKeyValue "appliance" "$COPIED_DIR/storage/data/version")
  tag=$(getTagVersion "$ver")

  # Check for valid versions
  for valid in ${VALID_VER[*]}
  do
    test "$tag" == "$valid" && { echo "$tag"; return; }
  done
  # Version not found
  echo $VER_UNKNOWN
  return
}

function log {
  if [ $REDIRECT_ENABLED -eq 1 ]; then
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") [=] $*" | tee /dev/fd/3
  else
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") [=] $*"
  fi
}

function logn {
  if [ $REDIRECT_ENABLED -eq 1 ]; then
    echo -ne "$(date +"%Y-%m-%d %H:%M:%S") [=] $*" | tee /dev/fd/3
  else
    echo -ne "$(date +"%Y-%m-%d %H:%M:%S") [=] $*"
  fi
}

# Get the fingerprint of vCenter
function getFingerprint() {
  govc about.cert -k -thumbprint
}
