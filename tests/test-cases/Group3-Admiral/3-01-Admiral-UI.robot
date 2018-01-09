# Copyright 2017 VMware, Inc. All Rights Reserved.
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
Documentation  Test 3-01 Admiral UI
Resource  ../../resources/Util.robot
Test Timeout  20 minutes
Test Setup  Run Keyword  Setup Base State
Test Teardown  Close All Browsers

*** Variables ***
${busybox-docker-image-name}  registry.hub.docker.com/library/busybox
${busybox-docker-image-tag}  latest
${sample-command-exit}  ls
${cp-card-status-stopped}  STOPPED

*** Keywords ***
Setup Base State
    Log To Console  \nWaiting for Admiral to come up...
    :FOR  ${i}  IN RANGE  6
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" https://%{OVA_IP}:8282
    \   Exit For Loop If  '302' in '''${out}'''
    \   Sleep  10s
    Log To Console  ${rc}
    Log To Console  ${out}
    Should Contain  ${out}  302

    Open Firefox Browser
    Navigate To VIC UI Home Page
    Login On Single Sign-On Page

Cleanup VCH And Teardown
    [Arguments]  ${vch-name}
    Cleanup VCH  ${vch-name}
    Close All Browsers

*** Test Cases ***
Add VCH to default project and create a container
    Download VIC Engine If Not Already
    ${vch-name}=  Install VCH  certs=${false}
    Add New Container Host And Verify Card  ${vch-name}
    Navigate To Containers Page
    Select Containers Page Iframe
    Verify Containers Page
    Provision And Verify New Container  ${busybox-docker-image-name}  ${busybox-docker-image-tag}  ${sample-command-exit}  ${cp-card-status-stopped}
    Unselect Containers Page Iframe

    Delete VCH Card Using Dropdown Menu  ${vch-name}
    [Teardown]  Cleanup VCH And Teardown  ${vch-name}