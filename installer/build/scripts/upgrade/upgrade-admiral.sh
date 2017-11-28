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

# This file contains upgrade processes specific to the Admiral component.

source /installer.env
. ${0%/*}/util.sh
set -euf -o pipefail

admiral_psc_token_file="/etc/vmware/psc/admiral/tokens.properties"
admiral_upgrade_status_prev="/etc/vmware/admiral/upgrade_status"
APPLIANCE_IP=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

# Check if required PSC token is present
function checkAdmiralPSCToken {
  if [ ! -f "${admiral_psc_token_file}" ]; then
    echo "PSC token ${admiral_psc_token_file} not present." | tee /dev/fd/3
    exit 1
  fi
  if [ ! -s "${admiral_psc_token_file}" ]; then
    echo "PSC token ${admiral_psc_token_file} has zero size." | tee /dev/fd/3
    exit 1
  fi
}

# Upgrade entry point from upgrade.sh
function upgradeAdmiral {
  echo "Performing pre-upgrade checks" | tee /dev/fd/3
  checkAdmiralPSCToken

  # Remove files from old upgrade
  if [ -f "${admiral_upgrade_status_prev}" ]; then
    rm -rf "${admiral_upgrade_status_prev}"
  fi

  echo "Starting Admiral upgrade" | tee /dev/fd/3
  systemctl start admiral_startup.service
  echo "Updating Admiral configuration" | tee /dev/fd/3
  curl \
    -s --insecure \
    -X PUT \
    -H "x-xenon-auth-token: $(cat /etc/vmware/psc/admiral/tokens.properties)" \
    -H 'cache-control: no-cache' \
    -H 'content-type: application/json' \
    -d "{ \"key\" : \"harbor.tab.url\", \"value\" : \"$(grep harbor.tab.url /storage/data/admiral/configs/config.properties | cut -d'=' -f2)\" }" \
    "https://${APPLIANCE_IP}:8282/config/props/harbor.tab.url" ; \
  systemctl restart admiral.service

  sleep 5
}
