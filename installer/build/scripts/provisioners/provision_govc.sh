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

# Need updated release of govc to support datastore.cp
# Build off of master for now.

# DIR=$(mktemp -d)
# cd $DIR
# curl -L"#" https://github.com/vmware/govmomi/releases/download/v0.16.0/govc_linux_amd64.gz | gunzip > govc
# sudo install -t /usr/local/bin/ govc

tdnf install -y git
curl -L'#' -k https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz | tar xzf - -C /usr/local
export PATH=$PATH:/usr/local/go/bin
MASTER='3c1bff8adbaf7408746a1f3b28ace708639b9e3e'
GOVMOMI='/root/go/src/github.com/vmware/govmomi'
mkdir -p $GOVMOMI
git clone https://github.com/vmware/govmomi.git $GOVMOMI
( cd $GOVMOMI && git checkout $MASTER )
GOOS=linux GOARCH=amd64 go build \
      -o="/usr/local/bin/govc" -ldflags="-X github.com/vmware/govmomi/govc/version.gitVersion=00.16.1" \
      github.com/vmware/govmomi/govc
govc version
tdnf remove -y git