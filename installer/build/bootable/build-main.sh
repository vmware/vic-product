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

# this file sets vic-product specific variables for the build configuration
set -e -o pipefail +h && [ -n "$DEBUG" ] && set -x
DIR=$(dirname $(readlink -f "$0"))
. ${DIR}/log.sh
RESOURCE=""
BASE=""
CACHE=""
MANIFEST=""

function cleanup() {
    log3 "--------------------------------------------------"
    log3 "cleaning up..."
    log3 "removing dev loops and images"
    losetup -D;
}
trap cleanup EXIT


function build_app {
    # run build-app in chroot
    ROOT=$1
    DATA=$2

    log2 "run in chroot ${brprpl}build-app.sh${creset}"
    [ -e "${ROOT}/dev/console" ] || mknod -m 600 "${ROOT}/dev/console" c 5 1
    [ -e "${ROOT}/dev/null" ]    || mknod -m 666 "${ROOT}/dev/null" c 1 3
    [ -e "${ROOT}/dev/random" ]  || mknod -m 444 "${ROOT}/dev/random" c 1 8
    [ -e "${ROOT}/dev/urandom" ] || mknod -m 444 "${ROOT}/dev/urandom" c 1 9
    if [ -h "${ROOT}/dev/shm" ]; then mkdir -pv "${ROOT}/$(readlink "${ROOT}/dev/shm")"; fi
    if ! mountpoint "${ROOT}/data" >/dev/null 2>&1; then mkdir -p "${ROOT}/data" && mount --bind "${DATA}" "${ROOT}/data"; fi

    log2 "setting mountpoints and adding build scripts"
    # if ! mountpoint "${ROOT}/dev"     >/dev/null 2>&1; then mkdir -p "${ROOT}/dev"  && mount --bind /dev "${ROOT}/dev"; fi
    if ! mountpoint "${ROOT}/proc" >/dev/null 2>&1; then mount -t proc proc "${ROOT}/proc"; fi
    if ! mountpoint "${ROOT}/sys"  >/dev/null 2>&1; then mount -t sysfs sysfs "${ROOT}/sys"; fi
    if ! mountpoint "${ROOT}/run"  >/dev/null 2>&1; then mount -t tmpfs tmpfs "${ROOT}/run"; fi

    install -D --mode=0755 --owner=root --group=root "${DIR}/build-app.sh" "${ROOT}/build/build-app.sh"
    install -D --mode=0755 --owner=root --group=root "${DIR}/log.sh" "${ROOT}/build/log.sh"
    
    log3 "copying provisioners"
    mkdir -p "${ROOT}/build/script-provisioners"

    LINE_NUM=0
    SCRIPT_NUM=0
    (
        cd build
        cat "${MANIFEST}" | jq '.[] | .type' | while read LINE; do
            LINE=$(echo $LINE | tr -d '"')
            if [[ $LINE == "shell" ]]; then
                SCRIPT=$(echo "$(cat "${MANIFEST}" | jq '.['$LINE_NUM'] | .script')" | tr -d '"')
                cp $SCRIPT "${ROOT}/build/script-provisioners/$SCRIPT_NUM-$(basename $SCRIPT)"
                chmod +x "${ROOT}/build/script-provisioners/$SCRIPT_NUM-$(basename $SCRIPT)"
            SCRIPT_NUM=$((SCRIPT_NUM+1))
            elif [[ $LINE == "file" ]]; then
                SOURCE=$(echo "$(cat "${MANIFEST}" | jq '.['$LINE_NUM'] | .source')" | tr -d '"' )
                DESTINATION=$(echo "${ROOT}/$(cat "${MANIFEST}" | jq '.['$LINE_NUM'] | .destination')" | tr -d '"' )
                mkdir -p $(dirname $DESTINATION) && cp -R $SOURCE "$DESTINATION"
            fi
                LINE_NUM=$((LINE_NUM+1))
        done
    )

    log2 "copying static assets"
    if [ -n "${CACHE}" ]; then 
        log3 "copying cache to /etc/cache/"
        cp -a "${CACHE}" "${ROOT}/etc/cache"
        cp -a "${CACHE}/installer.env" "${ROOT}/"
    fi

    chroot "$ROOT" \
    /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    DEBUG="$DEBUG" \
    BUILD_VICENGINE_FILE="${BUILD_VICENGINE_FILE}" \
    BUILD_HARBOR_FILE="${BUILD_HARBOR_FILE}" \
    BUILD_ADMIRAL_REVISION="${BUILD_ADMIRAL_REVISION}" \
    BUILD_OVA_REVISION="${BUILD_OVA_REVISION}" \
    PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /usr/bin/bash --login +h -c "cd build; ./build-app.sh" 2>&1 | tee /dev/fd/3

    log2 "cleanup installer"
    log3 "remove build scripts"
    rm -rf "${ROOT}/build"

    umount "${ROOT}/proc"
    umount "${ROOT}/sys"
    umount "${ROOT}/run"
    umount "${ROOT}/data"
}

function main {
    PACKAGE=$(mktemp -d)
    # create disks
    ${DIR}/build-disks.sh -a "create" -p "${PACKAGE}"

    # extract or build base install
    log1 "Installing base os"
    if [ -f "${BASE}" ]; then
        log2 "extracting base"
        tar -xzf "${BASE}" --skip-old-files -C "${PACKAGE}/mnt/root"
    else
        log2 "building base"
        ${DIR}/build-base.sh -r "${PACKAGE}/mnt/root"
        log2 "exporting base"
        [ -n "${BASE}" ] && tar -czf "${BASE}" -C "${PACKAGE}/mnt/root" .
    fi

    # install app dependencies and setup rootfs
    log1 "Installing application layer"
    log2 "building app"
    build_app "${PACKAGE}/mnt/root" "${PACKAGE}/mnt/data"

    # package
    ${DIR}/build-disks.sh -a "export" -p "${PACKAGE}"

    log1 "--------------------------------------------------"
    log1 "packaging OVA..."
    cp ${DIR}/config/builder.ovf ${PACKAGE}/vic-${BUILD_OVA_REVISION}.ovf
    cd ${PACKAGE}
    sed -i -e s~--version--~${BUILD_OVA_REVISION}~ vic-${BUILD_OVA_REVISION}.ovf
    log2 "rebuilding OVF manifest"
    sha256sum --tag vic-${BUILD_OVA_REVISION}.ovf vic-${BUILD_OVA_REVISION}.mf *.vmdk | sed s/SHA256\ \(/SHA256\(/ > vic-${BUILD_OVA_REVISION}.mf
    tar -cvf ${RESOURCE}/vic-${BUILD_OVA_REVISION}.ova vic-${BUILD_OVA_REVISION}.ovf vic-${BUILD_OVA_REVISION}.mf *.vmdk

    OUTFILE=${RESOURCE}/vic-${BUILD_OVA_REVISION}.ova

    log1 "build complete"
    log2 "SHA256: $(shasum -a 256 $OUTFILE | awk '{ print $1 }')"
    log2 "SHA1: $(shasum -a 1 $OUTFILE | awk '{ print $1 }')"
    log2 "MD5: $(md5sum $OUTFILE | awk '{ print $1 }')"
    log2 $(du -ks $OUTFILE | awk '{printf "%sMB\n", $1/1024}')

}

function usage() {
    echo "Usage: $0 -r resource-location -m manifest-location [-b base.tar.gz -c cache-dir] 1>&2"
    exit 1
}
while getopts "r:b:c:m:" flag
do
    case $flag in

        r)
            RESOURCE="$OPTARG"
            ;;

        m)
            MANIFEST="$OPTARG"
            ;;

        b)
            BASE="$OPTARG"
            ;;

        c)
            CACHE="$OPTARG"
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
# check there were no extra args and the required ones are set
if [ -n "$*" -o -z "${RESOURCE}" -o -z "${MANIFEST}" ]; then
    usage
fi

exec 3>&1 1>>"${RESOURCE}/installer-build.log" 2>&1
log1 "Staring appliance build."
main 2> /dev/fd/3