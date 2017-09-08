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

timestamp_file="/registration-timestamps.txt"
register_log_file="/var/log/vmware/register_external_psc.log"
mkdir -p "/var/log/vmware"

TENANT=""
VCENTER_USERNAME=""
VCENTER_PASSWORD=""
DOMAIN_CONTROLLER=""
APPLIANCE_IP=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S %z %Z")
ADMIRAL_URL="https://${APPLIANCE_IP}:8282"


# Register components with PSC
function register {
  clients=(harbor engine admiral)

  for client in "${clients[@]}"; do
    set +e
    java -jar /etc/vmware/admiral/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar \
    --command=register \
    --version=6.0 \
    --configDir=/etc/vmware/psc \
    --clientName="${client}" \
    --tenant="${TENANT}" \
    --username="${VCENTER_USERNAME}" \
    --password="${VCENTER_PASSWORD}" \
    --domainController="${DOMAIN_CONTROLLER}" \
    --admiralUrl="${ADMIRAL_URL}"
    if [ $? -ne 0 ]; then
      echo "Fatal error: Failed register ${client}." | tee /dev/fd/3
      exit 1
    fi
    set -e
  done

}

# Write timestamp so credentials prompt is skipped on Getting Started
function writeTimestamp {
  echo "${TIMESTAMP}" > ${timestamp_file}
}

function usage {
	echo "$(basename "$0") [-h] -- Registers VIC Appliance with an external PSC

required values:
    --username     vCenter Administrator username
    --password     vCenter Administrator password
    --user-domain  SSO Domain name, e.g. vsphere.local
    --psc          PSC FQDN (not IP)
                   If using embedded PSC, the FQDN of vCenter
                   If not using embedded PSC, the FQDN of the external PSC instance"
}

function main {
  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
      --username)
        VCENTER_USERNAME="$2"
        shift # past argument
        ;;
      --password)
        VCENTER_PASSWORD="$2"
        shift # past argument
        ;;
      --user-domain)
        TENANT="$2"
        shift # past argument
        ;;
      --psc)
        DOMAIN_CONTROLLER="$2"
        shift # past argument
        ;;
      --help|-h)
        usage
        exit 1
        ;;
      *)
        usage
        exit 1
        # unknown option
        ;;
    esac
    shift # past argument or value
  done

  if [ -z "${DOMAIN_CONTROLLER}" ] ; then
		echo "If not using an external PSC, enter vCenter FQDN"
    read -p "Enter PSC FQDN (not IP): " DOMAIN_CONTROLLER
  fi

  if [ -z "${VCENTER_USERNAME}" ] ; then
    read -p "Enter vCenter Administrator Username: " VCENTER_USERNAME
  fi

  if [ -z "$VCENTER_PASSWORD" ] ; then
    echo -n "Enter vCenter Administrator Password: "
    read -s VCENTER_PASSWORD
    echo ""
  fi

  if [ -z "${TENANT}" ] ; then
    read -p "Enter user domain: " TENANT
  fi

  if [ -z "${DOMAIN_CONTROLLER}" ] || [ -z "${VCENTER_USERNAME}" ] ||
     [ -z "${VCENTER_PASSWORD}" ] || [ -z "${TENANT}" ] ; then
    echo "Missing required values"
    usage
    exit 1
  fi

  exec 3>&1 1>>${register_log_file} 2>&1
  echo ""
  echo "-------------------------"
  echo "Starting registration with external PSC ${TIMESTAMP}" | tee /dev/fd/3
  register
  writeTimestamp
  echo "Registration script complete. Exiting." | tee /dev/fd/3
  echo "-------------------------"
  echo ""
  exit 0
}

main "$@"
