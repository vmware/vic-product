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
key_file="/root/.ssh/vic-appliance-automation-key"

VCENTER_TARGET=""
VCENTER_USERNAME=""
VCENTER_PASSWORD=""
VCENTER_DATACENTER=""
EXTERNAL_PSC=""
PSC_DOMAIN=""
VCENTER_FINGERPRINT=""
UPGRADE_APPLIANCE_PASSWORD=""

APPLIANCE_TARGET=""
APPLIANCE_USERNAME=""
APPLIANCE_PASSWORD=""
APPLIANCE_VERSION=""

DESTROY_ENABLED=""
MANUAL_DISK_MOVE=""
EMBEDDED_PSC=""
INSECURE_SKIP_VERIFY=""
UPGRADE_UI_PLUGIN=""

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S %z %Z")
export REDIRECT_ENABLED=0

VER_1_2_1="v1.2.1"
VER_1_3_0="v1.3.0"
VER_1_3_1="v1.3.1"
VER_1_4_0="v1.4.0"
VER_1_4_1="v1.4.1"
VER_1_4_2="v1.4.2"
VER_1_4_3="v1.4.3"
VER_1_4_4="v1.4.4"
VER_1_5_0="v1.5.0"
VER_1_5_1="v1.5.1"
VER_1_5_2="v1.5.2"
VER_1_5_3="v1.5.3"
VER_1_5_4="v1.5.4"

function usage {
    echo -e "Usage: $0 [args...]

      All arguments are optional - you will be prompted for required values if not provided.

      Values containing \$ (dollar sign), \` (backquote), \' (single quote), \" (double quote), and \\ (backslash) will not be substituted properly.
      Change any input (passwords) containing these values before running this script.

      [--dbpass value]:                Harbor db password.
      [--dbuser value]:                Harbor db username.
      [--target value]:                VC Target IP Address for PSC registration.
      [--username value]:              VC Username for PSC registration.
      [--password value]:              VC Password for PSC registration.
      [--upgrade-password value]:      Root Password for this appliance.
      [--dc value]:                    VC Target Datacenter of the old VIC Appliance. (Ignored if --manual-disks is specified.)
      [--fingerprint value]:           VC Target fingerprint in GOVC format (govc about.cert -k -thumbprint).

      [--external-psc value]:          External PSC IP Address.
      [--external-psc-domain value]:   External PSC Domain Name.

      [--appliance-username value]:    Username of the old appliance. (Ignored if --manual-disks is specified.)
      [--appliance-password value]:    Password of the old appliance. (Ignored if --manual-disks is specified.)
      [--appliance-target value]:      IP Address of the old appliance. (Ignored if --manual-disks is specified.)
      [--appliance-version value]:     Version of the old appliance. v1.2.1, v1.3.0, v1.3.1, v1.4.0, v1.4.1, v1.4.2, v1.4.3, v1.4.4, v1.5.0 v1.5.1 v1.5.2 v1.5.3 or v1.5.4.

      [--destroy]:                     Destroy the old appliance after upgrade is finished. (Ignored if --manual-disks is specified.)
      [--manual-disks]:                Skip the automated govc disk migration.

      [--embedded-psc]:                Using embedded PSC. Do not prompt for external PSC options.
      [--ssh-insecure-skip-verify]:    Skip host key checking when SSHing to the old appliance.
      [--upgrade-ui-plugin]:           Upgrade ui plugin.
    "
}

# A plugin upgrade is a forced plugin install
function callPluginUpgradeEndpoint {
  local preset=$1
  local vc='{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","password":"'"${VCENTER_PASSWORD}"'","thumbprint":"'"${VCENTER_FINGERPRINT}"'"}'
  local vc_info='{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","thumbprint":"'"${VCENTER_FINGERPRINT}"'"}'
  local plugin='{"preset":"'"${preset}"'","force":true}'
  local app_info='{"vicpassword":"'"${UPGRADE_APPLIANCE_PASSWORD}"'"}'
  local payload='{"vc":'"${vc}"',"appliance":'"${app_info}"',"plugin":'"${plugin}"'}'
  local payload_info='{"vc":'"${vc_info}"',"plugin":'"${plugin}"'}'
  echo "register payload - ${payload_info}" >> $upgrade_log_file 2>&1
  /usr/bin/curl \
    -k \
    -s \
    -o /dev/null \
    --write-out "%{http_code}\\n" \
    --header "Content-Type: application/json" \
    -X POST \
    --data "${payload}" \
    https://localhost:9443/plugin/upgrade
}

function upgradeAppliancePlugin {
  # Upgrade the H5 client...
  tab_retries=0
  ret=$(callPluginUpgradeEndpoint H5)
  while [[ "$ret" != *"204"* && "$ret" != *"5"* && ${tab_retries} -lt ${max_tab_retries} ]]; do
    log "Waiting for appliance h5 plugin upgrade..."
    sleep 10
    let "tab_retries+=1"
    ret=$(callPluginUpgradeEndpoint H5)
  done

  if [[ ${tab_retries} -eq ${max_tab_retries} || "$ret" == *"5"* ]]; then
    log "Failed to upgrade appliance h5 plugin. Check vCenter target settings, or contact VMware support."
    exit 1
  fi
}

function callRegisterEndpoint {
  local payload='{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","password":"'"${VCENTER_PASSWORD}"'","thumbprint":"'"${VCENTER_FINGERPRINT}"'","externalpsc":"'"${EXTERNAL_PSC}"'","pscdomain":"'"${PSC_DOMAIN}"'","vicpassword":"'"${UPGRADE_APPLIANCE_PASSWORD}"'"}'
  local payload_info='{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","thumbprint":"'"${VCENTER_FINGERPRINT}"'","externalpsc":"'"${EXTERNAL_PSC}"'","pscdomain":"'"${PSC_DOMAIN}"'"}'
  echo "register payload - ${payload_info}" >> $upgrade_log_file 2>&1
  /usr/bin/curl \
    -k \
    -s \
    -o /dev/null \
    --write-out "%{http_code}\\n" \
    --header "Content-Type: application/json" \
    -X POST \
    --data "${payload}" \
    https://localhost:9443/register
}

# Register appliance for content trust
function registerAppliance {
  log "Registering the appliance in PSC"
  tab_retries=0
  max_tab_retries=30 # 5 minutes
  while [[ "$(callRegisterEndpoint)" != *"200"* && ${tab_retries} -lt ${max_tab_retries} ]]; do
    log "Waiting for appliance registration..."
    sleep 10
    let "tab_retries+=1"
  done

  if [ ${tab_retries} -eq ${max_tab_retries} ]; then
    log "Failed to register appliance. Check vCenter target and credentials and provided PSC settings."
    exit 1
  fi
}

# Get PSC tokens for SSO integration
function getPSCTokens {
  set +e
  /etc/vmware/psc/get_token.sh
  if [ $? -ne 0 ]; then
    log "Fatal error: Failed to get PSC tokens."
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

# Prevent Admiral and Harbor from starting
function disableServicesStart {
  log "Disabling and stopping Admiral and Harbor"
  systemctl stop admiral.service
  systemctl stop harbor.service
  systemctl stop reconfigure_token.path
  systemctl disable admiral.service
  systemctl disable harbor.service
  systemctl disable reconfigure_token.path
}

# Enable Admiral and Harbor starting
function enableServicesStart {
  log "Enabling and starting Admiral and Harbor"
  systemctl enable admiral.service
  systemctl enable harbor.service
  systemctl enable reconfigure_token.path
  systemctl start admiral.service
  systemctl start harbor.service
  systemctl start reconfigure_token.path
}

### Valid upgrade paths to v1.5.2
#   v1.2.1 /data/version has "appliance=v1.2.1"
#   v1.3.0 /storage/data/version has "appliance=v1.3.0-3033-f8cc7317"
#   v1.3.1 /storage/data/version has "appliance=v1.3.1-3409-132fb13d".
#   v1.4.0 /storage/data/version
#   v1.4.1 /storage/data/version
#   v1.4.2 /storage/data/version
#   v1.4.3 /storage/data/version
#   v1.4.4 /storage/data/version
#   v1.5.0 /storage/data/version
#   v1.5.1 /storage/data/version
###
function proceedWithUpgrade {
  checkUpgradeStatus "VIC Appliance" ${appliance_upgrade_status}
  local ver="$1"

  if [ "$ver" == "$VER_1_2_1" ] || [ "$ver" == "$VER_1_3_0" ] || [ "$ver" == "$VER_1_3_1" ] || [ "$ver" == "$VER_1_4_0" ] || [ "$ver" == "$VER_1_4_1" ] || [ "$ver" == "$VER_1_4_2" ] || [ "$ver" == "$VER_1_4_3" ] || [ "$ver" == "$VER_1_4_4" ] || [ "$ver" == "$VER_1_5_0" ] || [ "$ver" == "$VER_1_5_1" ] || [ "$ver" == "$VER_1_5_2" ] || [ "$ver" == "$VER_1_5_3" ] || [ "$ver" == "$VER_1_5_4" ]; then
    log ""
    log "Detected old appliance's version as $ver."

    if [ -n "${APPLIANCE_VERSION}" ]; then
      if [ "$ver" == "${APPLIANCE_VERSION}" ]; then
        log "Detected old appliance version matches expected value from --appliance-version ${APPLIANCE_VERSION}"
        return # continue with upgrade
      else
        log "Detected old appliance version does not match expected value from --appliance-version ${APPLIANCE_VERSION}"
        log "Exiting without performing upgrade"
        exit 1
      fi
    fi

    log "If the old appliance's version is not detected correctly, please enter \"n\" to abort the upgrade and contact VMware support."
    while true; do
      log ""
      log "Do you wish to proceed with upgrade? [y/n]"
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
    return # continue with upgrade
  fi

  log ""
  log "Detected old appliance's version as $ver."
  log "Upgrade from this version is not a supported upgrade path."
  log "If the old appliance's version is not detected correctly, please contact VMware support."
  exit 1
}

# Copy files from old appliance for version check
function prepareForAutomatedUpgrade {
  mkdir -p  /root/.ssh
  rm -f $key_file
  rm -f ${key_file}.pub
  ssh-keygen -b 4096 -f $key_file -t rsa -N '' -C 'VIC Appliance Upgrade Automation Key'
  pubkey=$(cat ${key_file}.pub)

  local tmpdir="$1"
  local username="$2"
  local ip="$3"
  local add_authorized_key="mkdir -p ~/.ssh/ && echo $pubkey >> ~/.ssh/authorized_keys"

  # Add automation key
  if [ -z "${APPLIANCE_PASSWORD}" ]; then
    log "Please enter the VIC appliance password for $username@$ip"
    if [ -n "${INSECURE_SKIP_VERIFY}" ]; then
      ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$username@$ip" "$add_authorized_key"
    else
      ssh "$username@$ip" "$add_authorized_key"
    fi
  else
    log "Using provided VIC appliance password from --appliance-password"
    if [ -n "${INSECURE_SKIP_VERIFY}" ]; then
      sshpass -p "${APPLIANCE_PASSWORD}" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$username@$ip" "$add_authorized_key"
    else
      sshpass -p "${APPLIANCE_PASSWORD}" ssh "$username@$ip" "$add_authorized_key"
    fi
  fi

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
    if [ -n "${INSECURE_SKIP_VERIFY}" ]; then
      scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $key_file "$username@$ip:$file" "$tmpdir$file"
    else
      scp -i $key_file "$username@$ip:$file" "$tmpdir$file"
    fi
    set -e
  done

  # Remove automation key
  local remove_authorized_key="sed -i.bak '/VIC Appliance Upgrade Automation Key/d' ~/.ssh/authorized_keys"
  if [ -n "${INSECURE_SKIP_VERIFY}" ]; then
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $key_file "$username@$ip" "$remove_authorized_key"
  else
    ssh -i $key_file "$username@$ip" "$remove_authorized_key"
  fi
  rm -f $key_file
  rm -f ${key_file}.pub

  # Expect 3 files in temp dir
  local count=0
  count=$(find "$tmpdir" -type f | wc -l)
  if [ "$count" -ne 3 ]; then
    log "Failed to gather information about old VIC appliance"
    log "Please contact VMware support"
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
    log "Failed to gather environment information about old or new VIC appliance"
    log "Please contact VMware support"
    exit 1
  fi

  govc vm.power -s=true "$OLD_VM_NAME"
  while [ "$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Runtime.PowerState")" != "poweredOff" ]; do
    log "Waiting for old VIC appliance to power off"
    sleep 15
  done

  # detach new disks
  NEW_DATA_DISK=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[1].DiskFile[0]" | awk '{print $NF}')
  echo "NEW_DATA_DISK: $NEW_DATA_DISK"
  NEW_DB_DISK=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[2].DiskFile[0]" | awk '{print $NF}')
  echo "NEW_DB_DISK: $NEW_DB_DISK"
  NEW_LOG_DISK=$(govc vm.info -json "$NEW_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[3].DiskFile[0]" | awk '{print $NF}')
  echo "NEW_LOG_DISK: $NEW_LOG_DISK"

  disks=$(govc device.ls -vm="$NEW_VM_NAME" | grep disk- | tail -n +2 | awk '{print $1}')
  # Expected result:
  # disk-1000-1
  # disk-1000-2
  # disk-1000-3
  count=$(echo "$disks" | wc -l)
  if [ "$count" -ne 3 ]; then
    log "Failed to find the correct number of disks on the new VIC appliance"
    log "Please contact VMware support"
    exit 1
  fi

  echo "$disks" | while read disk; do
    # For 1.2.1 only remove data disk, remove this after end of 1.2.1 support
    if [[ "$disk" =~ -1$ ]]; then
      echo "Remove disk $disk from $NEW_VM_NAME"
      govc device.remove -vm="$NEW_VM_NAME" "$disk"
    fi
    # Only remove log and database disks from 1.3.0 and greater
    if [[ ( "$disk" =~ -2$ || "$disk" =~ -3$ ) && ( "$ver" != "$VER_1_2_1" ) ]]; then
      echo "Remove disk $disk from $NEW_VM_NAME"
      govc device.remove -vm="$NEW_VM_NAME" "$disk"
    fi
  done

  log "Migrating old disks to new VIC appliance..."
  OLD_DATA_DISK=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[1].DiskFile[0]" | awk '{print $NF}')
  echo "OLD_DATA_DISK: $OLD_DATA_DISK"
  if [ -z "$OLD_DATA_DISK" ]; then
    log "Failed to gather information about disks on the old VIC appliance"
    log "Please contact VMware support"
    exit 1
  fi

  if [ "$ver" != "$VER_1_2_1" ]; then
    OLD_DB_DISK=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[2].DiskFile[0]" | awk '{print $NF}')
    echo "OLD_DB_DISK: $OLD_DB_DISK"
    OLD_LOG_DISK=$(govc vm.info -json "$OLD_VM_NAME" | jq -r ".VirtualMachines[].Layout.Disk[3].DiskFile[0]" | awk '{print $NF}')
    echo "OLD_LOG_DISK: $OLD_LOG_DISK"
    if [ -z "$OLD_DB_DISK" ] || [ -z "$OLD_LOG_DISK" ]; then
      log "Failed to gather information about disks on the old VIC appliance"
      log "Please contact VMware support"
      exit 1
    fi
  fi

  log "Copying old data disk. Please wait."
  govc datastore.cp -ds "$OLD_DATASTORE" -ds-target "$NEW_DATASTORE" "$OLD_DATA_DISK" "$NEW_DATA_DISK" || ( log "Failed to copy data disk. Please try again. Exiting..." && exit 1)
  if [ "$ver" != "$VER_1_2_1" ]; then
    log "Copying old database disk. Please wait."
    govc datastore.cp -ds "$OLD_DATASTORE" -ds-target "$NEW_DATASTORE" "$OLD_DB_DISK" "$NEW_DB_DISK" || ( log "Failed to copy database disk. Please try again. Exiting..." && exit 1)
    log "Copying old log disk. Please wait."
    govc datastore.cp -ds "$OLD_DATASTORE" -ds-target "$NEW_DATASTORE" "$OLD_LOG_DISK" "$NEW_LOG_DISK" || ( log "Failed to copy log disk. Please try again. Exiting..." && exit 1)
  fi

  # TODO rename to new version
  echo "Attaching migrated disks to new VIC appliance"
  govc vm.disk.attach -vm="$NEW_VM_NAME" -ds "$NEW_DATASTORE" -disk "$NEW_DATA_DISK" -link=false || (log "Failed to attach data disk" && exit 1)
  if [ "$ver" != "$VER_1_2_1" ]; then
    govc vm.disk.attach -vm="$NEW_VM_NAME" -ds "$NEW_DATASTORE" -disk "$NEW_DB_DISK" -link=false || (log "Failed to attach database disk"  && exit 1)
    govc vm.disk.attach -vm="$NEW_VM_NAME" -ds "$NEW_DATASTORE" -disk "$NEW_LOG_DISK" -link=false || (log "Failed to attach log disk" && exit 1)
  fi
  log "Finished attaching migrated disks to new VIC appliance"

  echo "Mounting migrated disks" | tee /dev/fd3
  systemctl enable vic-mounts.target
  systemctl start vic-mounts.target
  systemctl --no-block start vic-appliance.target
  echo "Finished mounting migrated disks" | tee /dev/fd3
}

function main {

  local new_ver=""
  local tag=""
  new_ver=$(readKeyValue "appliance" "/etc/vmware/version")
  tag=$(getTagVersion "$new_ver")
  echo "-------------------------------" | tee /dev/fd3
  echo "VIC Appliance Upgrade to $tag" | tee /dev/fd3
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
      --upgrade-password)
        UPGRADE_APPLIANCE_PASSWORD="$2"
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
      --fingerprint)
        VCENTER_FINGERPRINT="$2"
        shift # past argument
        ;;
      --appliance-username)
        APPLIANCE_USERNAME="$2"
        shift
        ;;
      --appliance-password)
        APPLIANCE_PASSWORD="$2"
        shift
        ;;
      --appliance-target)
        APPLIANCE_TARGET="$2"
        shift
        ;;
      --appliance-version)
        APPLIANCE_VERSION="$2"
        shift
        ;;
      --destroy)
        DESTROY_ENABLED="1"
        ;;
      --manual-disks)
        MANUAL_DISK_MOVE="1"
        ;;
      --embedded-psc)
        EMBEDDED_PSC="1"
        ;;
      --ssh-insecure-skip-verify)
        INSECURE_SKIP_VERIFY="1"
        ;;
      --upgrade-ui-plugin)
        UPGRADE_UI_PLUGIN="y"
        ;;
      -h|--help|*)
        usage
        exit 0
        ;;
    esac
    shift # past argument or value
  done

  log "Values containing \$ (dollar sign), \` (backquote), \' (single quote), \" (double quote), and \\ (backslash) will not be substituted properly."
  log "Change any input (passwords) containing these values before running this script."

  [ -z "${VCENTER_TARGET}" ] && read -p "Enter vCenter Server FQDN or IP: " VCENTER_TARGET
  [ -z "${VCENTER_USERNAME}" ] && read -p "Enter vCenter Administrator Username: " VCENTER_USERNAME
  if [ -z "$VCENTER_PASSWORD" ] ; then
    echo -n "Enter vCenter Administrator Password: "
    read -s VCENTER_PASSWORD
    echo ""
  fi

  [ -z "${EMBEDDED_PSC}" ] && [ -z "${EXTERNAL_PSC}" ] && read -p "If using an external PSC, enter the FQDN of the PSC instance (leave blank otherwise): " EXTERNAL_PSC
  [ -z "${EMBEDDED_PSC}" ] && [ -z "${PSC_DOMAIN}" ] && read -p "If using an external PSC, enter the PSC Admin Domain (leave blank otherwise): " PSC_DOMAIN

  export GOVC_TLS_KNOWN_HOSTS=/tmp/govc_known_hosts
  export GOVC_URL="$VCENTER_USERNAME:$VCENTER_PASSWORD@$VCENTER_TARGET"

  if [ -z "${VCENTER_FINGERPRINT}" ]; then
    fingerprint=$(getFingerprint)
    echo -e "\nPlease verify the vCenter IP and TLS fingerprint: ${fingerprint}"
    read -p "Is the fingerprint correct? (y/n): " resp
    if [ "$resp" != "y" ]; then
      echo "TLS connection is not secure, unable to proceed with upgrade. Please contact VMware support. Exiting..."
      exit 1
    fi
    export VCENTER_FINGERPRINT="$(echo "${fingerprint}" | awk '{print $2}')"
    echo "${fingerprint}" > $GOVC_TLS_KNOWN_HOSTS
  else
    log "Using provided vCenter fingerprint from --fingerprint ${VCENTER_FINGERPRINT}"
    echo "${VCENTER_FINGERPRINT}" > $GOVC_TLS_KNOWN_HOSTS
    export VCENTER_FINGERPRINT="$(echo "${VCENTER_FINGERPRINT}" | awk '{print $2}')"
  fi

  if [ -z "$UPGRADE_APPLIANCE_PASSWORD" ] ; then
    echo -n "Enter VIC appliance root password: "
    read -s UPGRADE_APPLIANCE_PASSWORD
    echo ""
  fi

  [ -z "${MANUAL_DISK_MOVE}" ] && [ -z "${VCENTER_DATACENTER}" ] && read -p "Enter vCenter Datacenter of the old VIC appliance: " VCENTER_DATACENTER
  export GOVC_DATACENTER="$VCENTER_DATACENTER"
  [ -z "${MANUAL_DISK_MOVE}" ] && [ -z "${APPLIANCE_TARGET}" ] && read -p "Enter old VIC appliance IP: " APPLIANCE_TARGET
  [ -z "${MANUAL_DISK_MOVE}" ] && [ -z "${APPLIANCE_USERNAME}" ] && read -p "Enter old VIC appliance username: " APPLIANCE_USERNAME

  [ -z "${UPGRADE_UI_PLUGIN}" ] && read -p "Upgrade VIC UI Plugin? (y/n): " UPGRADE_UI_PLUGIN

  if [ -z "${MANUAL_DISK_MOVE}" ] && [ -n "${DESTROY_ENABLED}" ] ; then
    local resp=""
    read -p "Destroy option enabled. This will delete the old VIC appliance after upgrade. Are you sure? (y/n): " resp
    if [ "$resp" != "y" ]; then
      echo "Exiting..."
      exit 1
    fi
  fi

  systemctl start docker.service

  exec 3>&1 1>>${upgrade_log_file} 2>&1
  export REDIRECT_ENABLED=1
  log "\n-------------------------\nStarting upgrade ${TIMESTAMP}\n"

  # default to manual use case, where old disks root is current root.
  OLD_APP_DIR="/"

  # In the automated use case, scp the version files from the old appliance to a tmpdir.
  if [ -z "${MANUAL_DISK_MOVE}" ]; then
    OLD_APP_DIR=$(mktemp -d)
    prepareForAutomatedUpgrade "$OLD_APP_DIR" "$APPLIANCE_USERNAME" "$APPLIANCE_TARGET"
  fi

  local ver=""
  ver=$(getApplianceVersion "$OLD_APP_DIR")
  proceedWithUpgrade "$ver"
  if [ -z "${MANUAL_DISK_MOVE}" ]; then
    moveDisks "$ver"
  fi

  log "Preparing upgrade environment"
  disableServicesStart
  registerAppliance
  getPSCTokens

  # Write timestamp so credentials prompt is skipped on Getting Started
  writeTimestamp ${timestamp_file}
  log "Finished preparing upgrade environment"

  ### -------------------- ###
  ###  Component Upgrades  ###
  ### -------------------- ###
  if [ "$UPGRADE_UI_PLUGIN" == "y" ]; then
    log "\n-------------------------\nStarting VIC UI Plugin Upgrade ${TIMESTAMP}\n"
    upgradeAppliancePlugin
  fi

  log "\n-------------------------\nStarting Admiral Upgrade ${TIMESTAMP}\n"
  upgradeAdmiral
  log "\n-------------------------\nStarting Harbor Upgrade ${TIMESTAMP}\n"
  upgradeHarbor "$ver"

  setDataVersion
  writeTimestamp ${appliance_upgrade_status}
  enableServicesStart

  if [ -z "${MANUAL_DISK_MOVE}" ] && [ -n "${DESTROY_ENABLED}" ] ; then
    log "Destroying the old VIC appliance"
    govc vm.destroy "$OLD_VM_NAME"
    log "Old VIC appliance destroyed"
  fi

  # TODO: Add Admiral Health Check

  # Completed successfully
  rc=0 # Set good return code
  exit 0
}

function finish() {
  set +e
  rm -f $key_file
  rm -f ${key_file}.pub
  if [ "$rc" -eq 0 ]; then
    log ""
    log "-------------------------"
    if [ "$UPGRADE_UI_PLUGIN" == "y" ]; then
      log "Upgrade completed successfully. Exiting. All vSphere Client users must log out and log back in again twice to see the vSphere Integrated Containers plug-in."
    else
      log "Upgrade completed successfully. Exiting."
    fi
    log "-------------------------"
    log ""
  else
    log ""
    log "-------------------------"
    log "Upgrade failed."
    log "Please save ${upgrade_log_file} and contact VMware support."
    log "-------------------------"
    log ""
  fi

  exit $rc
}

rc=1  # Default return code
trap finish EXIT HUP INT TERM

main "$@"
