#!/bin/bash

data_dir=/data/kov
cert_dir=${data_dir}/cert
cert=${cert_dir}/server.crt
key=${cert_dir}/server.key
vmdk=${data_dir}/base_$(cat /etc/vmware/kov/kovd_revision).vmdk

port="$(ovfenv -k cluster_manager.port)"
mkdir -p /etc/vmware/kov

cat > /etc/vmware/kov/kov_env_vars <<EOF
KOVD_EXPOSED_PORT=${port}
KOVD_KEY_LOCATION=$key
KOVD_CERT_LOCATION=$cert
KOV_VMDK_LOCATION=$vmdk
KOVD_DATA_DIR=$data_dir
EOF
