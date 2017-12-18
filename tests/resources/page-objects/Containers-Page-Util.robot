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
Documentation  This resource contains any keywords dealing with Containers page
Resource  Provision-Container-Page-Util.robot
Resource  Side-Nav-Util.robot

*** Variables ***
# css locators
${cp-iframe}  css=.main-container iframe
${cp-title}  css=#main .title span:nth-of-type(1)
${cp-link-refresh}  css=.refresh-button a
${cp-link-new-container}  css=.toolbar .create-resource-btn
${cp-card-name}  css=.container-item .title-holder .title
${cp-card-image-tag}  css=.container-item .title-holder .image-tag
${cp-card-status}  css=.container-item .status
${cp-card-command-value}  css=.container-command-holder span:nth-of-type(2)
${cp-link-remove}  css=.container-actions .container-action-remove

# expected text values
${cp-title-text}  Containers

*** Keywords ***
Select Containers Page Iframe
    Select Frame  ${cp-iframe}

Unselect Containers Page Iframe
    Unselect Frame

Verify Containers Page
    Wait Until Element Is Visible  ${cp-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${cp-title}  ${cp-title-text}

Click New Container Button
    Click Link  ${cp-link-new-container}
    Verify Provision a Container Page

Get Container Card Index
    [Arguments]  ${card-name}
    ${card-index}=  Set Variable  None
    ${visible}=  Run Keyword And Return Status  Element Should Be Visible  ${cp-card-name}
    @{card-elements}=  Run Keyword If  ${visible} == True  Get Webelements  ${cp-card-name}
    :FOR  ${element}  IN  @{card-elements}
    \   ${name-text}=  Get Text  ${element}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${name-text}  ${card-name}
    \   ${card-index}=  Run Keyword If  ${status} == True  Get Index From List  ${card-elements}  ${element}
    \   Exit For Loop If  ${status} == True
    [Return]  ${card-index}

Verify Container Card Status
    [Arguments]  ${card-index}  ${card-status}
    @{statuses}=  Get Webelements  ${cp-card-status}
    ${status}=  Get From List  ${statuses}  ${card-index}
    ${status-text}=  Get Text  ${status}
    Should Contain  ${status-text}  ${card-status}

Verify Container Card
    [Arguments]  ${card-name}  ${card-status}
    ${card-index}=  Get Container Card Index  ${card-name}
    Should Not Be Equal As Strings  ${card-index}  None
    Wait Until Keyword Succeeds  3x  3s  Verify Container Card Status  ${card-index}  ${card-status}

Provision And Verify New Container
    [Arguments]  ${image-name}  ${image-tag}  ${command}  ${container-status}
    ${container-name}=  Get Random Container Name
    Click New Container Button
    Submit Provision New Container Details  ${image-name}  ${image-tag}  ${container-name}  ${command}
    Verify Requests Right Context Panel
    Verify Container Provision Status Is Finished  ${container-name}
    Reload Page
    Select Containers Page Iframe
    Verify Containers Page
    Verify Container Card  ${container-name}  ${container-status}
    [Return]  ${container-name}

Get Random Container Name
    ${random-container-name}=  Evaluate  'container-' + str(random.randint(1000,9999))  modules=random
    [Return]  ${random-container-name}