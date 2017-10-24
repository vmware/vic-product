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

# Check if directory is present
function checkDir {
  if [ -d "$1" ]; then
    echo "Directory $1 already exists. If upgrade is not already running or previously completed, remove the directory and retry upgrade." | tee /dev/fd/3
    exit 1
  fi
}

function readFile {
 cat "$1" ; echo
}

# Check timestamp file, skip if already upgraded
function checkUpgradeStatus {
  if [ -f "$2" ]; then
    echo "$1 upgrade status show previously completed" | tee /dev/fd/3
    echo "If upgrade is not already running or completed, execute the following command and rerun the upgrade script:" | tee /dev/fd/3
    echo "    rm $2" | tee /dev/fd/3
    return 1
  fi
  return 0
}

# Generate random password
function genPass {
  openssl rand -base64 32 | shasum -a 256 | head -c 32 ; echo
}