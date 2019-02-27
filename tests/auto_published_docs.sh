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

mkdir -p ./assets/files/html/latest

GITHUB_TOKEN=${GITHUB_AUTOMATION_API_KEY}
GITHUB_USER=vmware
GITHUB_REPO=https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/vic-product.git
SRC_DIR=assets/files/html/latest
TARGET_DIR=assets/files/html/latest
branch_name='gh-pages'
USER_NAME=vmware
USER_EMAIL='<vmware@vmware.com>'
date=$(date +%Y%m%d)
commit_msg="Update user docs at ${date}"
is_changed=$(git diff --name-only HEAD^ docs/user_doc)

echo changed files:
echo ${is_changed}

if [ "${is_changed}" != "" ]; then

  echo "install dependencies plugin............................"
  npm install --prefix ./docs/user_doc gitbook-plugin-page-toc-button
  npm install --prefix ./docs/user_doc gitbook-plugin-analytics

  echo "building docs....................................."
  gitbook build docs/user_doc ${SRC_DIR}
 
  echo "clean cached repo................................."
  gh-pages-clean

  echo "publish docs......................................."
  gh-pages -d ${SRC_DIR} -b ${branch_name} -e ${TARGET_DIR} -m "${commit_msg}" -u "${USER_NAME} ${USER_EMAIL}" -r ${GITHUB_REPO}
else
  echo "Nothing is changed in docs/user_doc."
fi

