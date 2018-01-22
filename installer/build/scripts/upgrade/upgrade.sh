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

# This file contains general upgrade processes for the ova appliance, such as psc registration and data versioning.
# File includes
source /installer.env
. "${0%/*}"/util.sh
. "${0%/*}"/upgrade-admiral.sh
. "${0%/*}"/upgrade-harbor.sh

set -euf -o pipefail

upgrade_log_file="/var/log/vmware/upgrade.log"
appliance_upgrade_status="/etc/vmware/upgrade_status_1.3.0"
mkdir -p "/var/log/vmware"
timestamp_file="/registration-timestamps.txt"

VCENTER_TARGET=""
VCENTER_USERNAME=""
VCENTER_PASSWORD=""
EXTERNAL_PSC=""
PSC_DOMAIN=""
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S %z %Z")

VER_1_1_1="v1.1.1"
VER_1_2_1="v1.2.1"
VER_1_3_0="v1.3.0"

# Register appliance for content trust
function registerAppliance {
  status=$(/usr/bin/curl -k --write-out '%{http_code}' --header "Content-Type: application/json" -X POST --data '{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","password":"'"${VCENTER_PASSWORD}"'","externalpsc":"'"${EXTERNAL_PSC}"'","pscdomain":"'"${PSC_DOMAIN}"'"}' https://localhost:9443/register)
  if [[ "$status" != *"200"* ]]; then
    echo "Failed to register appliance. Check vCenter target and credentials and provided PSC settings." | tee /dev/fd/3
    exit 1
  fi
}

# Get PSC tokens for SSO integration
function getPSCTokens {
  set +e
  /etc/vmware/psc/get_token.sh
  if [ $? -ne 0 ]; then
    echo "Fatal error: Failed to get PSC tokens." | tee /dev/fd/3
    exit 1
  fi
  set -e
}

# Write timestamp to a file
function writeTimestamp {
  echo "${TIMESTAMP}" > "$1"
}

# Copy the appliance version to /storage/data after successful upgrade
function setDataVersion {
  appliance_ver="/etc/vmware/version"
  data_ver="/storage/data/version"

  if [ -f ${data_ver} ]; then
    old_data_ver=$(readFile ${data_ver})
    echo "Old data version: ${old_data_ver}"
  fi

  cp -f ${appliance_ver} ${data_ver}
  new_data_ver=$(readFile ${data_ver})
  echo "Set new data version: ${new_data_ver}"
}

# Prevent Admiral and Harbor from starting from path units
function disableServicesStart {
  echo "Disabling and stopping Admiral and Harbor" | tee /dev/fd/3
  systemctl stop admiral.service
  systemctl stop harbor.service
  systemctl disable admiral.service
  systemctl disable harbor.service
}

# Enable Admiral and Harbor starting from path units
function enableServicesStart {
  echo "Enabling and starting Admiral and Harbor" | tee /dev/fd/3
  systemctl enable admiral.service
  systemctl enable harbor.service
  systemctl start admiral.service
  systemctl start harbor.service
}


### Valid upgrade paths to v1.3.1
#   v1.2.1 /data/version has "appliance=v1.2.1"
#   v1.3.0 /storage/data/version has "appliance=v1.3.0-3033-f8cc7317"
###
function proceedWithUpgrade {
  checkUpgradeStatus "VIC Appliance" ${appliance_upgrade_status}
  local ver=""
  ver=$(getApplianceVersion)
  if [ "$ver" == "$VER_1_1_1" ]; then
    echo -n "Detected old appliance's version as 1.1.x or older." | tee /dev/fd/3
  else
    echo "Detected old appliance's version as $ver" | tee /dev/fd/3
  fi

  if [ "$ver" == "$VER_1_2_1" ] || [ "$ver" == "$VER_1_3_0" ]; then
    echo "Detected valid upgrade path. Upgrade will perform data migration, but previous component logs won't be transferred." | tee /dev/fd/3
    echo -n "If the old appliance's version is not detected correctly, please enter \"n\" to abort the upgrade and contact VMware support." | tee /dev/fd/3
    while true; do
      echo "" | tee /dev/fd/3
      echo "Do you wish to proceed with upgrade? [y/n]" | tee /dev/fd/3
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
    return # continue with upgrade
  fi

  echo -n "Upgrade from this version is not a supported upgrade path."
  echo -n "If the old appliance's version is not detected correctly, please contact VMware support." | tee /dev/fd/3
  exit 1
}

function main {

  ### ------------------ ###
  ###  Appliance Upgrade ###
  ### ------------------ ###

  firstboot="/etc/vmware/firstboot"
  if [ ! -f "$firstboot" ]; then
    echo "Appliance services not ready. Please wait until vic-appliance-load-docker-images.service has completed."
    exit 1
  fi

  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
      --dbpass)
        DB_PASSWORD="$2"
        echo "--dbpass overriding stored password"
        shift # past argument
        ;;
      --dbuser)
        DB_USER="$2"
        shift # past argument
        ;;
      --target)
        VCENTER_TARGET="$2"
        shift # past argument
        ;;
      --username)
        VCENTER_USERNAME="$2"
        shift # past argument
        ;;
      --password)
        VCENTER_PASSWORD="$2"
        shift # past argument
        ;;
      --external-psc)
          EXTERNAL_PSC="$2"
          shift # past argument
          ;;
      --external-psc-domain)
          PSC_DOMAIN="$2"
          shift # past argument
          ;;
      *)
        # unknown option
        ;;
    esac
    shift # past argument or value
  done

  if [ -z "${VCENTER_TARGET}" ] ; then
    read -p "Enter vCenter Server FQDN or IP: " VCENTER_TARGET
  fi

  if [ -z "${VCENTER_USERNAME}" ] ; then
    read -p "Enter vCenter Administrator Username: " VCENTER_USERNAME
  fi

  if [ -z "$VCENTER_PASSWORD" ] ; then
    echo -n "Enter vCenter Administrator Password: "
    read -s VCENTER_PASSWORD
    echo ""
  fi

  if [ -z "${EXTERNAL_PSC}" ] ; then
      read -p "If using an external PSC, enter the FQDN of the PSC instance (leave blank otherwise): " EXTERNAL_PSC
  fi

  if [ -z "${PSC_DOMAIN}" ] ; then
      read -p "If using an external PSC, enter the PSC Admin Domain (leave blank otherwise): " PSC_DOMAIN
  fi

  systemctl start docker.service

  exec 3>&1 1>>${upgrade_log_file} 2>&1
  echo -e "\n-------------------------\nStarting upgrade ${TIMESTAMP}" | tee /dev/fd/3

  proceedWithUpgrade

  echo "Preparing upgrade environment" | tee /dev/fd/3
  disableServicesStart
  registerAppliance
  getPSCTokens

  # Write timestamp so credentials prompt is skipped on Getting Started
  writeTimestamp ${timestamp_file}
  echo "Finished preparing upgrade environment" | tee /dev/fd/3

  ### -------------------- ###
  ###  Component Upgrades  ###
  ### -------------------- ###
  echo -e "\n-------------------------\nStarting Admiral Upgrade ${TIMESTAMP}\n" | tee /dev/fd/3
  upgradeAdmiral
  echo -e "\n-------------------------\nStarting Harbor Upgrade ${TIMESTAMP}\n" | tee /dev/fd/3
  upgradeHarbor

  setDataVersion
  writeTimestamp ${appliance_upgrade_status}
  enableServicesStart
  echo "Upgrade script complete. Exiting." | tee /dev/fd/3
  echo "-------------------------"
  echo ""
  exit 0
}

main "$@"
