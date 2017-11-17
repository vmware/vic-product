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
Documentation  This resource contains any keywords dealing with vCenter Single Sign-On UI page
Resource  Header-Util.robot

*** Variables ***
# css locators
${vcsso-image-title}  id=VCSSO-Title
${vcsso-username}  id=username
${vcsso-password}  id=password
${vcsso-button-login}  id=submit

# expected text values

*** Keywords ***
Login On Single Sign-On Page
    Wait Until Element Is Visible  ${vcsso-image-title}  timeout=${EXPLICIT_WAIT}
    Input Text  ${vcsso-username}  %{TEST_USERNAME}
    Input Text  ${vcsso-password}  %{TEST_PASSWORD}
    Click Button  ${vcsso-button-login}
    Verify VIC UI Header Display