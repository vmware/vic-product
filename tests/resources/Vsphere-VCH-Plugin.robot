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
Documentation  This resource contains any keywords dealing with web based operations being performed within vSphere on the VCH plugin

*** Keywords ***
Navigate To Summary Tab
    Wait Until Element Is Visible And Enabled  css=ul.nav.nav-tabs > li:nth-child(1)
    Click Element  css=ul.nav.nav-tabs > li:nth-child(1)

    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=summary-view']
    Select Frame  css=iframe[ng-src*='view=summary-view']
    Wait Until Page Contains Element  css=vic-app
    Wait Until Page Contains Element  css=vic-summary-view
    Unselect Frame

Navigate To VCH Tab
    Wait Until Element Is Visible And Enabled  css=ul.nav.nav-tabs > li:nth-child(2)
    Click Element  css=ul.nav.nav-tabs > li:nth-child(2)

    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=vch-view']
    Select Frame  css=iframe[ng-src*='view=vch-view']
    Wait Until Page Contains Element  css=vic-app
    Wait Until Page Contains Element  css=vic-vch-view
    Unselect Frame

Navigate To Containers Tab
    Wait Until Element Is Visible And Enabled  css=ul.nav.nav-tabs > li:nth-child(3)
    Click Element  css=ul.nav.nav-tabs > li:nth-child(3)

    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=container-view']
    Select Frame  css=iframe[ng-src*='view=container-view']
    Wait Until Page Contains Element  css=vic-app
    Wait Until Page Contains Element  css=vic-container-view
    Unselect Frame

Click New Virtual Container Host Button
    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=vch-view']
    Select Frame  css=iframe[ng-src*='view=vch-view']
    Wait Until Element Is Visible And Enabled  css=clr-icon[shape='add']
    Click Element  css=clr-icon[shape='add']
    Unselect Frame
    
    Wait Until Element Is Visible And Enabled  css=iframe[ng-src*='view=create-vch']
    Select Frame  css=iframe[ng-src*='view=create-vch']

    Wait Until Page Contains  Virtual Container Host Name