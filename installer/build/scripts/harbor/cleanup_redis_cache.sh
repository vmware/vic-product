#!/usr/bin/bash
# Copyright 2020 VMware, Inc. All Rights Reserved.
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

function cleanup_redis_cache {
  sleep 30
  echo "cleaning up cache in the redis"
  local sleep_t=5
  local n=0
  while [ $n -lt 30 ]; do
    is_redis_ready=$(/usr/bin/docker ps | grep -i redis | wc -l)
    if [ $is_redis_ready -eq 1 ]; then
      redis_cid=$(/usr/bin/docker ps |grep -i redis | awk '{print $1}')
      echo "redis_cid: $redis_cid"
      docker exec -i $redis_cid redis-cli -n 1 flushdb
      echo "done"
      break
    fi
    let n+=1
    echo "retry after $sleep_t seconds............."
    sleep $sleep_t
  done
}

if [ "${REGISTRY_GC_ENABLED}" == "true" ]; then
  cleanup_redis_cache 2>&1 >> /var/log/harbor/gc.log || true
fi
