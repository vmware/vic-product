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

# This script grabs the engine PSC token and puts it in guestinfo.
set -euf -o pipefail

engine_psc_token=$(grep "access_token" /etc/vmware/psc/engine/tokens.properties | awk -F'access_token=' '{print $2}')
/etc/vmware/set_guestinfo.sh "engine.token" $engine_psc_token
