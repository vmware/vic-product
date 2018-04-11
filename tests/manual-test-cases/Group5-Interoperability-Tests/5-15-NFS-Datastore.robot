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
Documentation  Test 5-15 - NFS Datastore
Resource  ../../resources/Util.robot
Suite Setup  Wait Until Keyword Succeeds  10x  10m  NFS Datastore Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Keywords ***
NFS Datastore Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    ${esx1}  ${esx2}  ${esx3}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${esx3-ip}  ${vc-ip}=  Create a Simple VC Cluster  datacenter1  cls1
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  ${esx3}  %{NIMBUS_USER}-${vc}

    ${name}  ${ip}=  Deploy Nimbus NFS Datastore  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    Append To List  ${list}  ${name}

    ${out}=  Run  govc datastore.create -mode readWrite -type nfs -name nfsDatastore -remote-host ${ip} -remote-path /store /datacenter1/host/cls1
    Should Be Empty  ${out}

    Set Environment Variable  TEST_DATASTORE  nfsDatastore
    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /datacenter1/host/cls1
    Set Environment Variable  TEST_TIMEOUT  30m

*** Test Cases ***
Test
    Log To Console  \nStarting test...
    Set Environment Variable  OVA_NAME  OVA-5-15-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA Only  vic-*.ova  %{OVA_NAME}

    Set Browser Variables

    # Install VIC Plugin
    Download VIC And Install UI Plugin  %{OVA_IP}

    Set Global Variable  ${GRID_URL}  http://127.0.0.1:4444/wd/hub
    
    # Navigate to the wizard and create a VCH
    Open Firefox Browser
    Navigate To VC UI Home Page
    Login On Single Sign-On Page
    Verify VC Home Page
    Navigate To VCH Creation Wizard
    Navigate To VCH Tab
    Click New Virtual Container Host Button

    #general
    ${name}=  Evaluate  'VCH-5-15-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
    Input VCH Name  ${name}
    Click Next Button
    # compute capacity
    Log To Console  Selecting compute resource...
    Wait Until Element Is Visible And Enabled  css=.clr-treenode-children .cc-resource
    Click Button  css=.clr-treenode-children .cc-resource
    Click Next Button
    # storage capacity
    Select Image Datastore  %{TEST_DATASTORE}
    Click Next Button
    #networks
    Select Bridge Network  %{BRIDGE_NETWORK}
    Select Public Network  %{PUBLIC_NETWORK}  
    Click Next Button
    # security
    Toggle Client Certificate Option
    Click Next Button
    #registry access
    Click Next Button
    # ops-user
    Input Ops User Name  %{TEST_USERNAME}
    Input Ops User Password  %{TEST_PASSWORD}
    Click Next Button
    # summary
    Click Finish Button
    Unselect Frame
    Wait Until Page Does Not Contain  VCH name
    # retrieve docker parameters from UI
    Set Docker Host Parameters

    # run vch regression tests
    Run Docker Regression Tests For VCH
