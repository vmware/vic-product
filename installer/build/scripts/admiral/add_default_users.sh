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
sleep 30    # let admiral and harbor stabalize before trying to add users
            # and groups to the default project

# Populated by configure_admiral.sh
ADMIRAL_EXPOSED_PORT=""
ADMIRAL_DATA_LOCATION=""
OVA_VM_IP=""

# Add default users
# Usage: get_property FILE KEY
function get_property
{
    grep "^$2=" "$1" | cut -d'=' -f2
}

create_def_users=$(ovfenv -k default_users.create_def_users)
user_prefix=$(ovfenv -k default_users.def_user_prefix)
user_password=$(ovfenv -k default_users.def_user_password)

echo "add_default_users: $create_def_users, $user_prefix"

if [ ${create_def_users} != "True" ] || [ -z ${user_prefix} ] || [ -z ${user_password} ]; then
    echo "add_default_users, not creating default users"
    exit 0
fi

psc_prop_file=${ADMIRAL_DATA_LOCATION}/configs/psc-config.properties
token_file=/etc/vmware/psc/admiral/tokens.properties

echo "add_default_users wating for token"
token_tries=0
while true ; do
    if [ -f $token_file ]; then
        break;
    fi
    ((token_tries++))
    sleep 1
    if [ ${token_tries} -eq  60 ]; then
        echo "add_default_users, admiral start up failed, no tokens after one minute"
        exit -1
    fi
done

token=`cat $token_file`

echo "add_default_users loaded token"

tenant=`get_property $psc_prop_file "tenant"`
defuser_prefix=`get_property $psc_prop_file "default-user-prefix"`
admiral_url=`get_property $psc_prop_file admiral-url`
# remove backslashes
admiral_url=`echo $admiral_url | sed 's/\\\//g'`

cloud_admin_name=$defuser_prefix
cloud_admin_name+="-cloud-admin"
cloud_admin_name+="@"
cloud_admin_name+=$tenant

# Wait for admiral to come up, max 1 minute
check_admiral_url=$admiral_url
check_admiral_url+="/projects"

echo "add_default_user wating for ping"
current_tries=0
while true ; do
    http_code=`curl -s -o /dev/null \
    -w "%{http_code}" \
    -H 'cache-control: no-cache' \
    -H "x-xenon-auth-token: $token" \
    --insecure \
    --max-time 2 \
    ${check_admiral_url}`

    echo "add_default_users ping result: ${http_code}"

    if [ ${http_code} -eq "200" ]; then
        break;
    fi

    echo "add_default_users ping failed"

    sleep 1
    ((current_tries++))
    if [ ${current_tries} -eq  30 ]; then
        echo "add_default_users Admiral startup failed, no ping after one minute"
        exit -1
    fi
done

echo "add_default_users successful ping"

add_cloud_admin_url=$admiral_url
add_cloud_admin_url+="/auth/idm/principals/"
add_cloud_admin_url+=$cloud_admin_name
add_cloud_admin_url+="/roles"

echo $add_cloud_admin_url

curl -X PATCH \
  -s \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -H "x-xenon-auth-token: $token" \
  -d '{ "add":["CLOUD_ADMIN"] }' \
  --insecure \
  $add_cloud_admin_url

echo
echo "add_default_users added cloud-admin"

add_users_to_project_url=$admiral_url
add_users_to_project_url+="/projects/default-project"

echo $add_users_to_project_url

project_admin_name=$defuser_prefix
project_admin_name+="-devops-admin"
project_admin_name+="@"
project_admin_name+=$tenant

project_dev_name=$defuser_prefix
project_dev_name+="-developer"
project_dev_name+="@"
project_dev_name+=$tenant

curl -X PATCH \
  -s \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/json' \
  -H "x-xenon-auth-token: $token" \
  -d "{ \"administrators\": { \"add\" : [\"$project_admin_name\"] }, \"members\": { \"add\" : [\"$project_dev_name\"] } }" \
  --insecure \
  $add_users_to_project_url

echo
echo "add_default_users added project-admin"

echo