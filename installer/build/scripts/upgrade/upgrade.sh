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
DEBUG=${DEBUG:-}
set -euf -o pipefail && [ -n "$DEBUG" ] && set -x

# File includes
source /installer.env
. "${0%/*}"/util.sh
. "${0%/*}"/upgrade-admiral.sh
. "${0%/*}"/upgrade-harbor.sh

upgrade_log_file="/var/log/vmware/upgrade.log"
appliance_upgrade_status="/etc/vmware/upgrade_status_1.4.0"
mkdir -p "/var/log/vmware"
timestamp_file="/registration-timestamps.txt"

VCENTER_TARGET=""
VCENTER_USERNAME=""
VCENTER_PASSWORD=""
EXTERNAL_PSC=""
PSC_DOMAIN=""

APPLIANCE_TARGET=""
APPLIANCE_USERNAME=""
DESTROY_ENABLED=""
MANUAL_DISK_MOVE=""

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S %z %Z")

VER_1_1_1="v1.1.1"
VER_1_2_1="v1.2.1"
VER_1_3_0="v1.3.0"
VER_1_3_1="v1.3.1"

function usage {
    echo -e "Usage: $0 [args...]

      All arguments are optional - you will be prompted for them if not entered on the cli.
      [--dbpass]:                Harbor db password.
      [--dbuser]:                Harbor db username.
      [--target]:                VC Target IP Address for psc registration.
      [--username]:              VC Username for psc registration.
      [--password]:              VC Password for psc registration.
      [--external-psc]:          External PSC IP Address.
      [--external-psc-domain]:   External PSC Domain Name.

      [--appliance-username]:    Username of the old appliance.
      [--appliance-target]:      IP Address of the old appliance.
      [--destroy]:               Destroy the old appliance after upgrade is finished.
      [--manual-disks]:          Skip the automated govc disk migration.
    "
    exit 1
}

function callRegisterEndpoint {
  /usr/bin/curl \
    -k \
    --write-out '%{http_code}' \
    --header "Content-Type: application/json" \
    -X POST \
    --data '{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","password":"'"${VCENTER_PASSWORD}"'","externalpsc":"'"${EXTERNAL_PSC}"'","pscdomain":"'"${PSC_DOMAIN}"'"}' \
    https://localhost:9443/register
}

# Register appliance for content trust
function registerAppliance {

  tab_retries=0
  max_tab_retries=6 # 60 seconds
  while [[ "$(callRegisterEndpoint)" != *"200"* && ${tab_retries} -lt ${max_tab_retries} ]]; do
    timecho "Waiting for register appliance..." | tee /dev/fd/3
    sleep 10
    let "tab_retries+=1"
  done

  if [ ${tab_retries} -eq ${max_tab_retries} ]; then
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
  local ver="$1"

  if [ "$ver" == "$VER_1_3_0" ] || [ "$ver" == "$VER_1_3_1" ]; then
    echo "Detected valid upgrade path. Upgrade will perform data migration." | tee /dev/fd/3
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

  echo -n "Detected old appliance's version $ver as 1.2.x or older." | tee /dev/fd/3
  echo -n "Upgrade from this version is not a supported upgrade path." | tee /dev/fd/3
  echo -n "If the old appliance's version is not detected correctly, please contact VMware support." | tee /dev/fd/3
  exit 1
}

function prepareForUpgrade {
  local tmpdir="$1"
  local username="$2"
  local ip="$3"
  # setup ssh access
  echo "Please enter the vic appliance password for user $username at ip $ip" | tee /dev/fd/3
  
  mkdir -p  ~/.ssh
  [ ! -f ~/.ssh/id_rsa ] && ssh-keygen -b 4096 -f ~/.ssh/id_rsa -t rsa -N '' -C 'VIC Appliance Upgrade Automation Key'
  KEY_FILE=$(cat ~/.ssh/id_rsa.pub)
  ssh "$username@$ip" "mkdir -p ~/.ssh/ && echo $KEY_FILE >> ~/.ssh/authorized_keys"

  files=(
    "/etc/vmware/version"
    "/storage/data/version"
    "/storage/data/admiral/configs/psc-config.properties"
  )
  for file in ${files[@]}; do
    mkdir -p "$tmpdir$(dirname $file)"
    scp "$username@$ip":"$file" "$tmpdir$file"
  done

   ssh "$username@$ip" "sed -i.bak '/VIC Appliance Upgrade Automation Key/d' ~/.ssh/authorized_keys"
   rm ~/.ssh/id_rsa
}

function moveDisks {
  systemctl disable vic-mounts.target
  systemctl stop vic-mounts.target
  umount /storage/data /storage/db /storage/log

  myip=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

  OLD_VM_NAME=$(govc vm.info -json -vm.ip $APPLIANCE_TARGET | jq -r ".VirtualMachines[].Name")
  OLD_DATASTORE=$(govc vm.info -json $OLD_VM_NAME | jq -r ".VirtualMachines[].Config.DatastoreUrl[0].Name")

  NEW_VM_NAME=$(govc vm.info -json -vm.ip $myip | jq -r ".VirtualMachines[].Name")
  NEW_DATASTORE=$(govc vm.info -json $NEW_VM_NAME | jq -r ".VirtualMachines[].Config.DatastoreUrl[0].Name")

  govc vm.power -s=true $OLD_VM_NAME

  while [ $(govc vm.info -json $OLD_VM_NAME | jq -r ".VirtualMachines[].Runtime.PowerState") != "poweredOff" ]; do
    echo "Wating for old vm to power off.." | tee /dev/fd/3
    sleep 15
  done

  # detach new disks
  NEW_DATA_DISK=$(govc vm.info -json $NEW_VM_NAME | jq -r ".VirtualMachines[].Layout.Disk[1].DiskFile[0]" | awk '{print $2}')
  NEW_DB_DISK=$(govc vm.info -json $NEW_VM_NAME | jq -r ".VirtualMachines[].Layout.Disk[2].DiskFile[0]" | awk '{print $2}')
  NEW_LOG_DISK=$(govc vm.info -json $NEW_VM_NAME | jq -r ".VirtualMachines[].Layout.Disk[3].DiskFile[0]" | awk '{print $2}')
  disks=$(govc device.ls -vm=$NEW_VM_NAME | grep disk- | tail -n +2 | awk {'print $1'})
  echo $disks | while read disk; do
    govc device.remove -vm=$NEW_VM_NAME $disk
  done

  # copy old disks to new disks
  echo "Migrating old disks to new vic-appliance..." | tee /dev/fd/3
  OLD_DATA_DISK=$(govc vm.info -json $OLD_VM_NAME | jq -r ".VirtualMachines[].Layout.Disk[1].DiskFile[0]" | awk '{print $2}')
  OLD_DB_DISK=$(govc vm.info -json $OLD_VM_NAME | jq -r ".VirtualMachines[].Layout.Disk[2].DiskFile[0]" | awk '{print $2}')
  OLD_LOG_DISK=$(govc vm.info -json $OLD_VM_NAME | jq -r ".VirtualMachines[].Layout.Disk[3].DiskFile[0]" | awk '{print $2}')
  govc datastore.cp -ds $OLD_DATASTORE -ds-target $NEW_DATASTORE $OLD_DATA_DISK $NEW_DATA_DISK || ( echo "Disk copy failed. Please try again. Exiting..." | tee /dev/fd/3 && exit 1)
  govc datastore.cp -ds $OLD_DATASTORE -ds-target $NEW_DATASTORE $OLD_DB_DISK $NEW_DB_DISK || ( echo "Disk copy failed. Please try again. Exiting..." | tee /dev/fd/3 && exit 1)
  govc datastore.cp -ds $OLD_DATASTORE -ds-target $NEW_DATASTORE $OLD_LOG_DISK $NEW_LOG_DISK || ( echo "Disk copy failed. Please try again. Exiting..." | tee /dev/fd/3 && exit 1)

  govc vm.disk.attach -vm=$NEW_VM_NAME -ds $NEW_DATASTORE -disk $NEW_DATA_DISK
  govc vm.disk.attach -vm=$NEW_VM_NAME -ds $NEW_DATASTORE -disk $NEW_DB_DISK
  govc vm.disk.attach -vm=$NEW_VM_NAME -ds $NEW_DATASTORE -disk $NEW_LOG_DISK
  echo "Disk migration successful to new vic-appliance." | tee /dev/fd/3

  systemctl enable vic-mounts.target
  systemctl start vic-mounts.target
  systemctl --no-block start vic-appliance.target
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

  while [ $# -gt 0 ]; do
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
      --appliance-username)
        APPLIANCE_USERNAME="$2"
        shift
        ;;
      --appliance-target)
        APPLIANCE_TARGET="$2"
        shift
        ;;
      --destroy)
        DESTROY_ENABLED="1"
        ;;
      --manual-disks)
        MANUAL_DISK_MOVE="1"
        ;;
      -h|--help|*)
        usage
        ;;
    esac
    shift # past argument or value
  done

  [ -z "${VCENTER_TARGET}" ] && read -p "Enter vCenter Server FQDN or IP: " VCENTER_TARGET
  [ -z "${VCENTER_USERNAME}" ] && read -p "Enter vCenter Administrator Username: " VCENTER_USERNAME
  if [ -z "$VCENTER_PASSWORD" ] ; then
    echo -n "Enter vCenter Administrator Password: "
    read -s VCENTER_PASSWORD
    echo ""
  fi

  [ -z "${EXTERNAL_PSC}" ] && read -p "If using an external PSC, enter the FQDN of the PSC instance (leave blank otherwise): " EXTERNAL_PSC
  [ -z "${PSC_DOMAIN}" ] && read -p "If using an external PSC, enter the PSC Admin Domain (leave blank otherwise): " PSC_DOMAIN

  [ -z "${APPLIANCE_TARGET}" ] && read -p "Enter old VIC appliance FQDN or IP: " APPLIANCE_TARGET
  [ -z "${APPLIANCE_USERNAME}" ] && read -p "Enter old VIC appliance Username: " APPLIANCE_USERNAME

  if [ -n "${DESTROY_ENABLED}" ] ; then
    local resp=""
    read -p "You have set the destroy option. This will delete the old appliance after upgrade. Are you sure? (y/n):" resp
    if [ "$resp" != "y" ]; then
      echo "Exiting..."
      exit 1
    fi
  fi

  thumbprint=$(openssl s_client -connect ${VCENTER_TARGET}:443 < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin)
  echo -e "\nPlease verify the vCenter TLS fingerprint: ${thumbprint}"
  read -p "Is the fingerprint correct? (y/n):" resp
  if [ "$resp" != "y" ]; then
    echo "TLS connection is not secure, unable to proceed with upgrade. Please contact VMware support. Exiting..."
    exit 1
  fi

  export GOVC_INSECURE=1
  export GOVC_URL="$VCENTER_USERNAME:$VCENTER_PASSWORD@$VCENTER_TARGET"

  systemctl start docker.service

  exec 3>&1 1>>${upgrade_log_file} 2>&1
  echo -e "\n-------------------------\nStarting upgrade ${TIMESTAMP}" | tee /dev/fd/3
  
  # default to manual use case, where old disks root is current root.
  OLD_APP_DIR="/"

  # In the automated use case, scp the version files from the old appliance to a tmpdir.
  if [ -z "${MANUAL_DISK_MOVE}" ]; then
    OLD_APP_DIR=$(mktemp -d)
    prepareForUpgrade "$OLD_APP_DIR" "$APPLIANCE_USERNAME" "$APPLIANCE_TARGET"
  fi
  ver=$(getApplianceVersion "$OLD_APP_DIR")
  proceedWithUpgrade $ver
  if [ -z "${MANUAL_DISK_MOVE}" ]; then
    moveDisks "$APPLIANCE_USERNAME" "$APPLIANCE_TARGET"
  fi

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

  if [ -n "${DESTROY_ENABLED}" ] ; then
    echo "Deleting the old appliance..." | tee /dev/fd/3

    govc vm.destroy $VM_NAME

    echo "Old appliance deleted." | tee /dev/fd/3
  fi

  # TODO: Add Admiral Health Check
  echo "Upgrade script complete. Exiting." | tee /dev/fd/3
  echo "-------------------------"
  echo ""
  exit 0
}

main "$@"
