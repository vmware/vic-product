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

set -euo pipefail

brwhte="$(tput setaf 15)"
brblue="$(tput setaf 12)"
bryllw="$(tput setaf 11)"
brprpl="$(tput setaf 13)"
creset="$(tput sgr0)"

warrow="${brwhte}=>${creset}"
barrow="${brblue}==>${creset}"
yarrow="${bryllw} ->${creset}"

# cache docker images
images=(
  vmware/admiral:vic_${BUILD_ADMIRAL_REVISION}
  vmware/admiral:vic_${BUILD_ADMIRAL_RELEASE}
  vmware/dch-photon:${BUILD_DCHPHOTON_VERSION}
)

# cache other deps
downloads=(
  ${BUILD_HARBOR_URL}
  ${BUILD_VICENGINE_URL}
)

function add() {
  src=$1
  dest=$2
  if [[ "$src" =~ ^http://|^https:// ]]; then
    curl -L"#" $src > $dest
  else
    cp $src $dest
    eecho "coped from local fs"
  fi
  
}

mkdir -p "$(dirname $0)/baseimage/cache/docker/"

echo "${warrow} caching container images"
for img in "${images[@]}"; do
  echo "${barrow} checking cache for ${brprpl}${img}${creset} archive"
  archive=$(dirname $0)/baseimage/cache/docker/$(echo "${img##*/}" | tr ':' '-').tar.gz
  echo "${yarrow} pulling ${brprpl}${img}${creset}"
  pull=$(docker pull "$img")
  if [[ -f "$archive" && "$pull" == *"Image is up to date"* ]]; then
    echo "${yarrow} cache is up to date - not saving ${brprpl}${img}${creset}"
  else
    echo "${yarrow} saving ${brprpl}${archive##*/}${creset}"
    docker save "$img" | gzip > "$archive"
  fi
done
echo "${warrow} saved all images"

echo "${warrow} caching other dependencies"
for download in "${downloads[@]}"; do
  filename=$(basename ${download})
  echo "${barrow} checking cache for ${brprpl}${filename}${creset} archive"
  archive="$(dirname $0)/baseimage/cache/${filename}"
  if [ -f "$archive" ]; then
    echo "${yarrow} cache is up to date - not saving ${brprpl}${filename}${creset}"
  else
    echo "${yarrow} downloading and saving ${brprpl}${filename}${creset}"
    set +e
    basefile=$(ls "$(dirname $archive)/$(echo ${filename} | cut -f1 -d"-" | cut -f1 -d"_" | cut -f1 -d".")"* 2>/dev/null)
    [ $? -eq 0 ] && [ -f "$basefile" ] && rm "$basefile"*
    set -e
    add ${download} $archive 
  fi
done
echo "${warrow} saved all downloads"