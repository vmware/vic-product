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
Documentation  Test 5-6-1 - VSAN-Simple
Resource  ../../resources/Util.robot
Suite Setup   Wait Until Keyword Succeeds  10x  10m  Simple VSAN Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Keywords ***
Simple VSAN Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    ${name}=  Evaluate  'vic-vsan-' + str(random.randint(1000,9999))  modules=random
    Set Suite Variable  ${user}  %{NIMBUS_USER}
    ${out}=  Deploy Nimbus Testbed  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  --plugin testng --vcfvtBuildPath /dbc/pa-dbc1111/mhagen/ --noSupportBundles --vcvaBuild ${VC_VERSION} --esxPxeDir ${ESX_VERSION} --esxBuild ${ESX_VERSION} --testbedName vic-vsan-simple-pxeBoot-vcva --runName ${name}
    Should Contain  ${out}  "deployment_result"=>"PASS"
    Log  ${out}

    Log To Console   Get VC IP ...
    Open Connection  %{NIMBUS_GW}
    Wait Until Keyword Succeeds  10 min  30 sec  Login  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    ${vc-ip}=  Get IP  ${name}.vcva-${VC_VERSION}
    Close Connection

    Set Suite Variable  @{list}  ${user}-${name}.vcva-${VC_VERSION}  ${user}-${name}.esx.0  ${user}-${name}.esx.1  ${user}-${name}.esx.2  ${user}-${name}.esx.3  ${user}-${name}.nfs.0  ${user}-${name}.iscsi.0
    Log To Console   Finished Creating Simple VSAN

    Log To Console  Set environment variables up for GOVC
    Set Environment Variable  GOVC_INSECURE  1
    Set Environment Variable  GOVC_URL  ${vc-ip}
    Set Environment Variable  GOVC_USERNAME  Administrator@vsphere.local
    Set Environment Variable  GOVC_PASSWORD  Admin\!23

    Add Host To Distributed Switch  /vcqaDC/host/cls

    Log To Console  Enable DRS and VSAN on the cluster
    ${out}=  Run  govc cluster.change -drs-enabled /vcqaDC/host/cls
    Should Be Empty  ${out}

    Log To Console  Deploy VIC to the VC cluster
    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Remove Environment Variable  TEST_DATACENTER
    Set Environment Variable  TEST_DATASTORE  vsanDatastore
    Set Environment Variable  TEST_RESOURCE  /vcqaDC/host/cls
    Set Environment Variable  TEST_TIMEOUT  15m

Check VSAN DOMs In Datastore
    [Arguments]  ${test_datastore}
    ${out}=  Run  govc datastore.vsan.dom.ls -ds ${test_datastore} -l -o
    Should Be Empty  ${out}

*** Test Cases ***
Simple VSAN
    Log To Console  \nStarting test...
    Wait Until Keyword Succeeds  10x  30s  Check VSAN DOMs In Datastore  %{TEST_DATASTORE}

    Custom Testbed Keepalive  /dbc/pa-dbc1111/mhagen

    Set Environment Variable  OVA_NAME  OVA-5-06-1-TEST
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

    # general
    ${name}=  Evaluate  'VCH-5-6-1-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
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
