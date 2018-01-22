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

source /installer.env
. util.sh
set -euf -o pipefail

data_mount="/storage/data/harbor"
cfg="${data_mount}/harbor.cfg"
harbor_backup_prev="/storage/data/harbor_backup"
harbor_backup="/storage/data/harbor_backup_1.3.1"
harbor_migration="/storage/data/harbor_migration"
harbor_psc_token_file="/etc/vmware/psc/harbor/tokens.properties"

# File used in previous upgrades to indicate Harbor upgrade was complete
harbor_upgrade_status_prev="/etc/vmware/harbor/upgrade_status"

DB_USER=""
DB_PASSWORD=""

HARBOR_VER_1_2_1="harbor-offline-installer-v1.2.0.tgz"
HARBOR_VER_1_3_0="harbor-offline-installer-v1.3.0.tgz"

MANAGED_KEY="# Managed by configure_harbor.sh"
export LC_ALL="C"

# check for presence of required harbor folders before upgrade from v1.2.1
function harborDataSanityCheck_1_2 {
  harbor_dirs=(
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

# Cleanup files from previous upgrade operations
function cleanupFiles {
  if [ -f "${harbor_upgrade_status_prev}" ]; then
    rm -rf "${harbor_upgrade_status_prev}"
  fi
  if [ -d "${harbor_backup_prev}" ]; then
    rm -rf "${harbor_backup_prev}"
  fi
  if [ -d "${harbor_migration}" ]; then
    rm -rf "${harbor_migration}"
  fi
}

# Check if required PSC token is present
function checkHarborPSCToken {
  if [ ! -f "${harbor_psc_token_file}" ]; then
    echo "PSC token ${harbor_psc_token_file} not present. Unable to perform data migration to Admiral." | tee /dev/fd/3
    exit 1
  fi
  if [ ! -s "${harbor_psc_token_file}" ]; then
    echo "PSC token ${harbor_psc_token_file} has zero size. Unable to perform data migration to Admiral." | tee /dev/fd/3
    exit 1
  fi
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

# Remove key if it is not needed in the config
# Does not handle the comments of key
function removeHarborCfgKey {
  local cfg_key=$1
  local line
  line=$(sed -n "/^$cfg_key\s*=/p" $cfg)

  if [ -z "$line" ]; then
    echo "Key removed: $cfg_key, skipping"
  else
    echo "Key found: $cfg_key, removing key"
    sed -i "/$line/d" $cfg
  fi
}


# Returns value from cfg given key to search for
# Stored in cfg as key = value
function readHarborCfgKey {
  local cfg_key=$1
  local  __resultvar=$2
  local value
  value=$(grep "^$cfg_key " $cfg | cut -d' ' -f 3 | xargs)

  if [ -z "$value" ]; then
      echo "Key not found: $cfg_key"
    else
      eval "$__resultvar"="'$value'"
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
  # Add generated log_rotate_count, log_rotate_size, email_insecure, db_host, db_port, db_user, uaa_endpoint,
  # uaa_clientid, uaa_clientsecret, uaa_ca_root, and ldap_verify_cert as managed key if not present
  configureHarborCfgUnset log_rotate_count 50
  configureHarborCfgUnset log_rotate_size 200M
  configureHarborCfgUnset email_insecure false
  configureHarborCfgUnset db_host mysql
  configureHarborCfgUnset db_port 3306
  configureHarborCfgUnset db_user root
  configureHarborCfgUnset uaa_endpoint uaa.mydomain.org
  configureHarborCfgUnset uaa_clientid id
  configureHarborCfgUnset uaa_clientsecret secret
  configureHarborCfgUnset uaa_ca_root /path/to/uaa_ca.pem
  configureHarborCfgUnset ldap_verify_cert true

  # Add managed tags to db_password and clair_db_password
  configureHarborCfgManageKey db_password
  configureHarborCfgManageKey clair_db_password

  # Remove key verify_remote_cert
  removeHarborCfgKey verify_remote_cert
}

# https://github.com/vmware/harbor/blob/master/docs/migration_guide.md
function migrateHarborData {
  checkDir ${harbor_backup}
  mkdir ${harbor_backup}

  local migrator_image="vmware/harbor-db-migrator:1.3"
  local harbor_old_database_dir="/storage/data/harbor"
  local harbor_new_database_dir="/storage/db/harbor"
  local harbor_database="${harbor_old_database_dir}/database"

  # Test database connection
  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -v ${harbor_database}:/var/lib/mysql ${migrator_image} test
  if [ $? -ne 0 ]; then
    echo "Invalid database credentials" | tee /dev/fd/3
    exit 1
  fi

  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -v ${harbor_database}:/var/lib/mysql -v ${harbor_backup}:/harbor-migration/backup ${migrator_image} backup
  docker run -it --rm -e DB_USR=${DB_USER} -e DB_PWD=${DB_PASSWORD} -e SKIP_CONFIRM=y -v ${harbor_database}:/var/lib/mysql ${migrator_image} up head
  if [ $? -ne 0 ]; then
    echo "Harbor up head command failed" | tee /dev/fd/3
    exit 1
  fi

  mkdir -p ${harbor_new_database_dir}

  DIR="database";  mv "${harbor_old_database_dir}/$DIR" "${harbor_new_database_dir}/"
  DIR="clair-db";  mv "${harbor_old_database_dir}/$DIR" "${harbor_new_database_dir}/"
  DIR="notary-db"; mv "${harbor_old_database_dir}/$DIR" "${harbor_new_database_dir}/"
}

# Upgrade entry point from upgrade.sh
function upgradeHarbor {
  HARBOR_VER=$(readKeyValue "harbor" "/storage/data/version")

  if [ -z "${DB_USER}" ]; then
    DB_USER="root"
  fi

  if [ -z "${DB_PASSWORD}" ]; then
    echo "Getting password from harbor.cfg"
    readHarborCfgKey db_password DB_PASSWORD
  fi

  # If DB_PASSWORD not set by cfg, exit
  if [ -z "${DB_PASSWORD}" ]; then
    echo "--dbpass not set and value not found in $cfg"
    exit 1
  fi
  echo "Performing pre-upgrade checks" | tee /dev/fd/3

  if [ "$HARBOR_VER" == "$HARBOR_VER_1_2_1" ]; then
    if ! harborDataSanityCheck_1_2 ${data_mount}; then
      echo "Harbor Data is not present in ${data_mount}, aborting upgrade" | tee /dev/fd/3
      exit 1
    fi
  elif [ "$HARBOR_VER" == "$HARBOR_VER_1_3_0" ]; then
    echo "No upgrade operations required for upgrade from Harbor $HARBOR_VER" | tee /dev/fd/3
    cleanupFiles
    upgradeHarborConfiguration
    return
  else
    echo "Invalid Harbor version $HARBOR_VER detected. Aborting upgrade." | tee /dev/fd/3
    exit 1
  fi

  cleanupFiles
  checkDir ${harbor_backup}
  checkHarborPSCToken

  # Start Admiral for data migration
  systemctl start admiral.service

  echo "Starting Harbor upgrade" | tee /dev/fd/3

  echo "[=] Shutting down Harbor" | tee /dev/fd/3
  systemctl stop harbor.service

  if [ "$HARBOR_VER" == "$HARBOR_VER_1_2_1" ]; then
    echo "[=] Migrating Harbor data" | tee /dev/fd/3
    migrateHarborData
    echo "[=] Finished migrating Harbor data" | tee /dev/fd/3
  fi

  echo "[=] Migrating Harbor configuration" | tee /dev/fd/3
  upgradeHarborConfiguration
  echo "[=] Finished migrating Harbor configuration" | tee /dev/fd/3

  echo "Harbor upgrade complete" | tee /dev/fd/3

  # Cleanup
  if [ -d "${harbor_backup}" ]; then
    rm -rf "${harbor_backup}"
  fi

  echo "Starting Harbor" | tee /dev/fd/3
  systemctl start harbor.service
}
