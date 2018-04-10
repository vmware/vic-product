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

conf_dir=/etc/vmware/admiral

DIR="$(mktemp -d)"
SHA256SUMS="${DIR}/SHA256SUMS"
PSC_JAR_SHA256="c5de3a821ed7aece85331b22dfa49a99bbb38524ec9f4803b6b54f43cef91237  admiral-auth-psc-1.3.2-SNAPSHOT-command.jar"
cat > "${SHA256SUMS}" << EOF
${PSC_JAR_SHA256}
EOF

# Get the PSC binary for use during initialization
curl -L"#" -o $conf_dir/admiral-auth-psc-1.3.2-SNAPSHOT-command.jar https://storage.googleapis.com/vic-product-ova-build-deps/admiral-auth-psc-1.3.2-SNAPSHOT-command.jar
cd ${conf_dir}
shasum -a 256 --check "${SHA256SUMS}" || (echo "Failed to verify PSC JAR checksum" && exit 1)
cd -

# Get Admiral upgrade script
curl -L"#" -o /etc/vmware/admiral/migrate.sh https://raw.githubusercontent.com/vmware/admiral/master/upgrade/src/main/resources/migrate.sh
chmod +x /etc/vmware/admiral/migrate.sh
