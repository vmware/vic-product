# Copyright 2019 VMware, Inc. All Rights Reserved.
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
Documentation  Test 7-05 - Upgrade 1.4.4
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  OVA Upgrade Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Copy Support Bundle  %{OVA_IP}

*** Variables ***
${sample-image-tag}=  1.4.4
${old-ova-file-name}=  vic-v1.4.4-6375-0a6da3d4.ova
${old-ova-version}=  v1.4.4
${specific-upgrade-file-name}=  vic-v1.5.0-6915-e18e6647.ova
${specific-upgrade-ova-version}=  v1.5.0
${old-ova-cert-path}=  /storage/data/admiral/ca_download
${new-ova-cert-path}=  /storage/data/admiral/ca_download

*** Keywords ***
OVA Upgrade Setup
    Setup Simple VC And Test Environment with Shared iSCSI Storage

Custom Auto Upgrade Specific OVA With Verification
    # This is a complete keyword to run auto upgrade process and verify that upgrade is successful
    # This assumes that testbed is already setup
    [Arguments]  ${test-name}  ${old-ova-file-name}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  ${old-ova-datacenter}
    Set Global Variable  ${OVA_CERT_PATH}  ${old-ova-cert-path}
    # get ova file
    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}
    # setup and deploy old version of ova
    Setup And Install Specific OVA Version  ${old-ova-save-file}  ${test-name}
    # install VCH, create running container and push image to harbor
    Run  mkdir -p ./auto/${old-ova-version}
    Download VIC Engine If Not Already  %{OVA_IP}  auto/${old-ova-version}
    Install VCH With Busybox Container And Push That Image to Harbor  %{OVA_IP}  ${sample-image-tag}  auto/${old-ova-version}
    # save IP of old ova appliance
    Set Environment Variable  OVA_IP_OLD  %{OVA_IP}

    # install specific OVA appliance and don't initialize
    Log To Console  \nInstall specific version of OVA and auto upgrade...
    Set Environment Variable  OVA_NAME  ${test-name}-Specific
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Custom Install Specific OVA Version Without Initialize  ${specific-upgrade-file-name}  %{OVA_NAME}

    Execute Upgrade Script  %{OVA_IP}  %{OVA_IP_OLD}  ${old-ova-datacenter}  ${old-ova-version}
    Check Services Running Status
    Verify Running Busybox Container And Its Pushed Harbor Image  %{OVA_IP}  ${sample-image-tag}  ${new-ova-cert-path}  docker-endpoint=${VCH-PARAMS}
    Stop All Containers
    Second Auto Upgrade To Latest  7-05-UPGRADE-1-5-0  ${local_ova_file}  1.5.0  ${old-ova-datacenter}  
    Stop All Containers    

Custom Install Specific OVA Version Without Initialize
    [Arguments]  ${ova-file}  ${ova-name}
    Log To Console  \nSetting OVA variables...
    Set Environment Variable  OVA_NAME  ${ova-name}
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    ${ova-file}=  Get OVA Release File For Nightly  ${ova-file}
    Install VIC Product OVA And Wait For Home Page  ${ova-file}  %{OVA_NAME} 

Second Auto Upgrade To Latest
    [Arguments]  ${test-name}  ${ova-file}  ${image-tag}  ${old-ova-datacenter}
    Run  mkdir -p ./auto/${image-tag}
    Download VIC Engine If Not Already  %{OVA_IP}  auto/${image-tag}
    Install VCH With Busybox Container And Push That Image to Harbor  %{OVA_IP}  ${image-tag}  auto/${image-tag}
    Set Environment Variable  OVA_IP_OLD  %{OVA_IP}
    Log To Console  \nInstall latest version of OVA and auto upgrade...
    Set Environment Variable  OVA_NAME  ${test-name}-latest
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA And Wait For Home Page  ${ova-file}  %{OVA_NAME}
    Execute Upgrade Script  %{OVA_IP}  %{OVA_IP_OLD}  ${old-ova-datacenter}  ${specific-upgrade-ova-version}
    Check Services Running Status  
    Verify Running Busybox Container And Its Pushed Harbor Image  %{OVA_IP}  ${image-tag}  ${new-ova-cert-path}  docker-endpoint=${VCH-PARAMS}
    Verify Running Busybox Container And Its Pushed Harbor Image  %{OVA_IP}  ${sample-image-tag}  ${new-ova-cert-path}  docker-endpoint=${VCH-PARAMS}

*** Test Cases ***
Upgrade OVA 1.4.4
    Custom Auto Upgrade Specific OVA With Verification  7-05-UPGRADE-1-4-4  ${old-ova-file-name}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  dc1
    ${rc}  ${output}=  Run And Return Rc And Output  govc about -u=%{TEST_URL}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    ${status}=  Run Keyword And Return Status  Should Contain  ${output}  6.0
    Run Keyword Unless  ${status}  Delete All VCH Using UI
