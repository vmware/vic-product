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

DB_USER=""
DB_PASSWORD=""

HARBOR_VER_1_2_1="harbor-offline-installer-v1.2.1.tgz"

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
    echo "PSC token ${harbor_psc_token_file} not present. Unable to perform data migration to Harbor." | tee /dev/fd/3
    exit 1
  fi
  if [ ! -s "${harbor_psc_token_file}" ]; then
    echo "PSC token ${harbor_psc_token_file} has zero size. Unable to perform data migration to Harbor." | tee /dev/fd/3
    exit 1
  fi
}

# Run the harbor migrator docker image
# TODO(morris-jason): remove the test tag
function runMigratorCmd {
  local migrator_image="vmware/harbor-migrator:v1.5.0-test"

  docker run -it --rm \
    -e DB_USR=${DB_USER} \
    -e DB_PWD=${DB_PASSWORD} \
    -e SKIP_CONFIRM=y \
    -v ${harbor_database}:/var/lib/mysql \
    -v ${harbor_data_mount}:/harbor-migration/harbor-cfg \
    -v ${harbor_backup}:/harbor-migration/backup \
    ${migrator_image} "$@"
}

# https://github.com/vmware/harbor/blob/master/docs/migration_guide.md
function migrateHarbor {
  HARBOR_VER=$(readKeyValue "harbor" "/storage/data/version")
  if [ "$HARBOR_VER" != "$HARBOR_VER_1_2_1" ]; then
    harbor_old_database_dir="/storage/data/harbor"
    mkdir -p "${harbor_db_mount}"
    DIR="database";  mv "${harbor_old_database_dir}/$DIR" "${harbor_db_mount}"
    DIR="clair-db";  mv "${harbor_old_database_dir}/$DIR" "${harbor_db_mount}"
    DIR="notary-db"; mv "${harbor_old_database_dir}/$DIR" "${harbor_db_mount}"
  fi

  # Test database connection
  # Subshell to preserve -e
  echo "Testing database credentials..." | tee /dev/fd/3
  ( runMigratorCmd "test" )
  if [ $? -ne 0 ]; then
    echo "Invalid database credentials" | tee /dev/fd/3
    exit 1
  fi

  echo "Backing up harbor config..." | tee /dev/fd/3
  ( runMigratorCmd "backup" )
    if [ $? -ne 0 ]; then
    echo "Harbor backup failed..." | tee /dev/fd/3
    exit 1
  fi

  ( runMigratorCmd "up" )
  if [ $? -ne 0 ]; then
    echo "Harbor up head command failed" | tee /dev/fd/3
    echo "Restoring from backup..." | tee /dev/fd/3
    runMigratorCmd "restore"
    echo "Backup restored. Exiting..." | tee /dev/fd/3
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
}

# Upgrade entry point from upgrade.sh
function upgradeHarbor {
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

  echo "Performing pre-upgrade checks" | tee /dev/fd/3
  checkDir ${harbor_backup}
  cleanupFiles
  mkdir -p ${harbor_backup}
  checkHarborPSCToken
  
  # Start Admiral for data migration
  systemctl start admiral.service

  echo "Starting Harbor upgrade" | tee /dev/fd/3

  echo "[=] Shutting down Harbor" | tee /dev/fd/3
  systemctl stop harbor.service

  echo "[=] Migrating Harbor configuration and data" | tee /dev/fd/3
  # subshell to capture -e
  ( migrateHarbor )
  if [ $? -ne 0 ]; then
    echo "[=] Harbor migration failed from the Old VIC Appliance" | tee /dev/fd/3
    echo "[=] Please contact VMware support" | tee /dev/fd/3
    exit 1
  fi
  
  echo "[=] Successfully migrated Harbor configuration and data" | tee /dev/fd/3
  echo "Harbor upgrade complete" | tee /dev/fd/3

  echo "Starting Harbor" | tee /dev/fd/3
  systemctl start harbor.service
}
