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
Documentation  Test 5-02 - OVA Upgrade
Resource  ../../resources/Util.robot
Suite Setup  Wait Until Keyword Succeeds  10x  10m  OVA Upgrade Setup
#Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${esx_number}=  3
${datacenter}=  ha-datacenter

*** Keywords ***
OVA Upgrade Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    Log To Console  \nStart downloading vic-v1.2.1-4104e5f9.ova...
    ${pid1}=  Start Process  wget -nc https://storage.googleapis.com/vic-product-ova-releases/vic-v1.2.1-4104e5f9.ova  shell=True
    ${latest-ova}=  Run  gsutil ls -l gs://vic-product-ova-builds/ | grep -v TOTAL | sort -k2r | (head -n1 ; dd of=/dev/null 2>&1 /dev/null) | xargs | cut -d ' ' -f 3 | cut -d '/' -f 4
    Log To Console  \nStart downloading ${latest-ova}...
    ${pid2}=  Start Process  wget -nc https://storage.googleapis.com/vic-product-ova-builds/${latest-ova}  shell=True
    
    ${esx1}  ${esx2}  ${esx3}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${esx3-ip}  ${vc-ip}=  Create a Simple VC Cluster
    Log To Console  Finished Creating Cluster ${vc}
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  ${esx3}  %{NIMBUS_USER}-${vc}

    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /ha-datacenter/host/cls
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  TEST_DATASTORE  datastore1

    ${ret}=  Wait For Process  ${pid1}
    ${ret}=  Wait For Process  ${pid2}

*** Test Cases ***
Test
    Log To Console  \nStarting test...
    Set Environment Variable  OVA_NAME  OVA-5-02-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA  vic-v1.2.1-4104e5f9.ova  %{OVA_NAME}
    
    Set Global Variable  ${FIREFOX_BROWSER}  firefox
    Set Global Variable  ${GRID_URL}  http://127.0.0.1:4444/wd/hub
    Set Global Variable  ${EXPLICIT_WAIT}  30
    Set Global Variable  ${EXTRA_EXPLICIT_WAIT}  50
    Set Global Variable  ${PRIMARY_PORT}  8282
    Set Global Variable  ${GS_PAGE_PORT}  9443
    Set Global Variable  ${HARBOR_PORT}  443
    Set Global Variable  ${IP_URL}  https://%{OVA_IP}
    Set Global Variable  ${BASE_URL}  ${IP_URL}:${PRIMARY_PORT}
    Set Global Variable  ${GS_PAGE_BASE_URL}  ${IP_URL}:${GS_PAGE_PORT}
    Set Global Variable  ${COMPLETE_INSTALL_URL}  ${GS_PAGE_BASE_URL}/?login=true
    Set Global Variable  ${HARBOR_URL}  ${IP_URL}:${HARBOR_PORT}
    Set Global Variable  ${DEFAULT_HARBOR_NAME}  default-vic-registry
    Set Global Variable  ${DEFAULT_HARBOR_PROJECT}  default-project
    Open Firefox Browser
    Log In And Complete OVA Installation
    # TODO: Still need to walkthrough init and creation wizard

    Set Environment Variable  OVA_NAME  OVA-5-02-TEST-LATEST
    Install VIC Product OVA  ${latest-ova}  %{OVA_NAME}
    