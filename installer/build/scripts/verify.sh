#!/usr/bin/bash
# Copyright 2018 VMware, Inc. All Rights Reserved.
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

salt=`cat /etc/shadow | grep root | cut -d : -f 2 | cut -d $ -f 3`
salt_param='$6$'$salt'$'
origin_passwd=`cat /etc/shadow | grep root | cut -d : -f 2 | cut -d $ -f 4`
first_param='"'$1'"'
second_param='"'$salt_param'"'
passwd=`python -c 'import crypt; print crypt.crypt('$first_param', '$second_param')' | cut -d $ -f 4`
if [  $origin_passwd == $passwd  ]; then
  exit 0
fi
exit 1
