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
Documentation  This resource contains any keywords dealing with Provision a Container page
Resource  Containers-Page-Util.robot

*** Variables ***
# css locators
${pc-title}  css=.create-container .title
${pc-input-image-tag}  css=.image-name-input .tt-input
${pc-input-container-name}  css=.container-name-input input
${pc-input-command}  css=div[name=command] input
${pc-button-provision}  css=.btn-primary

# expected text values
${pc-title-text}  Provision a Container

*** Keywords ***
Verify Provision a Container Page
    Wait Until Element Is Visible  ${pc-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${pc-title}  ${pc-title-text}

Submit Provision New Container Details
    [Arguments]  ${image-tag}  ${container-name}  ${command}
    Input Text  ${pc-input-image-tag}  ${image-tag}
    Input Text  ${pc-input-container-name}  ${container-name}
    Input Text  ${pc-input-command}  ${command}
    Click Button  ${pc-button-provision}
    Verify Containers Page
    Capture Page Screenshot
