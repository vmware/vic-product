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
Suite Setup  Wait Until Keyword Succeeds  1x  30m  VIC UI OVA Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${ok}=  204

*** Test Cases ***
Attempt To Install To A Non vCenter Server
    # Install Fails  not-a-vcenter-server  admin  password  ${TRUE}
    # ${output}=  OperatingSystem.GetFile  install.log
    # ${passed}=  Run Keyword And Return Status  Should Contain  ${output}  vCenter Server was not found
    # Run Keyword Unless  ${passed}  Move File  install.log  install-fail-attempt-to-a-non-vcenter-server.log
    # Should Be True  ${passed}

    ${rc}  ${out}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  not-a-vcenter-server
    Should Not Contain  ${out}  ${ok}

Attempt To Install With Wrong Vcenter Credentials
    # Set Fileserver And Thumbprint In Configs
    # Append To File  ${UI_INSTALLER_PATH}/configs  BYPASS_PLUGIN_VERIFICATION=1\n
    # Install Fails  ${TEST_VC_IP}  ${TEST_VC_USERNAME}_nope  ${TEST_VC_PASSWORD}_nope  ${FALSE}  %{VC_FINGERPRINT}
    # ${output}=  OperatingSystem.GetFile  install.log
    # ${passed}=  Run Keyword And Return Status  Should Contain  ${output}  Cannot complete login due to an incorrect user name or password
    # Run Keyword Unless  ${passed}  Move File  install.log  install-fail-attempt-to-install-with-wrong-vcenter-credentials.log
    # Should Be True  ${passed}

    ${rc}  ${out}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Not Contain  ${out}  ${ok}
    

Attempt to Install With Unmatching Fingerprint
    # Append To File  ${UI_INSTALLER_PATH}/configs  BYPASS_PLUGIN_VERIFICATION=1\n
    # Install Fails  ${TEST_VC_IP}  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}  ${FALSE}  ff:ff:ff
    # ${output}=  OperatingSystem.GetFile  install.log
    # ${passed}=  Run Keyword And Return Status  Should Contain  ${output}  does not match
    # Run Keyword Unless  ${passed}  Move File  install.log  install-fail-attempt-to-install-with-unmatching-fingerprint.log
    # Should Be True  ${passed}

    ${rc}  ${out}=  Run Keyword And Ignore Error  Install UI Plugin  %{OVA_IP}  %{TEST_URL}  %{TEST_USERNAME}  %{TEST_PASSWORD}  ff:ff
    Should Not Contain  ${out}  ${ok}

Install Plugin Successfully
    ${out}=  Install UI Plugin  %{OVA_IP}
    Should Contain  ${out}  ${ok}