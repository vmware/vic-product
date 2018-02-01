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
# disable hashall
set -eu -o pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "This script needs to be run as root"
  exit 1
fi

brwhte="$(tput setaf 15)"
brblue="$(tput setaf 12)"
bryllw="$(tput setaf 11)"
brprpl="$(tput setaf 13)"
creset="$(tput sgr0)"

warrow="${brwhte}=>${creset}"
barrow="${brblue}==>${creset}"
yarrow="${bryllw} ->${creset}"

function section() {
  >&2 printf "${warrow} %s\n" "$*"
}

function task() {
  >&2 printf "${barrow} %s\n" "$*"
}

function progress() {
  >&2 printf "${yarrow} %s\n" "$*"
}

function create_disk() {
  local img="$1"
  local disk_size="$2"
  local mp="$3"
  local boot="${4:-}"

  losetup -f &>/dev/null || ( echo "Cannot setup loop devices" && exit 1 )

  progress "allocating raw image of ${brprpl}${disk_size}${creset}"
  fallocate -l "$disk_size" -o 1024 "$img"

  progress "wiping existing filesystems"
  sgdisk -Z -og "$img" &>/dev/null

  part_num=1
  if [[ -n $boot ]]; then
    progress "creating bios boot partition"
    sgdisk -n $part_num:2048:+2M -c $part_num:"BIOS Boot" -t $part_num:ef02 "$img" &>/dev/null
    part_num=$(($part_num+1))
  fi

  progress "creating linux partition"
  sgdisk -N $part_num -c $part_num:"Linux system" -t $part_num:8300 "$img" &>/dev/null

  progress "reloading loop devices"
  disk=$(losetup --show -f -P "$img")

  progress "formatting linux partition"
  mkfs.ext4 -F "${disk}p$part_num" &>/dev/null

  progress "mounting partition ${brprpl}${disk}p$part_num${creset} at ${brprpl}${mp}${creset}"
  mkdir -p "$mp"
  mount "${disk}p$part_num" "$mp"

  echo "$disk"
}

function setup() {
  task "installing qemu-img"
  task "ensuring necessary packages are present"

  progress "installing ${brprpl}gptfdisk e2fsprogs grub2 parted${creset}"
  tdnf install -y gptfdisk e2fsprogs grub2 parted &>/dev/null

  [ -f /usr/bin/qemu-img ] && return

  progress "installing ${brprpl}qemu-img${creset}"
  tdnf install -y xz
  curl -OL'#' https://storage.googleapis.com/vic-product-ova-build-deps/qemu-img.xz
  xz -d qemu-img.xz
  chmod +x qemu-img
  mv qemu-img /usr/bin/qemu-img

  task "installing ${brprpl}jq${creset}"
  curl -o /usr/bin/jq -L'#' https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
  chmod +x /usr/bin/jq
}

function set_stage() {
  src=$1
  rt="${2}"
  tgt="${rt}/build"

  task "preparing install stage"
  progress "configuring ${brprpl}tdnf${creset}"
  install -D --mode=0644 --owner=root --group=root /etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY "${rt}/etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY"
  mkdir -p "${rt}/var/lib/rpm"
  mkdir -p "${rt}/cache/tdnf"
  progress "initializing ${brprpl}rpm db${creset}"
  rpm --root "${rt}/" --initdb
  rpm --root "${rt}/" --import "${rt}/etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY"

  progress "configuring ${brprpl}yum repos${creset}"
  mkdir -p "${rt}/etc/yum.repos.d/"
  rm /etc/yum.repos.d/{photon,photon-updates}.repo
  # TODO: Use local yum repo in CI
  cp repo/*-remote.repo /etc/yum.repos.d/
  # if [[ $DRONE_BUILD_NUMBER && $DRONE_BUILD_NUMBER > 0 ]]; then
  #   cp repo/*-local.repo /etc/yum.repos.d/
  # else
  #   cp repo/*-remote.repo /etc/yum.repos.d/
  # fi
  cp -a /etc/yum.repos.d/ "${rt}/etc/"
  cp /etc/resolv.conf "${rt}/etc/"

  progress "verifying yum and tdnf setup"
  tdnf repolist --refresh

  progress "installing ${brprpl}filesystem bash shadow coreutils findutils${creset}"
  tdnf install -q --installroot "${rt}/" --refresh -y filesystem bash shadow coreutils findutils &>/dev/null
  progress "installing ${brprpl}systemd linux-esx tdnf ca-certificates sed gzip tar glibc${creset}"
  tdnf install -q --installroot "${rt}/" --refresh -y \
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
    cracklib-dicts &>/dev/null

  progress "installing ${brprpl}tzdata glibc-lang vim${creset}"
  tdnf install -q --installroot "${rt}/" -y tzdata glibc-lang vim &>/dev/null

  progress "installing ${brprpl}installer${creset}"
  install -D --mode=0755 --owner=root --group=root "${src}/install.sh" "${tgt}/install.sh"
  cp -a root "${tgt}/"

  task "copying static assets"
  progress "copying cache to /etc/cache/"
  cp -a cache "${rt}/etc/"
  progress "copying provisioners"
  mkdir -p "${tgt}/script-provisioners"
  LINE_NUM=0
  SCRIPT_NUM=0
  cat ../ova-manifest.json | jq '.[] | .type' | while read LINE; do
      LINE=$(echo $LINE | tr -d '"')
      if [[ $LINE == "shell" ]]; then
          SCRIPT=$(echo "$(cat ../ova-manifest.json | jq '.['$LINE_NUM'] | .script')" | tr -d '"')
          cp ../$SCRIPT "${tgt}/script-provisioners/$SCRIPT_NUM-$(basename $SCRIPT)"
          chmod +x "${tgt}/script-provisioners/$SCRIPT_NUM-$(basename $SCRIPT)"
          SCRIPT_NUM=$((SCRIPT_NUM+1))
      elif [[ $LINE == "file" ]]; then
          SOURCE=$(echo "$(cat ../ova-manifest.json | jq '.['$LINE_NUM'] | .source')" | tr -d '"' )
          DESTINATION=$(echo "${rt}/$(cat ../ova-manifest.json | jq '.['$LINE_NUM'] | .destination')" | tr -d '"' )
          mkdir -p $(dirname $DESTINATION) && cp -R ../$SOURCE "$DESTINATION"
      fi
      LINE_NUM=$((LINE_NUM+1))
  done
}

function setup_grub() {
  root=$2
  disk=$1
  device="${1}p2"

  progress "install grub to ${brprpl}${root}/boot${creset} on ${brprpl}${disk}${creset}"
  mkdir -p "${root}/boot/grub2"
  ln -sfv grub2 "${root}/boot/grub"
  grub2-install --target=i386-pc --modules "part_gpt gfxterm vbe tga png ext2" --no-floppy --force --boot-directory="${root}/boot" "$disk"

  PARTUUID=$(blkid -s PARTUUID -o value "${device}")
  BOOT_UUID=$(blkid -s UUID -o value "${device}")
  BOOT_DIRECTORY=/boot/

  progress "configure grub"
  rm -rf "${root}/boot/grub2/fonts"
  cp boot/ascii.pf2 "${root}/boot/grub2/"
  mkdir -p "${root}/boot/grub2/themes/photon"
  cp boot/splash.png "${root}/boot/grub2/themes/photon/photon.png"
  cp boot/terminal_*.tga "${root}/boot/grub2/themes/photon/"
  cp boot/theme.txt "${root}/boot/grub2/themes/photon/"
  # linux-esx tries to mount rootfs even before nvme got initialized.
  # rootwait fixes this issue
  EXTRA_PARAMS=""
  if [[ "$1" == *"nvme"* ]]; then
      EXTRA_PARAMS=rootwait
  fi

  cat > "${root}/boot/grub2/grub.cfg" << EOF
# Begin /boot/grub2/grub.cfg

set default=0
set timeout=5
search -n -u $BOOT_UUID -s
loadfont ${BOOT_DIRECTORY}grub2/ascii.pf2

insmod gfxterm
insmod vbe
insmod tga
insmod png
insmod ext2
insmod part_gpt

set gfxmode="640x480"
gfxpayload=keep

terminal_output gfxterm

set theme=${BOOT_DIRECTORY}grub2/themes/photon/theme.txt
load_env -f ${BOOT_DIRECTORY}photon.cfg
if [ -f  ${BOOT_DIRECTORY}systemd.cfg ]; then
    load_env -f ${BOOT_DIRECTORY}systemd.cfg
else
    set systemd_cmdline=net.ifnames=0
fi
set rootpartition=PARTUUID=$PARTUUID

menuentry "Photon" {
    linux ${BOOT_DIRECTORY}\$photon_linux root=\$rootpartition \$photon_cmdline \$systemd_cmdline $EXTRA_PARAMS
    if [ -f ${BOOT_DIRECTORY}\$photon_initrd ]; then
        initrd ${BOOT_DIRECTORY}\$photon_initrd
    fi
}
# End /boot/grub2/grub.cfg
EOF
}

function install_os() {
  dataroot=$3
  root=$2
  dev=$1

  task "install os and packages"
  setup_grub "$dev" "$root"
  photon_chroot "$root" "$dataroot" ./install.sh
}

function photon_chroot() {
  tgt="$1"
  datamount="$2"
  shift 2

  task "run in chroot ${brprpl}$*${creset}"
  [ -e "${tgt}/dev/console" ] || mknod -m 600 "${tgt}/dev/console" c 5 1
  [ -e "${tgt}/dev/null" ]    || mknod -m 666 "${tgt}/dev/null" c 1 3
  [ -e "${tgt}/dev/random" ]  || mknod -m 444 "${tgt}/dev/random" c 1 8
  [ -e "${tgt}/dev/urandom" ] || mknod -m 444 "${tgt}/dev/urandom" c 1 9

  if ! mountpoint "${tgt}/dev"     >/dev/null 2>&1; then mkdir -p "${tgt}/dev"  && mount --bind /dev "${tgt}/dev"; fi
  if ! mountpoint "${tgt}/data"    >/dev/null 2>&1; then mkdir -p "${tgt}/data" && mount --bind ${datamount} "${tgt}/data"; fi
  if ! mountpoint "${tgt}/proc"    >/dev/null 2>&1; then mount -t proc proc "${tgt}/proc"; fi
  if ! mountpoint "${tgt}/sys"     >/dev/null 2>&1; then mount -t sysfs sysfs "${tgt}/sys"; fi
  if ! mountpoint "${tgt}/run"     >/dev/null 2>&1; then mount -t tmpfs tmpfs "${tgt}/run"; fi
  if [ -h "${tgt}/dev/shm" ]; then
    mkdir -pv "${tgt}/$(readlink "${tgt}/dev/shm")";
  fi

  chroot "$tgt" \
    /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    BUILD_VICENGINE_FILE="${BUILD_VICENGINE_FILE}" \
    BUILD_HARBOR_FILE="${BUILD_HARBOR_FILE}" \
    BUILD_ADMIRAL_REVISION="${BUILD_ADMIRAL_REVISION}" \
    BUILD_OVA_REVISION="${BUILD_OVA_REVISION}" \
    PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /usr/bin/bash --login +h -c "cd build;$*"
}

function convert() {
  dev=$1
  root=$2
  raw=$3
  vmdk=$4

  progress "unmount ${brprpl}${root}${creset}"
  if mountpoint "${root}" >/dev/null 2>&1; then
    umount -R "${root}/" >/dev/null 2>&1
  fi

  progress "release loopback device ${brprpl}${dev}${creset}"
  losetup -d "$dev"

  progress "converting raw image ${brprpl}${raw}${creset} into ${brprpl}${vmdk}${creset}"
  qemu-img convert -f raw -O vmdk -o 'compat6,adapter_type=lsilogic,subformat=streamOptimized' "$raw" "bin/$vmdk"
  rm "$raw"
}

# find current dir in an arbitrarily nested symlinked path
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd "$DIR"

# These sizes are minimal for install, since partitions are resized to full disk space after firstboot.
IMAGESIZES=(
  "4GiB"
  "1GiB"
)
IMAGES=(
  "vic-disk1"
  "vic-disk2"
)
IMAGEROOTS=(
  "/mnt/ova-root"
  "/mnt/ova-data"
)
DEVS=()

section "setup build environment"
setup

task "create disk images"
for i in "${!IMAGES[@]}"; do
   BOOT=""
  [ "$i" == "0" ] && BOOT="1"
  progress "creating ${IMAGES[$i]}.img"
  DEVS+=("$(create_disk "${IMAGES[$i]}.img" "${IMAGESIZES[$i]}" "${IMAGEROOTS[$i]}" $BOOT)")
done

section "install OS to ${DEVS[0]}"

set_stage "$DIR" "${IMAGEROOTS[0]}"

install_os "${DEVS[0]}" "${IMAGEROOTS[0]}" "${IMAGEROOTS[1]}"

task "cleanup installer"
progress "remove build scripts"
rm -rf "${IMAGEROOTS[0]}/build"
# TODO: Use local yum repo in CI
# progress "reset yum repos to remote"
# REPOS=$(find ${IMG1ROOT}/etc/yum.repos.d/ | grep -E "*-remote.repo|*-local.repo")
# [ -n "$REPOS" ] && echo $REPOS | while read repo; do rm $repo; done
# cp repo/*-remote.repo "${IMG1ROOT}/etc/yum.repos.d/"

section "export images to VMDKs"
for i in "${!IMAGES[@]}"; do
  progress "exporting ${IMAGES[$i]}.img to ${IMAGES[$i]}.vmdk"
  convert "${DEVS[$i]}" "${IMAGEROOTS[$i]}" "${IMAGES[$i]}.img" "${IMAGES[$i]}.vmdk"
done

task "VMDK Sizes"
du -h bin/*