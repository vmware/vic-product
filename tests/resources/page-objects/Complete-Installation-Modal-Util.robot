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
Documentation  This resource contains any keywords dealing with Complete Installation Log In modal page
Resource  Getting-Started-Page-Util.robot

*** Variables ***
# css locators
${cim-title}  css=#login-modal .modal-title
${cim-thumbprint-title}  css=#plugin-modal .modal-title
${cim-input-target}  id=target
${cim-input-user}  id=user
${cim-input-password}  css=input[type=password]
${cim-button-continue}  id=login-submit
${cim-thumbprint-button-continue}  id=plugin-submit

# expected text values
${cim-title-text}  Complete VIC appliance installation

*** Keywords ***
Navigate To Complete Installation Login Modal
    Go To  ${COMPLETE_INSTALL_URL}

Verify Complete Installation Modal
    Element Text Should Be  ${cim-title}  ${cim-title-text}  message=Complete Installation Log In modal is not displayed

Verify Thumbprint Modal
    Element Text Should Be  ${cim-thumbprint-title}  ${cim-title-text}  message=Verify Thumbprint modal is not displayed

Log In And Complete OVA Installation
    [Tags]  secret
    Navigate To Complete Installation Login Modal
    Verify Complete Installation Modal
    Input Text  ${cim-input-target}   %{TEST_URL}
    Input Text  ${cim-input-user}   %{TEST_USERNAME}
    Input Text  ${cim-input-password}   %{TEST_PASSWORD}
    Click Button  ${cim-button-continue}
    Verify Thumbprint Modal
    Click Button  ${cim-thumbprint-button-continue}
    Verify Complete Installation Message
