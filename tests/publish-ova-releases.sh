#!/bin/bash
# Copyright 2019 VMware, Inc. All Rights Reserved.
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

set -e

echo -e "BRANCH = $DRONE_BRANCH\nEVENT = $DRONE_BUILD_EVENT\nTAG = $DRONE_TAG\n"

gs_private_key=${GS_PRIVATE_KEY:?Please set secret variable named GS_PRIVATE_KEY}
gs_client_email=${GS_CLIENT_EMAIL:?Please set secret variable named GS_CLIENT_EMAIL}
gs_project_id=${GS_PROJECT_ID:?Please set secret variable named GS_PROJECT_ID}
source_dir=${SOURCE:?Please set env variable named SOURCE}
target_bucket=${TARGET:?Please set env variable named TARGET}
ova_file_name=$(cd ${source_dir} && echo vic-*.ova)

# GC credentials
keyfile=~/${bucket}.key
botofile=~/.boto
if [ ! -f $keyfile ]; then
    echo -en $GS_PRIVATE_KEY > $keyfile
    chmod 400 $keyfile
fi
if [ ! -f $botofile ]; then
    echo "[Credentials]" >> $botofile
    echo "gs_service_key_file = $keyfile" >> $botofile
    echo "gs_service_client_id = $GS_CLIENT_EMAIL" >> $botofile
    echo "[GSUtil]" >> $botofile
    echo "content_language = en" >> $botofile
    echo "default_project_id = $GS_PROJECT_ID" >> $botofile
fi

if [ -f ${source_dir}/${ova_file_name} ]; then
  if [[ ${DRONE_TAG} =~ ^v([0-9]+\.){2}[0-9]+$ ]]; then
      if gsutil cp ${source_dir}/${ova_file_name} gs://${target_bucket}; then
        gsutil acl ch -u AllUsers:R gs://${target_bucket}/${ova_file_name}
        echo "Upload ova file successfully to ${target_bucket}. download url: https://storage.googleapis.com/${target_bucket}/${ova_file_name}"
      else
        echo "upload failed-----------------"
        exit 1
      fi
  else
    if gsutil cp ${source_dir}/${ova_file_name} gs://vic-product-ova-builds; then
      gsutil acl ch -u AllUsers:R gs://vic-product-ova-builds/${ova_file_name}
      echo "Upload ova file successfully to vic-product-ova-builds. download url: https://storage.googleapis.com/vic-product-ova-builds/${ova_file_name}"
    else
      echo "upload failed-----------------"
      exit 1
    fi
  fi
else
  echo "Not found target file."
  exit 1
fi

rm -f $keyfile
