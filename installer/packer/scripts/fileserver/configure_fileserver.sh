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

umask 077
data_dir="/opt/vmware/fileserver"
cert_dir="${data_dir}/cert"
script_dir=/etc/vmware
flag=${data_dir}/cert_gen_type

cert="${cert_dir}/server.crt"
key="${cert_dir}/server.key"
csr="${cert_dir}/server.csr"
ca_cert="${cert_dir}/ca.crt"
ca_key="${cert_dir}/ca.key"
ext=${cert_dir}/extfile.cnf

ca_download_dir=${data_dir}/ca_download
mkdir -p {${cert_dir},${ca_download_dir}}

port=$(ovfenv -k fileserver.port)

if [ -z "$port" ]; then
  port="9443"
fi

#Format cert file
function formatCert {
  content=$1
  file=$2
  echo $content | sed -r 's/(-{5}BEGIN [A-Z ]+-{5})/&\n/g; s/(-{5}END [A-Z ]+-{5})/\n&\n/g' | sed -r 's/.{64}/&\n/g; /^\s*$/d' > $file
}

function genCert {
  if [ ! -e $ca_cert ] || [ ! -e $ca_key ]
  then
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout $ca_key \
      -x509 -days 365 -out $ca_cert -subj \
      "/C=US/ST=California/L=Palo Alto/O=VMware, Inc./OU=Containers on vSphere/CN=Self-signed by VMware, Inc."
  fi
  openssl req -newkey rsa:4096 -nodes -sha256 -keyout $key \
    -out $csr -subj \
    "/C=US/ST=California/L=Palo Alto/O=VMware/OU=Containers on vSphere/CN=$hostname"

  echo "Add subjectAltName = IP: $ip_address to certificate"
  echo subjectAltName = IP:$ip_address > $ext
  openssl x509 -req -days 365 -in $csr -CA $ca_cert -CAkey $ca_key -CAcreateserial -extfile $ext -out $cert

  echo "self-signed" > $flag
  echo "Copy CA certificate to $ca_download_dir"
  cp $ca_cert $ca_download_dir/
}

function updateConfigFiles {
  ui_dir="${data_dir}/files"
  # cove cli has package in form of vic-adm_*.tar.gz, so use 'vic_*.tar.gz' here
  # to avoid including cove cli
  tar_gz=`find "${ui_dir}" -name "vic_*.tar.gz"`

  # untar vic package to tmp dir
  tar -zxf "${tar_gz}" -C /tmp

  # get certificate thumbprint
  tp=`openssl x509 -fingerprint -noout -in "${cert}" | awk -F= '{print $2}'`

  # replace configs files
  lconfig=/tmp/vic/ui/VCSA/configs
  wconfig=/tmp/vic/ui/vCenterForWindows/configs

  cur_tp_l=`awk '/VIC_UI_HOST_THUMBPRINT=/{print $NF}' $lconfig`
  sed -i -e s/${cur_tp_l}/VIC_UI_HOST_THUMBPRINT=\"${tp}\"/g $lconfig

  cur_tp_w=`awk '/vic_ui_host_thumbprint=/{print $NF}' $wconfig`
  sed -i -e s/${cur_tp_w}/vic_ui_host_thumbprint=${tp}/g $wconfig

  file_server="https://${hostname}:${port}"
  cur_file_server_l=`awk '/VIC_UI_HOST_URL=/{print $NF}' $lconfig`
  sed -i -e s%${cur_file_server_l}%VIC_UI_HOST_URL=\"${file_server}\"%g $lconfig

  cur_file_server_w=`awk '/vic_ui_host_url=/{print $NF}' $wconfig`
  sed -i -e s%${cur_file_server_w}%vic_ui_host_url=${file_server}%g $wconfig

  # tar all files again
  tar zcf $tar_gz -C /tmp vic
  rm -rf /tmp/vic
}

function secure {
  fileserver_cert=$(ovfenv -k fileserver.ssl_cert)
  fileserver_key=$(ovfenv -k fileserver.ssl_cert_key)
  if [ -n "$fileserver_cert" ] && [ -n "$fileserver_key" ]; then
    echo "fileserver_cert and fileserver_key are both set, using customized certificate"
    formatCert "$fileserver_cert" $cert
    formatCert "$fileserver_key" $key
    echo "customized" > $flag
    return
  fi

  if [ ! -e $ca_cert ] || [ ! -e $cert ] || [ ! -e $key ]; then
    echo "CA, Certificate or key file does not exist, will generate a self-signed certificate"
    genCert
    return
  fi

  if [ ! -e $flag ]; then
    echo "The file which records the way generating certificate does not exist, will generate a new self-signed certificate"
    genCert
    return
  fi

  if [ ! $(cat $flag) = "self-signed" ]; then
    echo "The way generating certificate changed, will generate a new self-signed certificate"
    genCert
    return
  fi

  cn=$(openssl x509 -noout -subject -in $cert | sed -n '/^subject/s/^.*CN=//p') || true
  if [ "$hostname" !=  "$cn" ]; then
    echo "Common name changed: $cn -> $hostname , will generate a new self-signed certificate"
    genCert
    return
  fi

  ip_in_cert=$(openssl x509 -noout -text -in $cert | sed -n '/IP Address:/s/.*IP Address://p') || true
  if [ "$ip_address" !=  "$ip_in_cert" ]; then
    echo "IP changed: $ip_in_cert -> $ip_address , will generate a new self-signed certificate"
    genCert
    return
  fi

  echo "Use the existing CA, certificate and key file"
  echo "Copy CA certificate to $ca_download_dir"
  cp $ca_cert $ca_download_dir/
}

function detectHostname {
  hostname=$(hostnamectl status --static) || true
  if [ -n "$hostname" ]; then
    if [ "$hostname" = "localhost.localdomain" ]; then
      hostname=""
      return
    fi
    echo "Get hostname from command 'hostnamectl status --static': $hostname"
    return
  fi
}

hostname=""
ip_address=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

#Modify hostname
detectHostname
if [[ x$hostname != "x" ]]; then
  echo "Hostname: ${hostname}"
else
  echo "Hostname is null, set it to IP"
  hostname=${ip_address}
fi

# Init certs
secure

iptables -w -A INPUT -j ACCEPT -p tcp --dport $port
iptables -w -A INPUT -j ACCEPT -p tcp --dport 80

# Update configurations
updateConfigFiles
