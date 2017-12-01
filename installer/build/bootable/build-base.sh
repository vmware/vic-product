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

# fail on error, unassigned vars or failed pipes
set -e -o pipefail +h && [ -n "$DEBUG" ] && set -x
DIR=$(dirname $(readlink -f "$0"))
. ${DIR}/log.sh

function set_stage() {
  src=${1}
  rt="${2}"
  tgt="${rt}/build"

  log2 "preparing install stage"
  log3 "configuring ${brprpl}tdnf${creset}"
  install -D --mode=0644 --owner=root --group=root /etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY "${rt}/etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY"
  mkdir -p "${rt}/var/lib/rpm"
  mkdir -p "${rt}/cache/tdnf"
  log3 "initializing ${brprpl}rpm db${creset}"
  rpm --root "${rt}/" --initdb
  rpm --root "${rt}/" --import "${rt}/etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY"

  log3 "configuring ${brprpl}yum repos${creset}"
  mkdir -p "${rt}/etc/yum.repos.d/"
  rm /etc/yum.repos.d/{photon,photon-updates}.repo
  # TODO: Use local yum repo in CI
  cp ${src}/repo/*-remote.repo /etc/yum.repos.d/
  # if [[ $DRONE_BUILD_NUMBER && $DRONE_BUILD_NUMBER > 0 ]]; then
  #   cp repo/*-local.repo /etc/yum.repos.d/
  # else
  #   cp repo/*-remote.repo /etc/yum.repos.d/
  # fi
  cp -a /etc/yum.repos.d/ "${rt}/etc/"
  cp /etc/resolv.conf "${rt}/etc/"

  log3 "verifying yum and tdnf setup"
  tdnf repolist --refresh

  log3 "installing ${brprpl}filesystem bash shadow coreutils findutils${creset}"
  tdnf install --installroot "${rt}/" --refresh -y filesystem bash shadow coreutils findutils
  
  log3 "installing ${brprpl}systemd linux-esx tdnf ca-certificates sed gzip tar glibc${creset}"
  tdnf install --installroot "${rt}/" --refresh -y \
    systemd util-linux \
    pkgconfig dbus \
    photon-release tdnf \
    openssh linux-esx sed \
    gzip tar xz bzip2 \
    glibc iana-etc \
    ca-certificates \
    curl which initramfs \
    krb5 motd Linux-PAM \
    bc kmod libdb \
    cpio procps-ng \
    cracklib-dicts

  log3 "installing ${brprpl}tzdata glibc-lang vim${creset}"
  tdnf install --installroot "${rt}/" -y tzdata glibc-lang vim

  log3 "installing ${brprpl}root${creset}"
  cp -a "${src}/root" "${tgt}/"
}

function usage() {
  echo "Usage: $0 -r root-location 1>&2"
  exit 1
}

while getopts "r:" flag
do
    case $flag in

        r)
            # Required. Package name
            ROOT="$OPTARG"
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
if [ -n "$*" -o -z "${ROOT}" ]; then
    usage
fi

log1 "install OS to ${ROOT}"

set_stage "${DIR}" "${ROOT}"

# TODO: Use local yum repo in CI
# log3 "reset yum repos to remote"
# REPOS=$(find ${IMG1ROOT}/etc/yum.repos.d/ | grep -E "*-remote.repo|*-local.repo")
# [ -n "$REPOS" ] && echo $REPOS | while read repo; do rm $repo; done
# cp repo/*-remote.repo "${IMG1ROOT}/etc/yum.repos.d/"