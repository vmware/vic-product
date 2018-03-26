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
set -uf -o pipefail

TIMEOUT=30
function timecho {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") [==] $*"
}

function connect_once {
    docker network connect internal $* 2>&1
}

function connect {
    out=$(connect_once $*)
    while [[ ! $? -eq 0 && "$out" != *"already exists"* ]]; do
        timecho "Internal connect for '$*' failed. Retrying in $TIMEOUT seconds..."
        sleep $TIMEOUT
        connect_once $*
    done
    timecho "Connected '$*' to internal network."
}

# connect admiral and harbor to a private network
docker network create internal || true
connect vic-admiral
connect harbor-ui