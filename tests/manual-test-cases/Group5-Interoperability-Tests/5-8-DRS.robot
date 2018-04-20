# Copyright 2016-2017 VMware, Inc. All Rights Reserved.
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
Documentation  Test 5-8 - DRS
Resource  ../../resources/Util.robot
Suite Setup  Wait Until Keyword Succeeds  10x  10m  DRS Setup
Suite Teardown  Nimbus Cleanup  ${list}

*** Keywords ***
DRS Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    Create a Simple VC Cluster

    Log To Console  Disable DRS on the cluster
    ${rc}  ${out}=  Run And Return Rc And Output  govc cluster.change -drs-enabled=false /ha-datacenter/host/cls
    Should Be Empty  ${out}
    Should Be Equal As Integers  ${rc}  0

*** Test Cases ***
Test
    Log To Console  \nStarting test...
    Set Environment Variable  OVA_NAME  OVA-5-04-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA  vic-*.ova  %{OVA_NAME}

    Set Browser Variables

    # Install VIC Plugin
    Download VIC And Install UI Plugin  %{OVA_IP}

    Log To Console  Create VCH with DRS disabled....
    # Navigate to the wizard and create a VCH
    Open Firefox Browser
    Navigate To VC UI Home Page
    Login On Single Sign-On Page
    Verify VC Home Page
    Navigate To VCH Creation Wizard
    Navigate To VCH Tab
    Click New Virtual Container Host Button

    # general
    ${name}=  Evaluate  'VCH-5-04-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
    Input VCH Name  ${name}
    Click Next Button
    # compute capacity
    Log To Console  Selecting compute resource...
    Wait Until Element Is Visible And Enabled  css=button.clr-treenode-caret.ng-tns-c11-22
    Click Button  css=button.clr-treenode-caret.ng-tns-c11-22
    Wait Until Element Is Visible And Enabled  css=button.clr-treenode-link.cc-resource
    Click Button  css=button.clr-treenode-link.cc-resource
    Click Next Button
    # storage capacity
    Select Image Datastore  %{TEST_DATASTORE}
    Click Next Button
    # networks
    Select Bridge Network  %{BRIDGE_NETWORK}
    Select Public Network  %{PUBLIC_NETWORK}
    Click Next Button
    # security
    Toggle Client Certificate Option
    Click Next Button
    # registry access
    Click Next Button
    # ops-user
    Input Ops User Name  %{TEST_USERNAME}
    Input Ops User Password  %{TEST_PASSWORD}
    Click Next Button
    # summary
    Click Finish Button
    Wait Until Page Contains Element  css=.alert-text
    Element Text Should Be  css=.alert-text  Failed to validate VCH: DRS must be enabled to use VIC
    Capture Page Screenshot

    Log To Console  Clicking Cancel button...
    Wait Until Element Is Visible And Enabled  css=.clr-wizard-btn--tertiary
    Click Button  css=.clr-wizard-btn--tertiary
    Unselect Frame

    Log To Console  Enable DRS on the cluster
    ${rc}  ${out}=  Run And Return Rc And Output  govc cluster.change -drs-enabled /ha-datacenter/host/cls
    Should Be Empty  ${out}
    Should Be Equal As Integers  ${rc}  0

    Log To Console  Create VCH with DRS enabled
    Wait Until Page Contains  Summary
    Wait Until Page Contains  Virtual Container Hosts
    Wait Until Page Contains  Containers

    Click New Virtual Container Host Button
    # general
    ${name}=  Evaluate  'VCH-5-05-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
    Input VCH Name  ${name}
    Click Next Button
    # compute capacity
    Log To Console  Selecting compute resource...
    Wait Until Element Is Visible And Enabled  css=button.clr-treenode-caret.ng-tns-c11-22
    Click Button  css=button.clr-treenode-caret.ng-tns-c11-22
    Wait Until Element Is Visible And Enabled  css=button.clr-treenode-link.cc-resource
    Click Button  css=button.clr-treenode-link.cc-resource
    Click Next Button
    # storage capacity
    Select Image Datastore  %{TEST_DATASTORE}
    Click Next Button
    # networks
    Select Bridge Network  %{BRIDGE_NETWORK}
    Select Public Network  %{PUBLIC_NETWORK}
    Click Next Button
    # security
    Toggle Client Certificate Option
    Click Next Button
    # registry access
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
