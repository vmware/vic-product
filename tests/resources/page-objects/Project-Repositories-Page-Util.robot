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
Documentation  This resource contains any keywords dealing with Project Repositories page

*** Variables ***
# css locators
${pr-title}  css=.content-area .title
${pr-repositories-table-row}  css=div.datagrid-body .datagrid-row
${pr-repositories-card-item}  css=div.grid-content .card-item
${pr-repositories-card-title}  css=.card-media-title

*** Keywords ***
Verify Project Repositories Page
    Wait Until Element Is Visible  ${pr-title}  timeout=${EXPLICIT_WAIT}

Verify Row Value In Project Repositories Table
    [Arguments]  ${expected}
    ${visible}=  Run Keyword And Return Status  Element Should Be Visible  ${pr-repositories-table-row}
    @{row-elements}=  Run Keyword If  ${visible} == True  Get Webelements  ${pr-repositories-table-row}
    :FOR  ${element}  IN  @{row-elements}
    \   ${row-text}=  Get Text  ${element}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${row-text}  ${expected}
    \   Exit For Loop If  ${status} == True
    [Return]  ${row-text}

Verify Row Value In Project Repositories Grid
    [Arguments]  ${expected}
    ${visible}=  Run Keyword And Return Status  Element Should Be Visible  ${pr-repositories-card-item}
    @{card-title-elements}=  Run Keyword If  ${visible} == True  Get Webelements  ${pr-repositories-card-title}
    :FOR  ${element}  IN  @{card-title-elements}
    \   ${card-title}=  Get Text  ${element}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${title}  ${expected}
    \   Exit For Loop If  ${status} == True
    [Return]  ${card-title}