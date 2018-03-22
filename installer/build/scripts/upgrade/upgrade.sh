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
VCENTER_DATACENTER=""
EXTERNAL_PSC=""
PSC_DOMAIN=""

APPLIANCE_TARGET=""
APPLIANCE_USERNAME=""
DESTROY_ENABLED=""
MANUAL_DISK_MOVE=""

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S %z %Z")

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
      [--dc]:                    VC Target Datacenter of the Old VIC Appliance
      [--external-psc]:          External PSC IP Address.
      [--external-psc-domain]:   External PSC Domain Name.

      [--appliance-username]:    Username of the old appliance.
      [--appliance-target]:      IP Address of the old appliance.
      [--destroy]:               Destroy the old appliance after upgrade is finished.
      [--manual-disks]:          Skip the automated govc disk migration.
    "
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
  max_tab_retries=30 # 5 minutes
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

### Valid upgrade paths to v1.4.0
#   v1.2.1 /data/version has "appliance=v1.2.1"
#   v1.3.0 /storage/data/version has "appliance=v1.3.0-3033-f8cc7317"
#   v1.3.1 /storage/data/version has "appliance=v1.3.1-3409-132fb13d"
###
function proceedWithUpgrade {
  checkUpgradeStatus "VIC Appliance" ${appliance_upgrade_status}
  local ver="$1"

  if [ "$ver" == "$VER_1_2_1" ] || [ "$ver" == "$VER_1_3_0" ] || [ "$ver" == "$VER_1_3_1" ]; then
    echo "" | tee /dev/fd/3
    echo "Detected old appliance's version as $ver." | tee /dev/fd/3
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

  echo "" | tee /dev/fd/3
  echo "Detected old appliance's version $ver as 1.2.0 or older." | tee /dev/fd/3
  echo "Upgrade from this version is not a supported upgrade path." | tee /dev/fd/3
  echo "If the old appliance's version is not detected correctly, please contact VMware support." | tee /dev/fd/3
  exit 1
}

# Copy files from old appliance for version check
function prepareForAutomatedUpgrade {
  local tmpdir="$1"
  local username="$2"
  local ip="$3"

  # Add automation key
  echo "Please enter the VIC appliance password for user $username at ip $ip" | tee /dev/fd/3

  mkdir -p  ~/.ssh
  [ ! -f ~/.ssh/id_rsa ] && ssh-keygen -b 4096 -f ~/.ssh/id_rsa -t rsa -N '' -C 'VIC Appliance Upgrade Automation Key'
  KEY_FILE=$(cat ~/.ssh/id_rsa.pub)
  ssh "$username@$ip" "mkdir -p ~/.ssh/ && echo $KEY_FILE >> ~/.ssh/authorized_keys"

  files=(
    "/etc/vmware/version"
    "/storage/data/version"
    "/storage/data/admiral/configs/psc-config.properties"
    "/data/version"  # Remove after end of 1.2.1 support
    "/data/admiral/configs/psc-config.properties"  # Remove after end of 1.2.1 support
  )
  for file in "${files[@]}"; do
    mkdir -p "$tmpdir$(dirname "$file")"
    set +e  # Copying files from /data will fail, remove after end of 1.2.1 support
    scp "$username@$ip:$file" "$tmpdir$file"
    set -e
  done

  # Remove automation key
  ssh "$username@$ip" "sed -i.bak '/VIC Appliance Upgrade Automation Key/d' ~/.ssh/authorized_keys"
  rm ~/.ssh/id_rsa

  # Expect 3 files in temp dir
  local count=0
  count=$(find "$tmpdir" -type f | wc -l)
  if [ "$count" -ne 3 ]; then
    echo "Failed to gather information about old VIC appliance" | tee /dev/fd/3
    echo "Please contact VMware support" | tee /dev/fd/3
    exit 1
  fi
}

function moveDisks {
  local ver="$1"

  systemctl disable vic-mounts.target
  systemctl stop vic-mounts.target

  # ignore errors if disks are already unmounted.
  ( umount /storage/data /storage/db /storage/log || true ) && echo "Storage disks unmounted."

  myip=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

  OLD_VM_NAME=$(govc vm.info -json -vm.ip $APPLIANCE_TARGET | jq -r ".VirtualMachines[].Name")
  OLD_DATASTORE=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Config.DatastoreUrl[0].Name")
  echo "OLD_VM_NAME: $OLD_VM_NAME"
  echo "OLD_DATASTORE: $OLD_DATASTORE"

  NEW_VM_NAME=$(govc vm.info -json -vm.ip "$myip" | jq -r ".VirtualMachines[].Name")
  NEW_DATASTORE=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Config.DatastoreUrl[0].Name")
  echo "NEW_VM_NAME: $NEW_VM_NAME"
  echo "NEW_DATASTORE: $NEW_DATASTORE"

  if [ -z "$OLD_VM_NAME" ] || [ -z "$OLD_DATASTORE" ] || [ -z "$NEW_VM_NAME" ] || [ -z "$NEW_DATASTORE" ]; then
    echo "Failed to gather environment information about old or new VIC appliance" | tee /dev/fd/3
    echo "Please contact VMware support" | tee /dev/fd/3
    exit 1
  fi

  govc vm.power -s=true "$OLD_VM_NAME"
  while [ "$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Runtime.PowerState")" != "poweredOff" ]; do
    echo "Wating for old VIC appliance to power off" | tee /dev/fd/3
    sleep 15
  done

  # detach new disks
  NEW_DATA_DISK=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[1].DiskFile[0]" | awk '{print $NF}')
  echo "NEW_DATA_DISK: $NEW_DATA_DISK"
  NEW_DB_DISK=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[2].DiskFile[0]" | awk '{print $NF}')
  echo "NEW_DB_DISK: $NEW_DB_DISK"
  NEW_LOG_DISK=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[3].DiskFile[0]" | awk '{print $NF}')
  echo "NEW_LOG_DISK: $NEW_LOG_DISK"

  # TODO Check count
  disks=$(govc device.ls -vm="$NEW_VM_NAME" | grep disk- | tail -n +2 | awk '{print $1}')
  echo "$disks" | while read disk; do
    echo "Remove disk $disk from $NEW_VM_NAME"
    govc device.remove -vm="$NEW_VM_NAME" "$disk"
  done

  echo "Migrating old disks to new VIC appliance..." | tee /dev/fd/3
  OLD_DATA_DISK=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[1].DiskFile[0]" | awk '{print $NF}')
  echo "OLD_DATA_DISK: $OLD_DATA_DISK"
  if [ -z "$OLD_DATA_DISK" ]; then
    echo "Failed to gather information about disks on the old VIC appliance" | tee /dev/fd/3
    echo "Please contact VMware support" | tee /dev/fd/3
    exit 1
  fi

  if [ "$ver" == "$VER_1_3_0" ] || [ "$ver" == "$VER_1_3_1" ]; then
    OLD_DB_DISK=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[2].DiskFile[0]" | awk '{print $NF}')
    echo "OLD_DB_DISK: $OLD_DB_DISK"
    OLD_LOG_DISK=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[3].DiskFile[0]" | awk '{print $NF}')
    echo "OLD_LOG_DISK: $OLD_LOG_DISK"
    if [ -z "$OLD_DB_DISK" ] || [ -z "$OLD_LOG_DISK" ]; then
      echo "Failed to gather information about disks on the old VIC appliance" | tee /dev/fd/3
      echo "Please contact VMware support" | tee /dev/fd/3
      exit 1
    fi
  fi

  echo "Copying old data disk. Please wait." | tee /dev/fd/3
  govc datastore.cp -ds "$OLD_DATASTORE" -ds-target "$NEW_DATASTORE" "$OLD_DATA_DISK" "$NEW_DATA_DISK" || ( echo "Failed to copy data disk. Please try again. Exiting..." | tee /dev/fd/3 && exit 1)
  if [ "$ver" == "$VER_1_3_0" ] || [ "$ver" == "$VER_1_3_1" ]; then
    echo "Copying old database disk. Please wait." | tee /dev/fd/3
    govc datastore.cp -ds "$OLD_DATASTORE" -ds-target "$NEW_DATASTORE" "$OLD_DB_DISK" "$NEW_DB_DISK" || ( echo "Failed to copy database disk. Please try again. Exiting..." | tee /dev/fd/3 && exit 1)
    echo "Copying old log disk. Please wait." | tee /dev/fd/3
    govc datastore.cp -ds "$OLD_DATASTORE" -ds-target "$NEW_DATASTORE" "$OLD_LOG_DISK" "$NEW_LOG_DISK" || ( echo "Failed to copy log disk. Please try again. Exiting..." | tee /dev/fd/3 && exit 1)
  fi

  # TODO rename to new version
  echo "Attaching migrated disks to new VIC appliance"
  govc vm.disk.attach -vm="$NEW_VM_NAME" -ds "$NEW_DATASTORE" -disk "$NEW_DATA_DISK" || (echo "Failed to attach data disk" | tee /dev/fd/3 && exit 1)
  if [ "$ver" == "$VER_1_3_0" ] || [ "$ver" == "$VER_1_3_1" ]; then
    govc vm.disk.attach -vm="$NEW_VM_NAME" -ds "$NEW_DATASTORE" -disk "$NEW_DB_DISK" || (echo "Failed to attach database disk" | tee /dev/fd/3 && exit 1)
    govc vm.disk.attach -vm="$NEW_VM_NAME" -ds "$NEW_DATASTORE" -disk "$NEW_LOG_DISK" || (echo "Failed to attach log disk" | tee /dev/fd/3 && exit 1)
  fi
  echo "Finished attaching migrating disks to new VIC appliance" | tee /dev/fd/3

  echo "Mounting migrated disks" | tee /dev/fd3
  systemctl enable vic-mounts.target
  systemctl start vic-mounts.target
  systemctl --no-block start vic-appliance.target
  echo "Finished mounting migrated disks" | tee /dev/fd3
}

function main {

  echo "-------------------------------" | tee /dev/fd3
  echo "VIC Appliance Upgrade to v1.4.0" | tee /dev/fd3
  echo "-------------------------------" | tee /dev/fd3
  echo "" | tee /dev/fd3
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
      --dc)
        VCENTER_DATACENTER="$2"
        shift
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
        exit 0
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

  export GOVC_TLS_KNOWN_HOSTS=/tmp/govc_known_hosts
  export GOVC_URL="$VCENTER_USERNAME:$VCENTER_PASSWORD@$VCENTER_TARGET"
  fingerprint=$(getFingerprint)
  echo -e "\nPlease verify the vCenter IP and TLS fingerprint: ${fingerprint}"
  read -p "Is the fingerprint correct? (y/n): " resp
  if [ "$resp" != "y" ]; then
    echo "TLS connection is not secure, unable to proceed with upgrade. Please contact VMware support. Exiting..."
    exit 1
  fi
  echo "${fingerprint}" > $GOVC_TLS_KNOWN_HOSTS

  [ -z "${VCENTER_DATACENTER}" ] && read -p "Enter vCenter Datacenter of the old VIC appliance: " VCENTER_DATACENTER
  export GOVC_DATACENTER="$VCENTER_DATACENTER"
  [ -z "${APPLIANCE_TARGET}" ] && read -p "Enter old VIC appliance FQDN or IP: " APPLIANCE_TARGET
  [ -z "${APPLIANCE_USERNAME}" ] && read -p "Enter old VIC appliance username: " APPLIANCE_USERNAME

  if [ -n "${DESTROY_ENABLED}" ] ; then
    local resp=""
    read -p "Destroy option enabled. This will delete the old VIC appliance after upgrade. Are you sure? (y/n):" resp
    if [ "$resp" != "y" ]; then
      echo "Exiting..."
      exit 1
    fi
  fi

  systemctl start docker.service

  exec 3>&1 1>>${upgrade_log_file} 2>&1
  echo -e "\n-------------------------\nStarting upgrade ${TIMESTAMP}" | tee /dev/fd/3

  # default to manual use case, where old disks root is current root.
  OLD_APP_DIR="/"

  # In the automated use case, scp the version files from the old appliance to a tmpdir.
  if [ -z "${MANUAL_DISK_MOVE}" ]; then
    OLD_APP_DIR=$(mktemp -d)
    prepareForAutomatedUpgrade "$OLD_APP_DIR" "$APPLIANCE_USERNAME" "$APPLIANCE_TARGET"
  fi

  ver=$(getApplianceVersion "$OLD_APP_DIR")
  proceedWithUpgrade "$ver"
  if [ -z "${MANUAL_DISK_MOVE}" ]; then
    moveDisks "$APPLIANCE_USERNAME" "$APPLIANCE_TARGET" "$ver"
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
    echo "Destroying the old VIC appliance" | tee /dev/fd/3
    govc vm.destroy "$VM_NAME"
    echo "Old VIC appliance destroyed" | tee /dev/fd/3
  fi

  # TODO: Add Admiral Health Check

  # Completed successfully
  rc=0 # Set good return code
  exit 0
}

function finish() {
  set +e
  if [ "$rc" -eq 0 ]; then
    echo "Upgrade completed successfully. Exiting." | tee /dev/fd/3
    echo "-------------------------" | tee /dev/fd/3
    echo "" | tee /dev/fd/3
  else
    echo "Upgrade failed." | tee /dev/fd/3
    echo "Please save ${upgrade_log_file} and contact VMware support." | tee /dev/fd/3
    echo "-------------------------" | tee /dev/fd/3
    echo "" | tee /dev/fd/3
  fi

  exit $rc
}

rc=1  # Default return code
trap finish EXIT HUP INT TERM

main "$@"
