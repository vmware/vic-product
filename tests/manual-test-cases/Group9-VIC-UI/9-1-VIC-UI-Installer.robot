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
Documentation  Test 9-1 - VIC UI Installation
Resource  ../../resources/Util.robot
Suite Setup  Run Keyword  VIC UI OVA Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${ok}=  204
${html5}=  H5
${flex}=  FLEX

*** Test Cases ***
Attempt To Install To A Non vCenter Server
    ${status}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  ${html5}  not-a-vcenter-server
    Should Not Be Equal As Integers  ${status}  ${ok}
    ${status}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  ${flex}  not-a-vcenter-server
    Should Not Be Equal As Integers  ${status}  ${ok}

Attempt To Install With Wrong Vcenter Credentials
    ${status}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  ${html5}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Not Be Equal As Integers  ${status}  ${ok}
    ${status}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  ${flex}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Not Be Equal As Integers  ${status}  ${ok}
    
Attempt to Install With Unmatching Fingerprint
    ${status}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  ${html5}  %{TEST_URL}  %{TEST_USERNAME}  %{TEST_PASSWORD}  ff:ff
    Should Not Be Equal As Integers  ${status}  ${ok}
    ${status}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  ${flex}  %{TEST_URL}  %{TEST_USERNAME}  %{TEST_PASSWORD}  ff:ff
    Should Not Be Equal As Integers  ${status}  ${ok}

Install Plugin Successfully
    ${status}=  Install UI Plugin  %{OVA_IP}  ${html5}
    Should Be Equal As Integers  ${status}  ${ok}
    ${status}=  Install UI Plugin  %{OVA_IP}  ${flex}
    Should Be Equal As Integers  ${status}  ${ok}

Upgrade Plugin Successfully
    ${status}=  Upgrade UI Plugin  %{OVA_IP}  ${html5}
    Should Be Equal As Integers  ${status}  ${ok}
    ${status}=  Upgrade UI Plugin  %{OVA_IP}  ${flex}
    Should Be Equal As Integers  ${status}  ${ok}
