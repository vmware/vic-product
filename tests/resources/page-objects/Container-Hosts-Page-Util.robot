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
Documentation  This resource contains any keywords dealing with Container Hosts page
Resource  Remove-Host-Modal-Util.robot
Resource  New-Container-Host-Modal-Util.robot
Resource  Side-Nav-Util.robot

*** Variables ***
# css locators
${ch-title}  css=.content-area .title
${ch-button-new-host}  css=.toolbar button
${ch-card-name}  css=.card-item .titleHolder div:nth-of-type(1)
${ch-card-status}  css=.card-item .status
${ch-button-card-dropdown}  css=.card button.dropdown-toggle
${ch-link-delete}  css=button.dropdown-item.remove-cluster

# expected text values
${ch-title-text}  Container Hosts
${ch-card-status-on}  ON

*** Keywords ***
Verify Container Hosts Page
    Wait Until Element Is Visible  ${ch-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${ch-title}  ${ch-title-text}

Click New Host Button
    Click Button   ${ch-button-new-host}
    Verify New Container Host Modal

Get VCH Card Index
    [Arguments]  ${card-name}
    ${card-index}=  Set Variable  None
    ${visible}=  Run Keyword And Return Status  Element Should Be Visible  ${ch-card-name}
    @{card-elements}=  Run Keyword If  ${visible} == True  Get Webelements  ${ch-card-name}
    :FOR  ${element}  IN  @{card-elements}
    \   ${name-text}=  Get Text  ${element}
    \   ${status}=  Run Keyword And Return Status  Should Be Equal As Strings  ${name-text}  ${card-name}
    \   ${card-index}=  Run Keyword If  ${status} == True  Get Index From List  ${card-elements}  ${element}
    \   Exit For Loop If  ${status} == True
    [Return]  ${card-index}

Verify VCH Card Status
    [Arguments]  ${card-index}  ${card-status}
    @{statuses}=  Get Webelements  ${ch-card-status}
    ${status}=  Get From List  ${statuses}  ${card-index}
    ${status-text}=  Get Text  ${status}
    Should Be Equal As Strings  ${status-text}  ${card-status}

Verify VCH Card
    [Arguments]  ${card-name}
    ${card-index}=  Get VCH Card Index  ${card-name}
    Should Not Be Equal As Strings  ${card-index}  None
    Verify VCH Card Status  ${card-index}  ${ch-card-status-on}

Add New Container Host And Verify Card
    [Arguments]  ${vch-name}
    Navigate To Container Hosts Page
    Click New Host Button
    Add New Container Host  ${vch-name}  ${VCH-URL}
    Verify VCH Card  ${vch-name}

Delete VCH Card Using Dropdown Menu
    [Arguments]  ${card-name}
    Navigate To Container Hosts Page
    ${card-index}=  Get VCH Card Index  ${card-name}
    @{dropdown-buttons}=  Get Webelements  ${ch-button-card-dropdown}
    ${dropdown}=  Get From List  ${dropdown-buttons}  ${card-index}
    Focus  ${dropdown}
    Click Button  ${dropdown}
    Focus  ${ch-link-delete}
    Click Link  ${ch-link-delete}
    Verify Modal for Remove Container Host
    Click Remove On Remove Container Host
    Verify Container Hosts Page
    ${no-card-index}=  Get VCH Card Index  ${card-name}
    Should Be Equal As Strings  ${no-card-index}  None