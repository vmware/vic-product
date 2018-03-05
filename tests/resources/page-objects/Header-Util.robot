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
Documentation  This resource contains any keywords dealing with header on VIC UI page

*** Variables ***
# css locators
${vh-title}  css=.header .title
${vh-admin-link}  css=a[routerlink='/administration']


# expected text values
${vh-title-text}  vSphere Integrated Containers


*** Keywords ***
Verify VIC UI Header Display
    Wait Until Element Is Visible  ${vh-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${vh-title}  ${vh-title-text}

Navigate To Admin Page
    Click Link  ${vh-admin-link}
    Wait Until Element Is Visible  ${sn-registries-link}  timeout=${EXPLICIT_WAIT}