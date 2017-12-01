#!/usr/bin/env bash
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

cert_dir="/storage/data/certs"
log_dir="/storage/log/vic-machine-server"
cert="${cert_dir}/server.cert.pem"
key="${cert_dir}/server.key.pem"
ca_cert="${cert_dir}/ca.crt"
ca_key="${cert_dir}/ca.key"
csr="${cert_dir}/server.csr"
ext="${cert_dir}/extfile.cnf"
flag="${cert_dir}/cert_gen_type"

# TODO Cert code is temporary until this is resolved https://github.com/vmware/vic-product/issues/881
# Format cert file
function formatCert {
  content=$1
  file=$2
  echo "$content" | sed -r 's/(-{5}BEGIN [A-Z ]+-{5})/&\n/g; s/(-{5}END [A-Z ]+-{5})/\n&\n/g' | sed -r 's/.{64}/&\n/g; /^\s*$/d' > "$file"
}

function genCert {
  if [ ! -e $ca_cert ] || [ ! -e $ca_key ]
  then
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout $ca_key \
      -x509 -days 1095 -out $ca_cert -subj \
      "/C=US/ST=California/L=Palo Alto/O=VMware, Inc./OU=Containers on vSphere/CN=Self-signed by VMware, Inc."
  fi
  openssl req -newkey rsa:4096 -nodes -sha256 -keyout $key \
    -out $csr -subj \
    "/C=US/ST=California/L=Palo Alto/O=VMware/OU=Containers on vSphere/CN=$hostname"

  echo "Add subjectAltName = IP: $ip_address to certificate"
  echo subjectAltName = IP:"$ip_address" > $ext
  openssl x509 -req -days 1095 -in $csr -CA $ca_cert -CAkey $ca_key -CAcreateserial -extfile $ext -out $cert

  echo "Creating certificate chain for $cert"
  cat $ca_cert >> $cert

  echo "self-signed" > $flag
}

function secure {
  ssl_cert=${TLS_CERT}
  ssl_cert_key=${TLS_PRIVATE_KEY}
  ca_cert_input=${TLS_CA_CERT}
  if [ -n "$ssl_cert" ] && [ -n "$ssl_cert_key" ] && [ -n "$ca_cert_input" ]; then
    echo "ssl_cert, ssl_cert_key, and ca_cert are set, using customized certificate"
    formatCert "$ssl_cert" $cert
    formatCert "$ssl_cert_key" $key
    formatCert "$ca_cert_input" $ca_cert
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

  if [ ! "$(cat $flag)" = "self-signed" ]; then
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
}

function detectHostname {
  hostname=$(hostnamectl status --static) || true
  if [ -n "$hostname" ]; then
    echo "Get hostname from command 'hostnamectl status --static': $hostname"
    return
  fi
}

mkdir -p ${cert_dir}
chown -R 10000:10000 ${cert_dir}
mkdir -p ${log_dir}
chown -R 10000:10000 ${log_dir}

hostname=""
ip_address=$(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+)\/.*/\1/p')

#Modify hostname
detectHostname
if [ -z $hostname ]; then
  echo "Hostname is null, set it to IP"
  hostname=${ip_address}
fi

# Init certs
secure

iptables -w -A INPUT -j ACCEPT -p tcp --dport "${VIC_MACHINE_SERVER_PORT}"

echo "Finished vic-machine-server config"
