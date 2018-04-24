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
Documentation  Test 5-04 - Multiple Clusters
Resource  ../../resources/Util.robot
Suite Setup  Wait Until Keyword Succeeds  10x  10m  Multiple Cluster Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Keywords ***
# Insert elements from dict2 into dict1, overwriting conflicts in dict1 & returning new dict
Combine Dictionaries
    [Arguments]  ${dict1}  ${dict2}
    ${dict2keys}=  Get Dictionary Keys  ${dict2}
    :FOR  ${key}  IN  @{dict2keys}
    \    ${elem}=  Get From Dictionary  ${dict2}  ${key}
    \    Set To Dictionary  ${dict1}  ${key}  ${elem}
    [Return]  ${dict1}

Multiple Cluster Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    &{esxes}=  Create Dictionary
    ${num_of_esxes}=  Evaluate  2
    :FOR  ${i}  IN RANGE  3
    # Deploy some ESXi instances
    \    &{new_esxes}=  Deploy Multiple Nimbus ESXi Servers in Parallel  ${num_of_esxes}  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    \    ${esxes}=  Combine Dictionaries  ${esxes}  ${new_esxes}

    # Investigate to see how many were actually deployed
    \    ${len}=  Get Length  ${esxes}
    \    ${num_of_esxes}=  Evaluate  ${num_of_esxes} - ${len}

    # Exit if we've got enough & continue loop if we don't
    \    Exit For Loop If  ${len} >= 2
    \    Log To Console  Only got ${len} ESXi instance(s); Trying again

    @{esx-names}=  Get Dictionary Keys  ${esxes}
    @{esx-ips}=  Get Dictionary Values  ${esxes}
    ${esx1}=  Get From List  ${esx-names}  0
    ${esx2}=  Get From List  ${esx-names}  1
    ${esx1-ip}=  Get From List  ${esx-ips}  0
    ${esx2-ip}=  Get From List  ${esx-ips}  1

    ${esx3}  ${esx4}  ${esx5}  ${vc}  ${esx3-ip}  ${esx4-ip}  ${esx5-ip}  ${vc-ip}=  Create a Simple VC Cluster  datacenter1  cls1
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  ${esx3}  ${esx4}  ${esx5}  %{NIMBUS_USER}-${vc}

    Log To Console  Create cluster2 on the VC
    ${out}=  Run  govc cluster.create cls2
    Should Be Empty  ${out}
    ${out}=  Run  govc cluster.add -hostname=${esx1-ip} -username=root -dc=datacenter1 -cluster=cls2 -password=e2eFunctionalTest -noverify=true
    Should Contain  ${out}  OK

    Log To Console  Create cluster3 on the VC
    ${out}=  Run  govc cluster.create cls3
    Should Be Empty  ${out}
    ${out}=  Run  govc cluster.add -hostname=${esx2-ip} -username=root -dc=datacenter1 -cluster=cls3 -password=e2eFunctionalTest -noverify=true
    Should Contain  ${out}  OK

    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /datacenter1/host/cls1
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  TEST_DATASTORE  datastore1

*** Test Cases ***
Test
    Log To Console  \nStarting test...
    Set Environment Variable  OVA_NAME  OVA-5-04-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install And Initialize VIC Product OVA  vic-*.ova  %{OVA_NAME}

    Set Browser Variables

    # Install VIC Plugin
    Download VIC And Install UI Plugin  %{OVA_IP}

    # Navigate to the wizard and create a VCH
    Open Firefox Browser
    Navigate To VC UI Home Page
    Login On Single Sign-On Page
    Verify VC Home Page
    Navigate To VCH Creation Wizard
    Navigate To VCH Tab
    Click New Virtual Container Host Button

    #general
    ${name}=  Evaluate  'VCH-5-04-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
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
