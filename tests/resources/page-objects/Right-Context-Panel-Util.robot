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
Documentation  This resource contains any keywords dealing with right context panel

*** Variables ***
# css locators
${rcp-title}  css=.right-context-panel .title > span
${rcp-container-name}  css=.right-context-panel .name
${rcp-progress-stage}  css=.progress .stage

# expected text values
${rcp-title-text}  Requests
${rcp-stage-finished-text}  FINISHED
${rcp-stage-failed-text}  FAILED

*** Keywords ***
Verify Requests Right Context Panel
    Wait Until Element Is Visible  ${rcp-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${rcp-title}  ${rcp-title-text}

Get Progress Stage Item Index
    [Arguments]  ${container-name}
    Sleep  5s
    ${item-index}=  Set Variable  None
    ${visible}=  Run Keyword And Return Status  Element Should Be Visible  ${rcp-container-name}
    @{name-elements}=  Run Keyword If  ${visible} == True  Get Webelements  ${rcp-container-name}
    :FOR  ${element}  IN  @{name-elements}
    \   ${name-text}=  Get Text  ${element}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${name-text}  ${container-name}
    \   ${item-index}=  Run Keyword If  ${status} == True  Get Index From List  ${name-elements}  ${element}
    \   Exit For Loop If  ${status} == True
    [Return]  ${item-index}

Verify Container Provision Status In Right Panel
    [Arguments]  ${container-name}  ${status}
    ${item-index}=  Get Progress Stage Item Index  ${container-name}
    Should Not Be Equal As Strings  ${item-index}  None
    @{status-elements}=  Get Webelements  ${rcp-progress-stage}
    ${status-element}=  Get From List  ${status-elements}  ${item-index}
    ${result}=  Run Keyword And Return Status  Wait Until Element Contains  ${status-element}  ${status}  timeout=300
    Should Be Equal  ${result}  ${TRUE}  msg=Container Provision Progress Status is not '${status}'

Verify Container Provision Status Is Finished
    [Arguments]  ${container-name}
    Wait Until Keyword Succeeds  10x  3s  Verify Container Provision Status In Right Panel  ${container-name}  ${rcp-stage-finished-text}

Verify Container Provision Status Is Failed
    [Arguments]  ${container-name}
    Wait Until Keyword Succeeds  10x  3s  Verify Container Provision Status In Right Panel  ${container-name}  ${rcp-stage-failed-text}