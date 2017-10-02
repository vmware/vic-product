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

set -eu -o pipefail +h

brwhte="$(tput setaf 15)"
brblue="$(tput setaf 12)"
bryllw="$(tput setaf 11)"
brprpl="$(tput setaf 13)"
creset="$(tput sgr0)"

warrow="${brwhte}=>${creset}"
barrow="${brblue}==>${creset}"
yarrow="${bryllw}  ->${creset}"

function task() {
  >&2 printf "${barrow} %s\n" "$*"
}

function progress() {
  >&2 printf "${yarrow} %s\n" "$*"
}

# Importing the pubkey
task "configuring base os"
progress "importing local gpg key"
rpm --import /etc/pki/rpm-gpg/VMWARE-RPM-GPG-KEY

progress "configuring grub"
sed -i 's/set timeout=5/set timeout=0/' /boot/grub2/grub.cfg
sed -i '/linux/ s/$/ consoleblank=0/' /boot/grub2/grub.cfg

progress "setting umask to 022"
sed -i 's/umask 027/umask 022/' /etc/profile

progress "setting root password"
echo 'root:Vmw@re!23' | chpasswd

progress "configuring password expiration"
chage -I -1 -m 0 -M 99999 -E -1 root

progress "configuring ${brprpl}UTC${creset} timezone"
ln --force --symbolic /usr/share/zoneinfo/UTC /etc/localtime
progress "configuring ${brprpl}en_US.UTF-8${creset} locale"
/usr/bin/touch /etc/locale.conf
/bin/echo "LANG=en_US.UTF-8" > /etc/locale.conf
/sbin/locale-gen.sh

progress "installing system dependencies"
tdnf install -q --refresh -y \
    haveged ethtool gawk \
    socat git nfs-utils \
    cifs-utils ebtables \
    iproute2 iptables iputils \
    cdrkit xfsprogs sudo \
    lvm2 parted gptfdisk \
    e2fsprogs docker &>/dev/null

progress "installing package dependencies"
tdnf install -q --refresh -y \
    rsync openjre python-pip &>/dev/null

progress "configuring with overlay"
cp -r /build/root/* /

progress "configuring ${brprpl}haveged${creset}"
systemctl enable haveged

progress "configuring ${brprpl}sshd${creset}"
echo "UseDNS no" >> /etc/ssh/sshd_config
systemctl enable sshd

task "running provisioners"
ls script-provisioners | while read SCRIPT; do
  progress "running ${brprpl}$SCRIPT${creset}"
  ./script-provisioners/$SCRIPT
done;


task "cleaning up base os disk"
tdnf clean all

/sbin/ldconfig
/usr/sbin/pwconv
/usr/sbin/grpconv
/bin/systemd-machine-id-setup

rm /etc/resolv.conf
ln -sf ../run/systemd/resolve/resolv.conf /etc/resolv.conf

progress "cleaning up tmp"
rm -rf /tmp/*

progress "removing man pages"
rm -rf /usr/share/man/*
progress "removing any docs"
rm -rf /usr/share/doc/*
progress "removing caches"
find /var/cache -type f -exec rm -rf {} \;

progress "removing bash history"
# Remove Bash history
unset HISTFILE
echo -n > /root/.bash_history

# Clean up log files
progress "cleaning log files"
find /var/log -type f | while read f; do echo -ne '' > $f; done;

progress "clearing last login information"
echo -ne '' >/var/log/lastlog
echo -ne '' >/var/log/wtmp
echo -ne '' >/var/log/btmp

progress "resetting bashrs"
echo -ne '' > /root/.bashrc

# Clear SSH host keys
progress "resetting ssh host keys"
rm -f /etc/ssh/{ssh_host_dsa_key,ssh_host_dsa_key.pub,ssh_host_ecdsa_key,ssh_host_ecdsa_key.pub,ssh_host_ed25519_key,ssh_host_ed25519_key.pub,ssh_host_rsa_key,ssh_host_rsa_key.pub}

# Zero out the free space to save space in the final image
progress "zero out free space"
dd if=/dev/zero of=/EMPTY bs=1M  2>/dev/null || echo "dd exit code $? is suppressed"
rm -f /EMPTY

progress "syncing fs"
sync

# seal the template
> /etc/machine-id
