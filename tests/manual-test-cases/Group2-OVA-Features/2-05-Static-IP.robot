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
Suite Setup  Setup VC With Static IP
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Copy Support Bundle  %{OVA_IP}

*** Variables ***
${dns-nimbus}=  10.170.16.48
${searchpath-nimbus}=  eng.vmware.com

*** Keywords ***
Setup VC With Static IP
    ${name}=  Evaluate  'vic-2-05-' + str(random.randint(1000,9999))  modules=random
    Nimbus Suite Setup  Create Simple VC Cluster With Static IP  ${name}

*** Test Cases ***
Deploy OVA With Static IP
    Log To Console  \nStarting test...
    
    Set Environment Variable  OVA_NAME  OVA-2-05-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # install ova using static ip
    Install And Initialize VIC Product OVA  vic-*.ova  %{OVA_NAME}  static-ip=&{static}[ip]  netmask=&{static}[netmask]  gateway=&{static}[gateway]  dns=${dns-nimbus}  searchpath=${searchpath-nimbus}
    # verify network details
    Verify OVA Network Information  %{OVA_IP}  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}  &{static}[ip]  &{static}[prefix]  &{static}[gateway]  ${dns-nimbus}  ${searchpath-nimbus}
