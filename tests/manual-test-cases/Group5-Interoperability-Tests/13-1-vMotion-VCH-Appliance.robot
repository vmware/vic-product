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
Documentation  Test 13-1 - vMotion VCH Appliance
Resource  ../../resources/Util.robot
Suite Setup    vMotion Setup
#Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
#Test Teardown  Run Keyword If Test Failed  Gather All vSphere Logs

*** Keywords ***
vMotion Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    Create a VSAN Cluster

Gather All vSphere Logs
    ${hostList}=  Run  govc ls -t HostSystem host/cls | xargs
    Run  govc logs.download ${hostList}

*** Test Cases ***
Test
   #Set Test Variable  ${user}  %{NIMBUS_USER}
   #Set Suite Variable  @{list}  ${user}-vic-vmotion-13-1.vcva-${VC_VERSION}  ${user}-vic-vmotion-13-1.esx.0  ${user}-vic-vmotion-13-1.esx.1  ${user}-vic-vmotion-13-1.esx.2  ${user}-vic-vmotion-13-1.esx.3  ${user}-vic-vmotion-13-1.nfs.0  ${user}-vic-vmotion-13-1.iscsi.0
   Log To Console  Deploy VIC to the VC cluster
   Set Environment Variable  TEST_URL  ${vc-ip}
   Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
   Set Environment Variable  TEST_PASSWORD  Admin\!23
   Set Environment Variable  BRIDGE_NETWORK  bridge
   Set Environment Variable  PUBLIC_NETWORK  vm-network
   Remove Environment Variable  TEST_DATACENTER
   Set Environment Variable  TEST_DATASTORE  datastore1
   Set Environment Variable  TEST_RESOURCE  /vcqaDC/host/cls
   Set Environment Variable  TEST_TIMEOUT  30m


   Set Environment Variable  OVA_NAME  OVA-5-06-1-TEST
   Set Global Variable  ${OVA_USERNAME_ROOT}  root
   Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
   Install And Initialize VIC Product OVA  bin/vic-v1.4.0-rc4-4839-d99cbdb4.ova  %{OVA_NAME}

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

   Log To Console  vMotion VCH...
   ${host}=  Get VM Host Name  %{VCH-NAME}
   ${status}=  Run Keyword And Return Status  Should Contain  ${host}  ${esx1-ip}
   Run Keyword If  ${status}  Run  govc vm.migrate -host cls/${esx2-ip} %{VCH-NAME}
   Run Keyword Unless  ${status}  Run  govc vm.migrate -host cls/${esx1-ip} %{VCH-NAME}
