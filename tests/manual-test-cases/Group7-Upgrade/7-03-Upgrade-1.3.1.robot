# Copyright 2018 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  Test 7-03 - Upgrade 1.3.1
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  OVA Upgrade Setup
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Copy Support Bundle  %{OVA_IP}

*** Variables ***
${old-ova-file-name}=  vic-v1.3.1-3409-132fb13d.ova
${old-ova-version}=    v1.3.1
${old-ova-cert-path}=  /storage/data/admiral/ca_download
${new-ova-cert-path}=  /storage/data/admiral/ca_download

*** Keywords ***
OVA Upgrade Setup
     Setup Simple VC And Test Environment with Shared iSCSI Storage

*** Test Cases ***
Upgrade OVA 1.3.1
    Auto Upgrade OVA With Verification  7-03-UPGRADE-1-3-1  ${old-ova-file-name}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  dc1
    ${rc}  ${output}=  Run And Return Rc And Output  govc about -u=%{TEST_URL}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    ${status}=  Run Keyword And Return Status  Should Contain  ${output}  6.0
    Run Keyword Unless  ${status}  Stop All Containers
    Run Keyword Unless  ${status}  Delete All VCH Using UI
