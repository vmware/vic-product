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

network_conf_file=/etc/systemd/network/09-vic.network

mask2cdr () {
  set -- 0^^^128^192^224^240^248^252^254^ ${#1} ${1##*255.}
  set -- $(( ($2 - ${#3})*2 )) ${1%%${3%%.*}*}
  echo $(( $1 + (${#2}/4) ))
}
opts=''
dhcpOpts=''
fqdn=$(ovfenv --key network.fqdn)
network_address=$(ovfenv --key network.ip0)
gateway=$(ovfenv --key network.gateway)
dns=$(ovfenv --key network.DNS | sed 's/,/ /g' | tr -s ' ')
domains=$(ovfenv --key network.searchpath)

# Set hostname
if [[ -n $fqdn ]]; then
  hostnamectl set-hostname $fqdn
  dhcpOpts=$dhcpOpts"UseHostname=false\n"
fi

# Set network address and mask
if [[ -n  $network_address ]]; then
  # If IP is configured via OVF environment, we create a file for systemd-networkd to parse
  network_cidr=$(mask2cdr $(ovfenv --key network.netmask0))
  opts=$opts"Address=${network_address}/${network_cidr}\n"
fi

if [[ -n $gateway ]]; then
  opts=$opts"Gateway=$gateway\n"
  dhcpOpts=$dhcpOpts"UseRoutes=false\n"
fi

if [[ -n $dns ]]; then
  opts=$opts"DNS=$dns\n"
  dhcpOpts=$dhcpOpts"UseDNS=false\n"
fi

if [[ -n $domains ]]; then
  opts=$opts"Domains=$domains\n"
  dhcpOpts=$dhcpOpts"UseDomains=false\n"
fi


cat <<EOF | tee ${network_conf_file}
[Match]
Name=eth0

[Network]
$(echo -e $opts)
DHCP=ipv4

[DHCP]
$(echo -e $dhcpOpts)
EOF

chmod 644 ${network_conf_file}
