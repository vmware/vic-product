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
Suite Setup  Ununstall OVA Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${ok}=  204

*** Keywords *** 
Ununstall OVA Setup
    Wait Until Keyword Succeeds  1x  30m  VIC UI OVA Setup
    ${out}=  Install UI Plugin  %{OVA_IP}
    Should Contain  ${out}  ${ok}

*** Test Cases ***
Attempt To Uninstall From A Non vCenter Server
    # Uninstall Fails  not-a-vcenter-server  admin  password
    # ${output}=  OperatingSystem.GetFile  uninstall.log
    # ${passed}=  Run Keyword And Return Status  Should Contain  ${output}  vCenter Server was not found
    # Run Keyword Unless  ${passed}  Move File  uninstall.log  uninstall-fail-attempt-to-uninstall-from-a-non-vcenter-server.log
    # Should Be True  ${passed}

    ${rc}  ${out}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  not-a-vcenter-server
    Should Not Contain  ${out}  ${ok}

Attempt To Uninstall With Wrong Vcenter Credentials
    # Set Fileserver And Thumbprint In Configs
    # Uninstall Fails  ${TEST_VC_IP}  ${TEST_VC_USERNAME}_nope  ${TEST_VC_PASSWORD}_nope
    # ${output}=  OperatingSystem.GetFile  uninstall.log
    # ${passed}=  Run Keyword And Return Status  Should Contain  ${output}  Cannot complete login due to an incorrect user name or password
    # Run Keyword Unless  ${passed}  Move File  uninstall.log  uninstall-fail-attempt-to-uninstall-with-wrong-vcenter-credentials.log
    # Should Be True  ${passed}

    ${rc}  ${out}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}  %{TEST_URL}  %{TEST_USERNAME}_nope  %{TEST_PASSWORD}_nope
    Should Not Contain  ${out}  ${ok}

Uninstall Successfully
    # Set Fileserver And Thumbprint In Configs
    # Uninstall Vicui  ${TEST_VC_IP}  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}
    # ${output}=  OperatingSystem.GetFile  uninstall.log
    # ${passed}=  Run Keyword And Return Status  Should Match Regexp  ${output}  exited successfully
    # Run Keyword Unless  ${passed}  Move File  uninstall.log  uninstall-fail-uninstall-successfully.log
    # Should Be True  ${passed}

    ${out}=  Remove UI Plugin  %{OVA_IP}
    Should Contain  ${out}  ${ok}


Attempt To Uninstall Plugin That Is Already Gone
    # Set Fileserver And Thumbprint In Configs
    # Uninstall Vicui  ${TEST_VC_IP}  ${TEST_VC_USERNAME}  ${TEST_VC_PASSWORD}
    # ${output}=  OperatingSystem.GetFile  uninstall.log
    # ${passed}=  Run Keyword And Return Status  Should Contain  ${output}  'com.vmware.vic.ui' is not registered
    # ${passed2}=  Run Keyword And Return Status  Should Contain  ${output}  'com.vmware.vic' is not registered
    # Run Keyword Unless  (${passed} and ${passed2})  Move File  uninstall.log  uninstall-fail-attempt-to-uninstall-plugin-that-is-already-gone.log
    # Should Be True  ${passed}

    ${rc}  ${out}=  Run Keyword And Ignore Error  Remove UI Plugin  %{OVA_IP}
    Should Not Contain  ${out}  ${ok}
