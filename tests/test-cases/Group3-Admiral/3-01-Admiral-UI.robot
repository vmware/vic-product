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
${busybox-docker-image-tag}  registry.hub.docker.com/library/busybox
${sample-command-exit}  ls
${cp-card-status-stopped}  STOPPED

*** Keywords ***
Setup Base State
    Open Firefox Browser
    Navigate To VIC UI Home Page
    Login On Single Sign-On Page

*** Test Cases ***
Add VCH to default project and create a container
    Download VIC Engine If Not Already
    ${vch-name}=  Install VCH  certs=${false}
    Add New Container Host And Verify Card  ${vch-name}  ${VCH-URL}
    Navigate To Containers Page
    Select Containers Page Iframe
    Verify Containers Page
    Provision And Verify New Container  ${busybox-docker-image-tag}  ${sample-command-exit}  ${cp-card-status-stopped}
    Unselect Containers Page Iframe

    Delete VCH Card Using Dropdown Menu  ${vch-name}
    [Teardown]  Cleanup VCH  ${vch-name}