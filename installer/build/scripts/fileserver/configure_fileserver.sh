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
set -uf -o pipefail

umask 077
data_dir="/opt/vmware/fileserver"
files_dir="${data_dir}/files"
cert="/storage/data/certs/server.crt"
error_index_file="index.html"

ca_download_dir="${data_dir}/ca_download"
mkdir -p ${ca_download_dir}

function updateConfigFiles {
  set -e
  # cove cli has package in form of vic-adm_*.tar.gz, so use 'vic_*.tar.gz' here
  # to avoid including cove cli
  tar_gz=$(find "${data_dir}" -maxdepth 1 -name "vic_*.tar.gz")

  # untar vic package to tmp dir
  tar -zxf "${tar_gz}" -C /tmp

  # get certificate thumbprint
  tp=$(openssl x509 -fingerprint -noout -in "${cert}" | awk -F= '{print $2}')

  # replace configs files
  lconfig=/tmp/vic/ui/VCSA/configs
  wconfig=/tmp/vic/ui/vCenterForWindows/configs

  cur_tp_l=$(awk '/VIC_UI_HOST_THUMBPRINT=/{print $NF}' $lconfig)
  sed -i -e s/${cur_tp_l}/VIC_UI_HOST_THUMBPRINT=\"${tp}\"/g $lconfig

  cur_tp_w=$(awk '/vic_ui_host_thumbprint=/{print $NF}' $wconfig)
  sed -i -e s/${cur_tp_w}/vic_ui_host_thumbprint=${tp}/g $wconfig

  file_server="https://${HOSTNAME}:${FILESERVER_PORT}"
  cur_file_server_l=$(awk '/VIC_UI_HOST_URL=/{print $NF}' $lconfig)
  sed -i -e s%${cur_file_server_l}%VIC_UI_HOST_URL=\"${file_server}\"%g $lconfig

  cur_file_server_w=$(awk '/vic_ui_host_url=/{print $NF}' $wconfig)
  sed -i -e s%${cur_file_server_w}%vic_ui_host_url=${file_server}%g $wconfig

  # tar all files again
  tar zcf "$files_dir/$(basename $tar_gz)" -C /tmp vic
  rm -rf /tmp/vic
}

iptables -w -A INPUT -j ACCEPT -p tcp --dport "${FILESERVER_PORT}"

# Update configurations, run in subshell to preserve +e
( updateConfigFiles )
if [ $? -eq 0 ]; then
  echo "Fileserver configuration complete."
  if [ -f "${error_index_file}" ]; then
    rm "${files_dir}/${error_index_file}"
  fi
else
  echo "Fileserver configuration failed."
  cp "${data_dir}/${error_index_file}" "${files_dir}/${error_index_file}"
fi
