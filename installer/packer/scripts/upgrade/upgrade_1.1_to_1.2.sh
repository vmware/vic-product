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

data_mount="/data/harbor"
cfg="${data_mount}/harbor.cfg"
harbor_backup="/data/harbor_backup"
harbor_migration="/data/harbor_migration"
harbor_psc_token_file="/etc/vmware/psc/harbor/tokens.properties"
admiral_psc_token_file="/etc/vmware/psc/admiral/tokens.properties"

admiral_upgrade_status="/etc/vmware/admiral/upgrade_status"
harbor_upgrade_status="/etc/vmware/harbor/upgrade_status"

DB_USER=""
DB_PASSWORD=""
VCENTER_TARGET=""
VCENTER_USERNAME=""
VCENTER_PASSWORD=""
APPLIANCE_IP=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

MANAGED_KEY="# Managed by configure_harbor.sh"
export LC_ALL="C"

function harborDataSanityCheck {
  harbor_dirs=(
    cert
    database
    job_logs
    registry
  )

  for harbor_dir in "${harbor_dirs[@]}"
  do
    if [ ! -d "$1"/"$harbor_dir" ]; then
      echo "Harbor directory $1/${harbor_dir} not found"
      return 1
    fi
  done

}

# Check if directory is present
function checkDir {
  if [ -d "$1" ]; then
    echo "Directory $1 already exists. If upgrade is not already running or previously completed, remove the directory and retry upgrade."
    exit 1
  fi
}

# Check if required PSC token is present
function checkHarborPSCToken {
  if [ ! -f "${harbor_psc_token_file}" ]; then
    echo "PSC token ${harbor_psc_token_file} not present. Unable to perform data migration to Admiral."
    exit 1
  fi
  if [ ! -s "${harbor_psc_token_file}" ]; then
    echo "PSC token ${harbor_psc_token_file} has zero size. Unable to perform data migration to Admiral."
    exit 1
  fi
}

# Check if required PSC token is present
function checkAdmiralPSCToken {
  if [ ! -f "${admiral_psc_token_file}" ]; then
    echo "PSC token ${admiral_psc_token_file} not present."
    exit 1
  fi
  if [ ! -s "${admiral_psc_token_file}" ]; then
    echo "PSC token ${admiral_psc_token_file} has zero size."
    exit 1
  fi
}

function readFile {
 cat "$1" ; echo
}

# Check if Admiral is running
function checkAdmiralRunning {
  if [ "$(systemctl is-active admiral.service)" != "active" ]; then
    echo "Admiral is not running. Unable to perform data migration to Admiral."
    exit 1
  fi
}

# Check timestamp file, skip if already upgraded
function checkUpgradeStatus {
  if [ -f "$2" ]; then
    echo "$1 upgrade previously completed. Skipping."
    return 1
  fi
  return 0
}

# Generate random password
function genPass {
  openssl rand -base64 32 | shasum -a 256 | head -c 32 ; echo
}

# Add key if it is not present in the config
# Does not handle if key is present, but value unset
function configureHarborCfgUnset {
  local cfg_key=$1
  local cfg_value=$2
  local managed="${3:-false}"
  local line
  line=$(sed -n "/^$cfg_key\s*=/p" $cfg)

  if [ -z "$line" ]; then
    echo "Key not found: $cfg_key, adding key"
    if [ "$managed" = true ]; then
      echo "Setting managed key $cfg_key"
      echo "${MANAGED_KEY}" >> $cfg
      echo "$cfg_key = $cfg_value" >> $cfg
    else
      echo "Setting $cfg_key"
      echo "$cfg_key = $cfg_value" >> $cfg
    fi
  else
    echo "Key found: $cfg_key, skipping"
  fi
}

# Add managed keyword to key if not already managed
function configureHarborCfgManageKey {
  local cfg_key=$1
  local prev_line
  prev_line=$(sed -n "/^$cfg_key\s*=/{x;p;d;}; x" $cfg)
  local line
  line=$(sed -n "/^$cfg_key\s*=/p" $cfg)

  if [ -z "$line" ]; then
    echo "Key not found: $cfg_key"
    return
  fi

  if [[ $prev_line != *"${MANAGED_KEY}"* ]]; then
    echo "Setting managed key $cfg_key"
    sed -i -r "s/^$cfg_key\s*=.*/${MANAGED_KEY}\n$line/g" $cfg
  else
    echo "Key $cfg_key already managed, skipping."
  fi
}

# Upgrade config file in place
function upgradeHarborConfiguration {
  # Add generated clair_db_password as managed key if not present
  configureHarborCfgUnset clair_db_password "$(genPass)" true

  # Add managed tags to db_password and clair_db_password
  configureHarborCfgManageKey db_password
  configureHarborCfgManageKey clair_db_password
}

# https://github.com/vmware/harbor/blob/master/docs/migration_guide.md
function migrateHarborData {
  checkDir ${harbor_backup}
  checkDir ${harbor_migration}
  mkdir ${harbor_backup}
  mkdir ${harbor_migration}

  local migrator_image="vmware/harbor-db-migrator:1.2"
  local harbor_database="/data/harbor/database"

  # Test database connection
  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -v ${harbor_database}:/var/lib/mysql ${migrator_image} test
  if [ $? -ne 0 ]; then
    (>&2 echo "Invalid database credentials")
    exit 1
  fi

  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -v ${harbor_database}:/var/lib/mysql -v ${harbor_backup}:/harbor-migration/backup ${migrator_image} backup
  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -e SKIP_CONFIRM=y -v ${harbor_database}:/var/lib/mysql ${migrator_image} up head
  if [ $? -ne 0 ]; then
    (>&2 echo "Harbor up head command failed")
    exit 1
  fi
  # Overwrites ${harbor_migration}/harbor_projects.json if present
  docker run -ti --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -e EXPORTPATH=/harbor_migration -v ${harbor_migration}:/harbor_migration -v ${harbor_database}:/var/lib/mysql ${migrator_image} export
  if [ $? -ne 0 ]; then
    (>&2 echo "Harbor data export failed")
    exit 1
  fi
}

function admiralImportData {
  checkHarborPSCToken
  /etc/vmware/harbor/admiral_import --admiralendpoint https://localhost:8282 --tokenfile ${harbor_psc_token_file} --projectsfile ${harbor_migration}/harbor_projects.json
  if [ $? -ne 0 ]; then
    (>&2 echo "Importing Harbor data to Admiral failed")
    exit 1
  fi
}

function performAdmiralUpgrade {
  local old_admiral_data="/data/admiral"
  local admiral_cert_location="/data/admiral/cert/server.crt"
  local admiral_key_location="/data/admiral/cert/server.key"
  local admiral_jks_location="/data/admiral/cert/trustedcertificates.jks"

  local new_admiral_data="/data/admiral_new"

  local old_admiral="${APPLIANCE_IP}:8283"
  local new_admiral="${APPLIANCE_IP}:8282"

  local admiral_backup="/etc/vmware/upgrade/admiral_backup.tgz"

  if [ -d $new_admiral_data ]; then
    echo "Admiral upgrade target exists"
    echo "If upgrade is not already running or completed, execute the following command and rerun the upgrade script:"
    echo "    rm -r $new_admiral_data"
    exit 1
  fi
  if [ -f $admiral_backup ]; then
    echo "Admiral upgrade backup exists"
    echo "If upgrade is not already running or completed, execute the following command and rerun the upgrade script:"
    echo "    rm $admiral_backup"
    exit 1
  fi

  mkdir -p $new_admiral_data/configs

  # Copy old certificates to new data
  cp -r $old_admiral_data/cert/. $new_admiral_data/configs

  # Start Admiral v1.1.1
  # https://github.com/vmware/vic/blob/56a309fb855dc29f4dca576aba712c657acb44d0/installer/packer/scripts/admiral/start_admiral.sh
  /usr/bin/docker create -p 8283:8282 \
    --name vic-upgrade-admiral \
    -e ADMIRAL_PORT=8282 \
    -e JAVA_OPTS="-Ddcp.net.ssl.trustStore=/tmp/trusted_certificates.jks -Ddcp.net.ssl.trustStorePassword=changeit" \
    -e XENON_OPTS="--port=-1 --securePort=8282 --certificateFile=/tmp/server.crt --keyFile=/tmp/server.key" \
    -v "$admiral_cert_location:/tmp/server.crt" \
    -v "$admiral_key_location:/tmp/server.key" \
    -v "$admiral_jks_location:/tmp/trusted_certificates.jks" \
    -v "$old_admiral_data/custom.conf:/admiral/config/configuration.properties" \
    -v "$old_admiral_data:/var/admiral" \
    --log-driver=json-file \
    --log-opt max-size=1g \
    --log-opt max-file=10 \
    "vmware/admiral:vic_v1.1.1"
  /usr/bin/docker start vic-upgrade-admiral

  # Copy psc-config.properties to /configs in container
  cp /etc/vmware/psc/admiral/psc-config.properties $new_admiral_data/configs

  local new_admiral_xenon_opts="--publicUri=https://${APPLIANCE_IP}:8282/ --bindAddress=0.0.0.0 --port=-1 --authConfig=/configs/psc-config.properties --securePort=8282 --keyFile=/configs/server.key --certificateFile=/configs/server.crt --startMockHostAdapterInstance=false"

  # Start current Admiral
  docker create -p 8282:8282 \
    --name vic-admiral \
    -v "$new_admiral_data/configs:/configs" \
    -v "$new_admiral_data:/var/admiral" \
    -v "/etc/vmware/psc/admiral:/etc/vmware/psc/admiral" \
    -e ADMIRAL_PORT=-1 \
    -e JAVA_OPTS="-Ddcp.net.ssl.trustStore=/configs/trustedcertificates.jks -Ddcp.net.ssl.trustStorePassword=changeit" \
    -e CONFIG_FILE_PATH="/configs/config.properties" \
    -e XENON_OPTS="$new_admiral_xenon_opts" \
    --log-driver=json-file \
    --log-opt max-size=1g \
    --log-opt max-file=10 \
    "vmware/admiral:ova"
  /usr/bin/docker start vic-admiral

  local psc_token
  psc_token=$(readFile ${admiral_psc_token_file})
  /etc/vmware/admiral/migrate.sh "$old_admiral" "$new_admiral" "$psc_token"
  if [ $? -ne 0 ]; then
    (>&2 echo "Data migration to new Admiral failed")
    exit 1
  fi

  echo "Admiral migration complete"
  docker stop vic-upgrade-admiral
  docker stop vic-admiral

  echo "Archiving previous Admiral data"
  /usr/bin/tar czf $admiral_backup $old_admiral_data
  rm -rf $old_admiral_data
  mv $new_admiral_data $old_admiral_data

  echo "Cleaning up"
  docker rm -f vic-upgrade-admiral
}

function upgradeAdmiral {
  echo "Performing pre-upgrade checks"
  checkAdmiralPSCToken
  checkUpgradeStatus "Admiral" ${admiral_upgrade_status}
  if [ $? -ne 0 ]; then
    # Return to skip Admiral, continue
    return 1
  fi

  if [ -n "$(docker ps -q -f name=vic-upgrade-admiral)" ]; then
    echo "Admiral upgrade container already exists"
    echo "If upgrade is not already running, execute the following command and rerun the upgrade script:"
    echo "    docker rm -f vic-upgrade-admrial"
    exit 1
  fi

  echo "Starting Admiral upgrade"

  echo "[=] Shutting down Harbor and Admiral"
  systemctl stop harbor.service harbor_startup.service
  systemctl stop admiral.service admiral_startup.service
  iptables -A INPUT -p tcp --dport 8282 -j ACCEPT
  iptables -A INPUT -p tcp --dport 8283 -j ACCEPT

  echo "[=] Upgrade Admiral"
  performAdmiralUpgrade

  echo "Admiral upgrade complete"
  # Set timestamp file
  /usr/bin/touch ${admiral_upgrade_status}
  iptables -D INPUT -p tcp --dport 8283 -j ACCEPT

  echo "Starting Admiral"
  systemctl start admiral_startup.service
}

function upgradeHarbor {
  echo "Performing pre-upgrade checks"
  checkUpgradeStatus "Harbor" ${harbor_upgrade_status}
  if [ $? -ne 0 ]; then
    # Return to skip Harbor, continue
    return 1
  fi

  # Perform sanity check on data volume
  if ! harborDataSanityCheck ${data_mount}; then
    echo "Harbor Data is not present in ${data_mount}, can't continue with upgrade operation"
    exit 1
  fi

  checkDir ${harbor_backup}
  checkDir ${harbor_migration}
  checkHarborPSCToken

  # Start Admiral for data migration
  systemctl start admiral_startup.service

  echo "Starting Harbor upgrade"

  echo "[=] Shutting down Harbor"
  systemctl stop harbor_startup.service
  systemctl stop harbor.service

  echo "[=] Migrating Harbor data"
  migrateHarborData
  echo "[=] Finished migrating Harbor data"

  echo "[=] Migrating Harbor configuration"
  upgradeHarborConfiguration
  echo "[=] Finished migrating Harbor configuration"

  echo "[=] Importing project data into Admiral"
  checkAdmiralRunning
  admiralImportData
  echo "[=] Finished importing project data into Admiral"

  echo "Harbor upgrade complete"
  # Set timestamp file
  /usr/bin/touch ${harbor_upgrade_status}

  echo "Starting Harbor"
  systemctl start harbor_startup.service
}

# Register appliance for content trust
function registerAppliance {
  status=$(/usr/bin/curl -k --write-out '%{http_code}' --header "Content-Type: application/json" -X POST --data '{"target":"'"${VCENTER_TARGET}"'","user":"'"${VCENTER_USERNAME}"'","password":"'"${VCENTER_PASSWORD}"'"}' https://localhost:9443/register)
  if [[ "$status" != *"200"* ]]; then
    echo "Failed to register appliance. Check vCenter target and credentials."
    exit 1
  fi
}

# Get PSC tokens for SSO integration
function getPSCTokens {
  /etc/vmware/psc/get_token.sh
  if [ $? -ne 0 ]; then
    echo "Fatal error: Failed to get PSC tokens."
    exit 1
  fi
}

# Prevent Admiral and Harbor from starting from path units
function disableServicesStart {
  echo "Disabling and stopping Admiral and Harbor path startup"
  systemctl stop admiral_startup.path
  systemctl stop harbor_startup.path
  systemctl disable admiral_startup.path
  systemctl disable harbor_startup.path
}

# Enable Admiral and Harbor starting from path units
function enableServicesStart {
  echo "Enabling and starting Admiral and Harbor path startup"
  systemctl enable admiral_startup.path
  systemctl enable harbor_startup.path
  systemctl start admiral_startup.path
  systemctl start harbor_startup.path
}

function main {
  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
      --dbpass)
        DB_PASSWORD="$2"
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
      *)
        # unknown option
        ;;
    esac
    shift # past argument or value
  done

  if [ -z "${DB_USER}" ]; then
    DB_USER="root"
  fi

  if [ -z "${DB_PASSWORD}" ]; then
    echo "--dbpass not set"
    exit 1
  fi

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

  systemctl start docker.service

  echo "Preparing upgrade environment"
  disableServicesStart
  registerAppliance
  getPSCTokens
  echo "Finished preparing upgrade environment"

  upgradeAdmiral
  upgradeHarbor

  enableServicesStart
  echo "Upgrade script complete. Exiting."
  exit 0
}

main "$@"
