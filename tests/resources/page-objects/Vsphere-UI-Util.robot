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
Resource  ../../resources/UI-Util.robot

*** Variables ***
# css locators
${vcsso-image-title}  id=VCSSO
${vic-link}  css=#center-pane span[title='vSphere Integrated Containers']

*** Keywords ***
Navigate To VCH Creation Wizard
    Log To Console  Navigating to VCH creation wizard page...
    Go To  ${VC_SHORTCUTS_PAGE_URL}

    Wait Until Element Is Visible And Enabled  css=span.com_vmware_vic-home-shortcut-icon
    Click Element  css=span.com_vmware_vic-home-shortcut-icon
    
    Wait Until Element Is Visible And Enabled  ${vic-link}
    Click Element  ${vic-link}

    Wait Until Page Contains  Summary
    Wait Until Page Contains  Virtual Container Hosts
    Wait Until Page Contains  Containers
