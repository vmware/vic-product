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

# This file contains upgrade processes specific to the Harbor component.
set -euf -o pipefail && [ -n "$DEBUG" ] && set -x
source /installer.env
. "${0%/*}"/util.sh

harbor_data_mount="/storage/data/harbor"
harbor_db_mount="/storage/db/harbor"
harbor_cfg="${harbor_data_mount}/harbor.cfg"
harbor_database="${harbor_db_mount}/database"
harbor_psc_token_file="/etc/vmware/psc/harbor/tokens.properties"
harbor_upgrade_status="/etc/vmware/harbor/upgrade_status"
harbor_backup="/storage/data/harbor_backup"
harbor_migrator_image=$(docker images goharbor/harbor-migrator --format "{{.Repository}}:{{.Tag}}")
DB_USER=""
DB_PASSWORD=""

VER_1_2_1="v1.2.1"

# Configure attr in harbor.cfg
MANAGED_KEY="# Managed by configure_harbor.sh"

# Cleanup files from previous upgrade operations
function cleanupFiles {
  files=(
    ${harbor_backup}
    ${harbor_upgrade_status}
  )
  for file in "${files[@]}"; do
    if [ -e "${file}" ]; then
      rm -rf "${file}"
    fi
  done
}

# Returns value from cfg given key to search for
# Stored in cfg as key = value
function readHarborCfgKey {
  local cfg_key=$1
  local  __resultvar=$2
  local value
  value=$(grep "^$cfg_key " $harbor_cfg | cut -d' ' -f 3 | xargs)

  if [ -z "$value" ]; then
      echo "Key not found: $cfg_key"
    else
      eval "$__resultvar"="'$value'"
    fi
}

# Check if required PSC token is present
function checkHarborPSCToken {
  if [ ! -f "${harbor_psc_token_file}" ]; then
    log "PSC token ${harbor_psc_token_file} not present. Unable to perform data migration to Harbor."
    exit 1
  fi
  if [ ! -s "${harbor_psc_token_file}" ]; then
    log "PSC token ${harbor_psc_token_file} has zero size. Unable to perform data migration to Harbor."
    exit 1
  fi
}

function migrateHarborCfg {
  log "Back up harbor data to : ${harbor_backup}"
  tar czf "${harbor_backup}/database.tar.gz" "${harbor_database}"
  tar czf "${harbor_backup}/data.tar.gz" "${harbor_data_mount}"
  log "harbor-migrator version: ${harbor_migrator_image}"
  docker run --rm -e SKIP_CONFIRM=y -v ${harbor_cfg}:/harbor-migration/harbor-cfg/harbor.cfg ${harbor_migrator_image} --cfg up
}
# Run the harbor migrator docker image
function runMigratorCmd {
  log "harbor-migrator version: ${harbor_migrator_image}"

  docker run -i \
    -e DB_USR=${DB_USER} \
    -e DB_PWD=${DB_PASSWORD} \
    -e SKIP_CONFIRM=y \
    -v ${harbor_database}:/var/lib/mysql \
    -v ${harbor_cfg}:/harbor-migration/harbor-cfg/harbor.cfg \
    -v ${harbor_backup}:/harbor-migration/backup \
    ${harbor_migrator_image} "$@"

  if [ $1 == "up" ]; then
    docker run -i \
      -e DB_USR=${DB_USER} \
      -e SKIP_CONFIRM=y \
      -v ${harbor_db_mount}/notary-db/:/var/lib/mysql \
      -v ${harbor_database}:/var/lib/postgresql/data \
      -v ${harbor_cfg}:/harbor-migration/harbor-cfg/harbor.cfg \
      -v ${harbor_backup}:/harbor-migration/backup \
      ${harbor_migrator_image} up

    docker run -i \
      -e SKIP_CONFIRM=y \
      -v ${harbor_db_mount}/clair-db/:/clair-db \
      -v ${harbor_database}:/var/lib/postgresql/data \
      -v ${harbor_cfg}:/harbor-migration/harbor-cfg/harbor.cfg \
      -v ${harbor_backup}:/harbor-migration/backup \
      ${harbor_migrator_image} up
  fi
}

# https://github.com/goharbor/harbor/blob/master/docs/migration_guide.md
function migrateHarbor {
  major_ver=$(echo ${HARBOR_VER:1:3} | tr -d '.')
  # Only upgrade harbor configure if VIC version >= 1.5.0
  if [[ "${major_ver}" -ge 15 ]]; then
    migrateHarborCfg
    exit 0
  fi
  if [ "$HARBOR_VER" == "$VER_1_2_1" ]; then
    harbor_old_database_dir="/storage/data/harbor"
    mkdir -p "${harbor_db_mount}"
    DIR="database";  mv "${harbor_old_database_dir}/$DIR" "${harbor_db_mount}"
    DIR="clair-db";  mv "${harbor_old_database_dir}/$DIR" "${harbor_db_mount}"
    DIR="notary-db"; mv "${harbor_old_database_dir}/$DIR" "${harbor_db_mount}"
  fi

  # Test database connection
  # Subshell to preserve -e
  log "Testing database credentials..."
  ( runMigratorCmd "test" )
  if [ $? -ne 0 ]; then
    log "Invalid database credentials"
    exit 1
  fi

  log "Backing up harbor config..."
  ( runMigratorCmd "backup" )
    if [ $? -ne 0 ]; then
    log "Harbor backup failed..."
    exit 1
  fi

  ( runMigratorCmd "up" )
  if [ $? -ne 0 ]; then
    log "Harbor up head command failed"
    log "Restoring from backup..."
    runMigratorCmd "restore"
    log "Backup restored. Exiting..."
    exit 1
  fi

  # Preserve the managed keys from configure_harbor.sh
  keys=(
    db_password
    clair_db_password
  )
  for cfg_key in "${keys[@]}"; do
    sed -i -r "s/^$cfg_key\s*=/${MANAGED_KEY}\n$cfg_key =/g" $harbor_cfg
  done;
  chmod 600 ${harbor_cfg}
  /etc/vmware/upgrade/notary-migration-fix.sh
}

# Upgrade entry point from upgrade.sh
function upgradeHarbor {
  export HARBOR_VER="$1"

  if [ -z "${DB_USER}" ]; then
    DB_USER="root"
  fi

  if [ -z "${DB_PASSWORD}" ]; then
    echo "Getting password from harbor.cfg"
    readHarborCfgKey db_password DB_PASSWORD
  fi

  # If DB_PASSWORD not set by cfg, exit
  if [ -z "${DB_PASSWORD}" ]; then
    echo "--dbpass not set and value not found in $harbor_cfg"
    exit 1
  fi

  log "Performing pre-upgrade checks"
  checkDir ${harbor_backup}
  cleanupFiles
  mkdir -p ${harbor_backup}
  checkHarborPSCToken

  # Start Admiral for data migration
  systemctl start admiral.service

  log "Starting Harbor upgrade"

  log "[=] Shutting down Harbor"
  systemctl stop harbor.service

  log "[=] Migrating Harbor configuration and data"
  # subshell to capture -e
  ( migrateHarbor )
  if [ $? -ne 0 ]; then
    log "[=] Harbor migration failed from the old VIC Appliance"
    log "[=] Please contact VMware support"
    exit 1
  fi

  log "[=] Successfully migrated Harbor configuration and data"
  log "Harbor upgrade complete"

  log "Starting Harbor"
  systemctl start harbor.service
}
