# Copyright 2016-2018 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
*** Settings ***
Resource  ../resources/Util.robot

*** Test Cases ***
Test 5-03-Multiple-Datacenter
    ${status}=  Get State Of Github Issue  2151
    Run Keyword If  '${status}' == 'closed'  Fail  Test 5-03-Multiple-Datacenter.robot needs to be moved out of "need-to-fix" folder now that Issue #2151 has been resolved
    Log  Test skipped; see issue \#2151  WARN

Test 5-05-Enhanced-Linked-Mode
    ${status}=  Get State Of Github Issue  2152
    Run Keyword If  '${status}' == 'closed'  Fail  5-05-Enhanced-Linked-Mode.robot needs to be moved out of "need-to-fix" folder now that Issue #2152 has been resolved
    Log  Test skipped; see issue \#2152  WARN

