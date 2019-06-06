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
DIR=$(dirname "$(readlink -f "$0")")
. "${DIR}/log.sh"

function set_base() {
  src="${1}"
  rt="${2}"

  log2 "preparing install stage"
  log3 "configuring ${brprpl}tdnf${reset}"
  install -D --mode=0644 --owner=root --group=root /etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY "${rt}/etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY"
  mkdir -p "${rt}/var/lib/rpm"
  mkdir -p "${rt}/cache/tdnf"
  log3 "initializing ${brprpl}rpm db${reset}"
  rpm --root "${rt}/" --initdb
  rpm --root "${rt}/" --import "${rt}/etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY"

  log3 "configuring ${brprpl}yum repos${reset}"
  cp -a /etc/yum.repos.d "${rt}/etc/"

  log3 "configuring tdnf.conf"
  cp "${DIR}"/repo/tdnf.conf "${rt}/tdnf.conf"
  sed -i "s|\$ROOTFS|${rt}|g" "${rt}/tdnf.conf"

  if [[ ${DRONE_BUILD_NUMBER} && ${DRONE_BUILD_NUMBER} > 0 ]]; then
    log3 "Use local tdnf repo to install packages for CI build ${DRONE_BUILD_NUMBER}"
    mv "${rt}/etc/yum.repos.d" "${rt}/etc/yum.repos.d.bak"
    mkdir -p "${rt}/etc/yum.repos.d"
    cp "${DIR}"/repo/*-local.repo "${rt}/etc/yum.repos.d"
  fi
  cp /etc/resolv.conf "${rt}/etc/"

  TDNF_OPTS="-c ${rt}/tdnf.conf --installroot ${rt}/ --refresh"
  # baseurl is something like https://dl.bintray.com/vmware/photon_release_$releasever_$basearch.
  # releasever in tdnf.conf does not render to baseurl in /etc/yum.repos.d/*.repo, so it is required
  # to specify releasever as 2.0 when it is built from remote repo.
  if [[ -z ${DRONE_BUILD_NUMBER} || ${DRONE_BUILD_NUMBER} -eq 0 ]]; then
    TDNF_OPTS="$TDNF_OPTS --releasever 2.0"
  fi

  log3 "verifying yum and tdnf setup"
  tdnf ${TDNF_OPTS} repolist

  log3 "installing ${brprpl}filesystem bash shadow coreutils findutils${reset}"
  tdnf ${TDNF_OPTS} install -y \
    filesystem bash shadow coreutils findutils

  log3 "installing ${brprpl}systemd linux-esx tdnf ca-certificates sed gzip tar glibc rpm${reset}"
  tdnf ${TDNF_OPTS} install -y \
    systemd util-linux \
    pkgconfig dbus cpio\
    photon-release tdnf \
    openssh linux-esx sed \
    gzip zip tar xz bzip2 \
    glibc iana-etc \
    ca-certificates \
    curl which initramfs \
    krb5 motd procps-ng \
    bc kmod libdb rpm

  log3 "installing ${brprpl}tzdata glibc-lang vim glibc-i18n${reset}"
  tdnf ${TDNF_OPTS} install -y \
    tzdata glibc-lang vim glibc-i18n

  log3 "installing system dependencies"
  tdnf ${TDNF_OPTS} install -y \
    haveged ethtool gawk \
    socat git nfs-utils \
    cifs-utils ebtables \
    iproute2 iptables iputils \
    cdrkit xfsprogs sudo \
    lvm2 parted gptfdisk \
    e2fsprogs docker gzip \
    net-tools logrotate sshpass \
    rsyslog

  log3 "installing package dependencies"
  tdnf ${TDNF_OPTS} install -y \
    openjre8 python-pip

  log3 "installing ${brprpl}root${reset}"
  cp -a "${src}/root/." "${rt}/"

  rm -f "${rt}/tdnf.conf"

  if [[ ${DRONE_BUILD_NUMBER} && ${DRONE_BUILD_NUMBER} > 0 ]]; then
    log3 "reset tdnf repos to remote"
    rm -rf "${rt}/etc/yum.repos.d"
    mv "${rt}/etc/yum.repos.d.bak" "${rt}/etc/yum.repos.d"
  fi
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
if [[ -n "$*" || -z "${ROOT}" ]]; then
    usage
fi

log2 "install OS to ${ROOT}"

set_base "${DIR}" "${ROOT}"
