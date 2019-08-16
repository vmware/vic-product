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

# this file caches vic-product dependencies
set -e -o pipefail +h && [ -n "$DEBUG" ] && set -x
DIR=$(dirname $(readlink -f "$0"))

brprpl="\033[0;00;95m"
reset="\033[0m"

warrow="\033[0;00;97m=>\033[0m"
barrow="\033[0;00;94m=>\033[0m"
yarrow="\033[0;00;93m=>\033[0m"

# cache docker images
images=(
  vmware/admiral:vic_${BUILD_ADMIRAL_REVISION}
  vmware/dch-photon:${BUILD_DCHPHOTON_VERSION}
  gcr.io/eminent-nation-87317/vic-machine-server:${BUILD_VIC_MACHINE_SERVER_REVISION}
  vmware/registry:2.6.2-photon
)

# cache other deps
downloads=(
  ${BUILD_HARBOR_URL}
  ${BUILD_VICENGINE_URL}
  ${BUILD_VICUI_URL}
)

function timecho {
  echo -e "$(date +"%Y-%m-%d %H:%M:%S") [==] $*"
}

function add() {
  src=$1
  dest=$2
  if [[ "$src" =~ ^http://|^https:// ]]; then
    curl -fL"#" "$src" -o "$dest"
  else
    cp "$src" "$dest"
    timecho "copied from local fs"
  fi
}

function cacheImages() {
  timecho "${warrow} caching container images"
  mkdir -p ${CACHE}/docker/
  for img in "${images[@]}"; do
    timecho "${barrow} checking cache for ${brprpl}${img}${reset} archive"
    archive="${CACHE}/docker/$(echo "${img##*/}" | tr ':' '-').tar.gz"
    timecho "${yarrow} pulling ${brprpl}${img}${reset}"
    pull=$(docker pull "$img")
    if [[ -f "$archive" && "$pull" == *"Image is up to date"* ]]; then
      timecho "${yarrow} cache is up to date - not saving ${brprpl}${img}${reset}"
    else
      timecho "${yarrow} saving ${brprpl}${archive##*/}${reset}"
      docker save "$img" | gzip > "$archive"
    fi
    timecho "${warrow} ${img} details \n$(docker images --digests -f "dangling=false" --format "tag: {{.Tag}}, digest: {{.Digest}}, age: {{.CreatedSince}}" $(echo ${img} | cut -d ':' -f1))\n"
  done

  timecho "${warrow} saved all images"
}

function cacheOther() {
  timecho "${warrow} caching other dependencies"
  for download in "${downloads[@]}"; do
    filename=$(basename "${download}")
    timecho "${barrow} checking cache for ${brprpl}${filename}${reset} archive"
    archive="${CACHE}/${filename}"
    if [ -f "$archive" ]; then
      timecho "${yarrow} cache is up to date - not saving ${brprpl}${filename}${reset}"
    else
      timecho "${yarrow} downloading and saving ${brprpl}${filename}${reset}"
      set +e
      basefile=$(ls "$(dirname "$archive")/$(echo "${filename}" | grep -v vic | cut -f1 -d"-" | cut -f1 -d"_" | cut -f1 -d".")"* 2>/dev/null)
      [ $? -eq 0 ] && [ -f "$basefile" ] && rm "$basefile"*
      set -e
      add "${download}" "$archive"
    fi
    echo ""
  done
  timecho "${warrow} saved all downloads"
}

function usage() {
timecho "Usage: $0 -c cache-directory" 1>&2
exit 1
}

while getopts "c:" flag
do
    case $flag in

        c)
            # Optional. Offline cache of yum packages
            CACHE="$OPTARG"
            ;;

        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

# check there were no extra args and the required ones are set
if [ -n "$*" -o -z "${CACHE}" ]; then
    usage
fi

cacheImages
cacheOther
