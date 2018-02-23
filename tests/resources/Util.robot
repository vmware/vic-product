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
Library  OperatingSystem
Library  String
Library  Collections
Library  requests
Library  Process
Library  SSHLibrary  5 minute
Library  DateTime
Resource  OVA-Util.robot
Resource  VC-Util.robot
Resource  VCH-Util.robot
Resource  UI-Util.robot
Resource  Docker-Util.robot
Library  Selenium2Library  timeout=30  implicit_wait=15  run_on_failure=Capture Page Screenshot  screenshot_root_directory=test-screenshots
# UI page object utils
Resource  page-objects/Getting-Started-Page-Util.robot
Resource  page-objects/Complete-Installation-Modal-Util.robot
Resource  page-objects/VC-Single-Sign-On-Util.robot
Resource  page-objects/Header-Util.robot
Resource  page-objects/Side-Nav-Util.robot
Resource  page-objects/Container-Hosts-Page-Util.robot
Resource  page-objects/New-Container-Host-Modal-Util.robot
Resource  page-objects/Verify-Certificate-Modal-Util.robot
Resource  page-objects/Remove-Host-Modal-Util.robot
Resource  page-objects/Containers-Page-Util.robot
Resource  page-objects/Provision-Container-Page-Util.robot
Resource  page-objects/Right-Context-Panel-Util.robot
Resource  page-objects/Registries-Page-Util.robot
Resource  page-objects/Project-Repositories-Page-Util.robot

*** Keywords ***
Global Environment Setup
    [Tags]  secret
    Log To Console  Running global setup...
    # vCenter variables
    Environment Variable Should Be Set  TEST_URL
    Environment Variable Should Be Set  TEST_USERNAME
    Environment Variable Should Be Set  TEST_PASSWORD
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  PUBLIC_NETWORK
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  PUBLIC_NETWORK  'vm-network'
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  PUBLIC_NETWORK
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  BRIDGE_NETWORK  'bridge'
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  TEST_DATASTORE
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  TEST_DATASTORE  datastore1
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  TEST_DATACENTER
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  TEST_DATACENTER  /datacenter1
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  TEST_RESOURCE
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  TEST_RESOURCE  /dc1/host/cls
    # drone variables
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  DRONE_BUILD_NUMBER
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  DRONE_BUILD_NUMBER  0
    # govc env variables
    Set Environment Variable  GOVC_URL  %{TEST_URL}
    Set Environment Variable  GOVC_USERNAME  %{TEST_USERNAME}
    Set Environment Variable  GOVC_PASSWORD  %{TEST_PASSWORD}
    Set Environment Variable  GOVC_INSECURE  1
    # vCenter variables
    Set Test VC Variables
    # ova variables
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Set Global Variable  ${OVA_CERT_PATH}  /storage/data/admiral/ca_download
    # common vch variables
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  VCH_TIMEOUT
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  VCH_TIMEOUT  20m0s
    # make sure vCenter is up and running
    Check VCenter
    # set common OVA name
    Set Common Test OVA Name
    # dind variables
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER}  DOCKER_API_VERSION=1.23 docker
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER_ENDPOINT}  unix:///var/run/docker-local.sock

Global Setup With Complete OVA Installation
    Global Environment Setup
    Set Test OVA IP If Available
    Set Browser Variables

Set Browser Variables
    # UI tests variables
    Set Global Variable  ${FIREFOX_BROWSER}  firefox
    Set Global Variable  ${GRID_URL}  http://selenium-grid-hub:4444/wd/hub
    Set Global Variable  ${EXPLICIT_WAIT}  30
    Set Global Variable  ${EXTRA_EXPLICIT_WAIT}  60
    Set Global Variable  ${PRIMARY_PORT}  8282
    Set Global Variable  ${GS_PAGE_PORT}  9443
    Set Global Variable  ${HARBOR_PORT}  443
    Set Global Variable  ${IP_URL}  https://%{OVA_IP}
    Set Global Variable  ${BASE_URL}  ${IP_URL}:${PRIMARY_PORT}
    Set Global Variable  ${GS_PAGE_BASE_URL}  ${IP_URL}:${GS_PAGE_PORT}
    Set Global Variable  ${COMPLETE_INSTALL_URL}  ${GS_PAGE_BASE_URL}/?login=true
    Set Global Variable  ${HARBOR_URL}  ${IP_URL}:${HARBOR_PORT}
    Set Global Variable  ${DEFAULT_HARBOR_NAME}  default-vic-registry
    Set Global Variable  ${DEFAULT_HARBOR_PROJECT}  default-project

Run command and Return output
    [Arguments]  ${command}
    ${rc}  ${output}=  Run And Return Rc And Output  ${command}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    [Return]  ${output}

Check service running
    [Arguments]  ${service-name}
    Log To Console  Checking status of ${service-name}...
    ${out}=  Execute Command  systemctl status -l ${service-name}
    Should Contain  ${out}  Active: active (running)