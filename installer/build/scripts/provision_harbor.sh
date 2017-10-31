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

echo "Provisioning Harbor ${BUILD_HARBOR_FILE}"
cat /etc/cache/${BUILD_HARBOR_FILE}  | tar xz -C /var/tmp

harbor_containers_bundle=$(find /tmp/harbor -size +20M -type f -regextype sed -regex ".*/harbor\..*\.t.*z$")
[ -f $harbor_containers_bundle ] || (echo "Harbor archive invalid - cannot fine docker image archive." && exit 1)

# Copy configuration data from tarball
cp -p /var/tmp/harbor/harbor.cfg /data/harbor
cp -pr /var/tmp/harbor/{prepare,common,docker-compose.yml,docker-compose.notary.yml,docker-compose.clair.yml} /etc/vmware/harbor

# Get Harbor to Admiral data migration script
curl -L"#" -o /etc/vmware/harbor/admiral_import https://raw.githubusercontent.com/vmware/harbor/master/tools/migration/import
chmod +x /etc/vmware/harbor/admiral_import

function overrideDataDirectory {
FILE="$1"  python - <<END
import yaml, os
file = os.environ['FILE']
f = open(file, "r+")
dataMap = yaml.safe_load(f)
for _, s in enumerate(dataMap["services"]):
  if "restart" in dataMap["services"][s]:
      if "always" in dataMap["services"][s]["restart"]:
        dataMap["services"][s]["restart"] = "on-failure"
  if "volumes" in dataMap["services"][s]:
    for kvol, vol in enumerate(dataMap["services"][s]["volumes"]):
      # Fixing up volumes in compose file. 
      if vol.startswith( '/data/database' ):
        dataMap["services"][s]["volumes"][kvol] = vol.replace("/data/database", "/storage/db/harbor/database", 1)
      elif vol.startswith( '/data/notary-db' ):
        dataMap["services"][s]["volumes"][kvol] = vol.replace("/data/notary-db", "/storage/db/harbor/notary-db", 1)
      elif vol.startswith( '/data/clair-db' ):
        dataMap["services"][s]["volumes"][kvol] = vol.replace("/data/clair-db", "/storage/db/harbor/clair-db", 1)
      elif vol.startswith( '/var/log/harbor' ):
        dataMap["services"][s]["volumes"][kvol] = vol.replace("/var/log/harbor", "/storage/log/harbor", 1)
      elif vol.startswith( '/data' ):
        dataMap["services"][s]["volumes"][kvol] = vol.replace("/data", "/storage/data/harbor", 1)
f.seek(0)
yaml.dump(dataMap, f, default_flow_style=False)
f.truncate()
f.close()
END
}

# Replace default DataDirectories in the harbor-provided compose files
overrideDataDirectory /etc/vmware/harbor/docker-compose.yml
overrideDataDirectory /etc/vmware/harbor/docker-compose.notary.yml
overrideDataDirectory /etc/vmware/harbor/docker-compose.clair.yml

chmod 600 /data/harbor/harbor.cfg
chmod -R 600 /etc/vmware/harbor/common

# Write version files
echo "harbor=${BUILD_HARBOR_FILE}" >> /data/version
echo "harbor=${BUILD_HARBOR_FILE}" >> /etc/vmware/version
