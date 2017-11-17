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
Documentation  This resource contains any keywords dealing with Remove Container Host modal page

*** Variables ***
# css locators
${rch-title}  css=.modal-title
${rch-button-remove}  css=.modal .btn-danger

# expected text values
${rch-title-text}  Remove Container Host

*** Keywords ***
Verify Modal for Remove Container Host
    Wait Until Element Is Visible  ${rch-title}  timeout=${EXPLICIT_WAIT}
    Element Text Should Be  ${rch-title}  ${rch-title-text}

Click Remove On Remove Container Host
    Click Button  ${rch-button-remove}
    Wait Until Page Does Not Contain Element  ${rch-button-remove}  timeout=${EXTRA_EXPLICIT_WAIT}