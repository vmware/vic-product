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
source /installer.env
set -euf -o pipefail

# Populated by configure_admiral.sh
ADMIRAL_EXPOSED_PORT=""
ADMIRAL_DATA_LOCATION=""
OVA_VM_IP=""

# Configure Xenon opts with VM IP
admiral_xenon_opts="--publicUri=https://${OVA_VM_IP}:8282/ --bindAddress=0.0.0.0 --port=-1 --authConfig=/configs/psc-config.properties --securePort=8282 --keyFile=/configs/server.key --certificateFile=/configs/server.crt --startMockHostAdapterInstance=false"

/usr/bin/docker run -p ${ADMIRAL_EXPOSED_PORT}:8282 \
  --name vic-admiral \
  -v "$ADMIRAL_DATA_LOCATION:/var/admiral" \
  -v "$ADMIRAL_DATA_LOCATION/configs:/configs" \
  -v /storage/log/admiral:/admiral/log \
  -e ADMIRAL_PORT=-1 \
  -e JAVA_OPTS="-Ddcp.net.ssl.trustStore=/configs/trustedcertificates.jks -Ddcp.net.ssl.trustStorePassword=changeit -Dencryption.key.file=/var/admiral/8282/encryption.key -Dinit.encryption.key.file=true" \
  -e CONFIG_FILE_PATH="/configs/config.properties" \
  -e XENON_OPTS="${admiral_xenon_opts}" \
  --log-driver=json-file \
  --log-opt max-size=1g \
  --log-opt max-file=10 \
  "vmware/admiral:vic_${BUILD_ADMIRAL_REVISION}"
