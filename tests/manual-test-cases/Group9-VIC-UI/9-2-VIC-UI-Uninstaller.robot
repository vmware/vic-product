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
Documentation  Test 9-2 - VIC UI Uninstallation
Resource  ../../resources/Util.robot
Suite Setup  Uninstall OVA Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${ok}=  204

*** Keywords *** 
Uninstall OVA Setup
    Wait Until Keyword Succeeds  1x  30m  VIC UI OVA Setup
    ${out}=  Install UI Plugin  %{OVA_IP}
    Should Contain  ${out}  ${ok}

*** Test Cases ***
Attempt To Uninstall From A Non vCenter Server
    ${rc}  ${out}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  not-a-vcenter-server
    Should Not Contain  ${out}  ${ok}

Attempt To Uninstall With Wrong Vcenter Credentials
    ${rc}  ${out}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Not Contain  ${out}  ${ok}

Uninstall Successfully
    ${out}=  Remove UI Plugin  %{OVA_IP}
    Should Contain  ${out}  ${ok}

Attempt To Uninstall Plugin That Is Already Gone
    ${rc}  ${out}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}
    Should Not Contain  ${out}  ${ok}
