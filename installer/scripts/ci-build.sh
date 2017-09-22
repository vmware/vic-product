#!/bin/bash
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

set -e

# set variables
cd installer
INSTALLER_DIR=$(pwd)
OPTIONS=""

# TODO remove after #353 is fixed
# Grab the dependencies from vic if we're running ci
if [[ $DRONE ]]; then
  mkdir -p /go/src/github.com/vmware/vic/
  git clone https://github.com/vmware/vic.git /go/src/github.com/vmware/vic/
fi

# set options
if [ -n "${ADMIRAL}" ]; then
  OPTIONS="--admiral $ADMIRAL"
fi

if [ -n "${HARBOR}" ]; then
  OPTIONS="$OPTIONS --harbor $HARBOR"
fi

if [ -n "${VICENGINE}" ]; then
  OPTIONS="$OPTIONS --vicengine $VICENGINE"
fi

# invoke build script
$INSTALLER_DIR/build/build.sh ova-ci $OPTIONS