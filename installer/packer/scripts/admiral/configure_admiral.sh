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

ADMIRAL_PORT=$(ovfenv -k management_portal.port)

data_dir="/data/admiral"
conf_dir="/etc/vmware/admiral"
script_dir="/etc/vmware"
keytool="/usr/bin/keytool"

cert_dir="${data_dir}/cert"
flag="${data_dir}/cert_gen_type"
admiral_start_script="${conf_dir}/start_admiral.sh"
admiral_add_default_users_script=${conf_dir}/add_default_users.sh

ca_download_dir="${data_dir}/ca_download"
mkdir -p "${cert_dir}"
rm -rf "${ca_download_dir}"
mkdir -p "${ca_download_dir}"

cert="${cert_dir}/server.crt"
key="${cert_dir}/server.key"
jks="${cert_dir}/trustedcertificates.jks"
csr="${cert_dir}/server.csr"
ca_cert="${cert_dir}/ca.crt"
ca_key="${cert_dir}/ca.key"
ext="${cert_dir}/extfile.cnf"

#Configure attr in script
function configureScript {
  script_name=$1
  cfg_key=$2
  cfg_value=$3

  if [ -n "$cfg_key" ]; then
    cfg_value=$(echo "$cfg_value" | sed -r -e 's%[\/&%]%\\&%g')
    sed -i -r "s%#?$cfg_key\s*=\s*.*%$cfg_key=$cfg_value%" $script_name
  fi
}

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
  echo "Copy CA certificate to $ca_download_dir"
  cp $ca_cert $ca_download_dir/
  $script_dir/set_guestinfo.sh -f $ca_cert "admiral.ca"

  echo "creating java keystore with self-signed CA"
  if [ -f "$jks" ]; then
    echo "removing existing keystore $jks"
    rm -f $jks
  else
    echo "no keystore present, creating"
  fi

  $keytool -import -noprompt -v -trustcacerts -alias selfsignedca -file $ca_cert -keystore $jks -keypass changeit -storepass changeit
}

function secure {
  ssl_cert=$(ovfenv -k management_portal.ssl_cert)
  ssl_cert_key=$(ovfenv -k management_portal.ssl_cert_key)
  if [ -n "$ssl_cert" ] && [ -n "$ssl_cert_key" ]; then
    echo "ssl_cert and ssl_cert_key are both set, using customized certificate"
    formatCert "$ssl_cert" $cert
    formatCert "$ssl_cert_key" $key
    echo "customized" > $flag
    echo "creating java keystore with provided cert for xenon"
    if [ -f "$jks" ]; then
      echo "removing existing keystore $jks"
      rm -f $jks
    else
      echo "no keystore present, creating"
    fi
    $keytool -import -noprompt -v -trustcacerts -alias selfsignedca -file $cert -keystore $jks -keypass changeit -storepass changeit
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
  configureScript $admiral_start_script "hostname" ${hostname}
else
  echo "Hostname is null, set it to IP"
  hostname=${ip_address}
fi

# put admiral endpoint in guestinfo
$script_dir/set_guestinfo.sh admiral.endpoint https://"$ip_address":"$ADMIRAL_PORT"

# Init certs
secure

configureScript $admiral_start_script ADMIRAL_DATA_LOCATION $data_dir
configureScript $admiral_start_script ADMIRAL_EXPOSED_PORT "$ADMIRAL_PORT"
configureScript $admiral_start_script OVA_VM_IP "$ip_address"

configureScript $admiral_add_default_users_script ADMIRAL_DATA_LOCATION $data_dir
configureScript $admiral_add_default_users_script ADMIRAL_EXPOSED_PORT "$ADMIRAL_PORT"
configureScript $admiral_add_default_users_script OVA_VM_IP "$ip_address"

iptables -w -A INPUT -j ACCEPT -p tcp --dport "$ADMIRAL_PORT"

touch $data_dir/custom.conf


HARBOR_PORT=$(ovfenv -k registry.port)
# Configure the integration URL
echo "harbor.tab.url=https://${hostname}:${HARBOR_PORT}" > $data_dir/custom.conf

# Copy files needed by Admiral into one directory
config_dir=$data_dir/configs
mkdir -p $config_dir
admiral_psc_dir=/etc/vmware/psc/admiral

cp $jks $config_dir
cp $key $config_dir
cp $cert $config_dir
cp $data_dir/custom.conf $config_dir/config.properties
cp $admiral_psc_dir/psc-config.keystore $config_dir
cp $admiral_psc_dir/psc-config.properties $config_dir

# Change Admiral's keystore.file value to point to mounted path in container
sed -i "/\b\(keystore.file\)\b/d" $config_dir/psc-config.properties
echo "keystore.file=/configs/psc-config.keystore" >> $config_dir/psc-config.properties

# Start on startup
echo "Enable admiral startup"
systemctl enable admiral_startup.service
systemctl enable admiral.service
