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
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Copy Support Bundle  %{OVA_IP}

*** Keywords *** 
Uninstall OVA Setup
    Run Keyword  VIC UI OVA Setup
    ${status}=  Install UI Plugin  %{OVA_IP}  ${html5}
    Should Be Equal As Integers  ${status}  ${ok}

*** Test Cases ***
Attempt To Uninstall From A Non vCenter Server
    ${status}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  ${html5}  not-a-vcenter-server
    Should Contain  ${status}  ${fail}
    ${status}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  ${flex}  not-a-vcenter-server
    Should Contain  ${status}  ${fail}

Attempt To Uninstall With Wrong Vcenter Credentials
    ${status}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  ${html5}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Contain  ${status}  ${fail}
    ${status}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  ${flex}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Contain  ${status}  ${fail}

Uninstall Successfully
    ${status}=  Remove UI Plugin  %{OVA_IP}  ${html5}
    Should Be Equal As Integers  ${status}  ${ok}
    #${status}=  Remove UI Plugin  %{OVA_IP}  ${flex}
    #Should Be Equal As Integers  ${status}  ${ok}

Attempt To Uninstall Plugin That Is Already Gone
    ${status}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  ${html5}
    Should Contain  ${status}  ${fail}
    ${status}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  ${flex}
    Should Contain  ${status}  ${fail}
