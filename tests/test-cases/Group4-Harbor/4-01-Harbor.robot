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
Documentation  Test 4-01 Harbor
Resource  ../../resources/Util.robot
Test Timeout  20 minutes
Test Setup  Run Keyword  Setup Base State
Test Teardown  Close All Browsers

*** Variables ***
${sample-image-name}  busybox
${sample-image-tag}  test
${sample-command-exit}  ls
${card-status-stopped}  STOPPED

*** Keywords ***
Setup Base State
    Open Firefox Browser
    Navigate To VIC UI Home Page
    Login On Single Sign-On Page
    Verify VIC UI Header Display

Teardown VCH And Docker Daemon
    [Arguments]  ${vch-name}  ${handle}  ${docker_daemon_pid}
    Close All Browsers
    Run Keyword And Ignore Error  Cleanup VCH  ${vch-name}
    Run Keyword And Ignore Error  Kill Local Docker Daemon  ${handle}  ${docker_daemon_pid}

*** Test Cases ***
Verify default harbor registry is displayed
    Navigate To Admin Page
    Navigate To Registries Page
    Select Registries Page Iframe
    Verify Column Value In Registries Table  1  ${HARBOR_URL}
    Verify Column Value In Registries Table  2  ${DEFAULT_HARBOR_NAME}
    Unselect Registries Page Iframe

Push an image to harbor and create a container
    Setup Docker Daemon
    # verify push image to harbor
    ${harbor-image-name}=  Set Variable  %{OVA_IP}/${DEFAULT_HARBOR_PROJECT}/${sample-image-name}
    ${harbor-image-tagged}=  Set Variable  ${harbor-image-name}:${sample-image-tag}
    Pull And Tag Docker Image  ${sample-image-name}  ${harbor-image-tagged}
    Push Docker Image To Harbor Registry  %{OVA_IP}  ${harbor-image-tagged}
    Navigate To VIC UI Home Page
    Navigate To Project Repositories Page
    Wait Until Keyword Succeeds  3x  2s  Verify Row Value In Project Repositories Grid  ${harbor-image-name}
    # create container from harbor image
    Download VIC Engine If Not Already  %{OVA_IP}
    Download CA Cert  %{OVA_IP}
    ${vch-name}=  Install VCH  additional-args=--registry-ca=./ca.crt  certs=${false}
    Add New Container Host And Verify Card  ${vch-name}
    Navigate To Containers Page
    Select Containers Page Iframe
    Verify Containers Page
    Provision And Verify New Container  %{OVA_IP}:443/${DEFAULT_HARBOR_PROJECT}/${sample-image-name}  ${sample-image-tag}  ${sample-command-exit}  ${card-status-stopped}
    Unselect Containers Page Iframe

    [Teardown]  Teardown VCH And Docker Daemon  ${vch-name}  ${handle}  ${docker_daemon_pid}