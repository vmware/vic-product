#!/usr/bin/bash
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
psc_token_file="/etc/vmware/psc/harbor/tokens.properties"

DB_USER=""
DB_PASSWORD=""

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
    echo "Directory $1 already exists. Please remove and retry upgrade."
    exit 1
  fi
}

# Check if required PSC token is present
function checkHarborPSCToken {
  if [ ! -f "${psc_token_file}" ]; then
    echo "PSC token ${psc_token_file} not present. Unable to perform data migration to Admiral."
    exit 1
  fi
}

# Check if Admiral is running
function checkAdmiralRunning {
  if [ "$(systemctl is-active admiral.service)" != "active" ]; then
    echo "Admiral is not running. Unable to perform data migration to Admiral."
    exit 1
  fi
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

  # TODO FIXME ATC Change to real image
  local migrator_image="vmware/harbor-db-migrator:1.2-test"
  local harbor_database="/data/harbor/database"

  # Test database connection
  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -v ${harbor_database}:/var/lib/mysql ${migrator_image} test
  if [ $? -ne 0 ]; then
    (>&2 echo "Invalid database credentials")
    exit 1
  fi

  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -v ${harbor_database}:/var/lib/mysql -v ${harbor_backup}:/harbor-migration/backup ${migrator_image} backup
  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -e SKIP_CONFIRM=y -v ${harbor_database}:/var/lib/mysql ${migrator_image} up head
  # Overwrites ${harbor_migration}/harbor_projects.json if present
  docker run -ti --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -e EXPORTPATH=/harbor_migration -v ${harbor_migration}:/harbor_migration -v ${harbor_database}:/var/lib/mysql ${migrator_image} export

  if [ $? -ne 0 ]; then
    (>&2 echo "Harbor data export failed")
    exit 1
  fi
}

function admiralImportData {
  checkHarborPSCToken
  /etc/vmware/harbor/admiral_import --admiralendpoint https://localhost:8282 --tokenfile ${psc_token_file} --projectsfile ${harbor_migration}/harbor_projects.json
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

  echo "Performing sanity check..."

  # Perform sanity check on data volume
  if ! harborDataSanityCheck ${data_mount}; then
    echo "Harbor Data is not present in ${data_mount}, can't continue with upgrade operation"
    exit 1
  fi

  checkDir ${harbor_backup}
  checkDir ${harbor_migration}
  checkHarborPSCToken
  checkAdmiralRunning

  # Start migration
  echo "Starting migration"
  systemctl start docker.service
  sleep 2

  echo "[=] Shutting down Harbor"
  systemctl stop harbor_startup.service
  systemctl stop harbor.service

  echo "[=] Migrating Harbor data"
  migrateHarborData

  echo "[=] Migrating Harbor configuration"
  upgradeHarborConfiguration

  echo "[=] Importing project data into Admiral"
  admiralImportData

  echo "Upgrade complete."

  echo "Starting Harbor"
  systemctl start harbor.service
}

main "$@"
