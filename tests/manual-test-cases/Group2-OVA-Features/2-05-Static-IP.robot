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
Documentation  Test 2-05 - Static IP
Resource  ../../resources/Util.robot
Suite Setup  Wait Until Keyword Succeeds  10x  10m  Simple VC Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${esx_number}=  2
${cluster}=  cls
${ha-datacenter}=  ha-datacenter
${dns-nimbus}=  10.170.16.48
${serachpath-nimbus}=  eng.vmware.com
${subnet-nimbus}=  255.255.224.0

*** Keywords ***
Simple VC Setup
    [Timeout]    110 minutes

    ${esx1}  ${esx2}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${vc-ip}=  Create a Simple VC Cluster  ${ha-datacenter}  ${cluster}  ${esx_number}
    Log To Console  Finished Creating Cluster ${vc}
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  %{NIMBUS_USER}-${vc}

    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /${ha-datacenter}/host/${cluster}
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  TEST_DATASTORE  datastore1

*** Test Cases ***
Deploy OVA With Static IP
    Log To Console  \nStarting test...
    Set Environment Variable  OVA_NAME  OVA-2-05-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # create static ip
    Set Nimbus POD Variable  %{NIMBUS_USER}-${vc}
    ${static}=  Get Static IP Address
    Append To List  ${list}  %{STATIC_WORKER_NAME}
    # install ova using static ip
    Install And Initialize VIC Product OVA  vic-*.ova  %{OVA_NAME}  static-ip=&{static}[ip]  netmask=${subnet-nimbus}  gateway=&{static}[gateway]  dns=${dns-nimbus}  searchpath=${serachpath-nimbus}
    # verify network details
    Verify OVA Network Information  %{OVA_IP}  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}  &{static}[ip]  &{static}[netmask]  &{static}[gateway]  ${dns-nimbus}  ${serachpath-nimbus}
