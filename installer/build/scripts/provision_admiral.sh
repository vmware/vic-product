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

# Get the PSC binary for use during initialization
curl -L"#" -o $conf_dir/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar https://storage.googleapis.com/vic-product-ova-build-deps/admiral-auth-psc-1.2.0-SNAPSHOT-command.jar

# Get Admiral upgrade script
curl -L"#" -o /etc/vmware/admiral/migrate.sh https://raw.githubusercontent.com/vmware/admiral/master/upgrade/src/main/resources/migrate.sh
chmod +x /etc/vmware/admiral/migrate.sh
