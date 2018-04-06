# Copyright 2018 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  This resource contains any keywords dealing with web based operations being performed on a Vsphere instance

*** Keywords ***
Login To Vsphere UI
    [Arguments]  ${url}=%{TEST_URL}  ${username}=%{TEST_USERNAME}  ${password}=%{TEST_PASSWORD}
    Go To  ${url}
    Wait Until Element Is Visible And Enabled  username
    Wait Until Element Is Visible And Enabled  password

    Input Text  username  ${username}
    Input Text  password  ${password}

    Wait Until Element Is Visible And Enabled  submit

    Click Button  submit

    Wait Until Page Contains  Summary
    Wait Until Page Contains  Monitor
    Wait Until Page Contains  Configure
    Wait Until Page Contains  Permissions

Navigate To VCH Creation Wizard
    Wait Until Element Is Visible And Enabled  action-homeMenu
    Click Element  action-homeMenu

    Wait Until Element Is Visible And Enabled  xpath=//*[@id="homeMenu-vsphere.core.navigator.shortcuts"]
    Click Element  xpath=//*[@id="homeMenu-vsphere.core.navigator.shortcuts"]

    Wait Until Element Is Visible And Enabled  css=span.com_vmware_vic-home-shortcut-icon
    Click Element  css=span.com_vmware_vic-home-shortcut-icon
    
    Wait Until Element Is Visible And Enabled  css=span[title='vSphere Integrated Containers']
    Click Element  css=span[title='vSphere Integrated Containers']

    Wait Until Page Contains  Summary
    Wait Until Page Contains  Virtual Container Hosts
    Wait Until Page Contains  Containers