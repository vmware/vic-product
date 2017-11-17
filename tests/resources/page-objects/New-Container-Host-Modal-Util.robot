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
Documentation  This resource contains any keywords dealing with New Container Host modal

*** Variables ***
# css locators
${nch-title}  css=.modal-title
${nch-name}  id=name
${nch-url}  id=url
${nch-select-creds}  css=.dropdown-select button
${nch-dropdown-creds}  css=.dropdown-options li a
${nch-default-cert-option}  css=a[data-name=default-ca-cert]
${nch-button-save}  css=.modal-footer .btn-primary

# expected text values
${nch-title-text}  New Container Host

*** Keywords ***
Verify New Container Host Modal
    Wait Until Element Is Visible  ${nch-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${nch-title}  ${nch-title-text}

Add New Container Host
    [Arguments]  ${name}  ${url}  ${creds}=${nch-default-cert-option}
    Input Text  ${nch-name}  ${name}
    Input Text  ${nch-url}  ${url}
    Click Button  ${nch-select-creds}
    Click Link  ${creds}
    Click Button  ${nch-button-save}
    Verify Modal for Verify Certificate
    Click Yes On Verify Certificate
    Wait Until Page Does Not Contain Element  ${nch-title}  timeout=${EXPLICIT_WAIT}