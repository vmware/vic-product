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
Documentation  Global Variables, Setup and Teardown
Resource  ../resources/Util.robot
Suite Setup  Global Setup
Suite Teardown  Global Teardown

*** Variables ***
${vic-ova-file-path}  installer/bin/vic-*.ova

*** Keywords ***
Global Setup
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
    # ova variables
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # vCenter variables
    Set Test VC Variables
    # common vch variables
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  VCH_TIMEOUT
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  VCH_TIMEOUT  20m0s
    # make sure vCenter is up and running
    Check VCenter
    # Install VIC appliance
    Install VIC Product OVA  ${vic-ova-file-path}
    # UI tests variables
    Set Global Variable  ${FIREFOX_BROWSER}  firefox
    Set Global Variable  ${GRID_URL}  http://127.0.0.1:4444/wd/hub
    Set Global Variable  ${EXPLICIT_WAIT}  30
    Set Global Variable  ${EXTRA_EXPLICIT_WAIT}  50
    Set Global Variable  ${PRIMARY_PORT}  8282
    Set Global Variable  ${GS_PAGE_PORT}  9443
    Set Global Variable  ${BASE_URL}  https://%{OVA_IP}:${PRIMARY_PORT}
    Set Global Variable  ${GS_PAGE_BASE_URL}  https://%{OVA_IP}:${GS_PAGE_PORT}
    Set Global Variable  ${COMPLETE_INSTALL_URL}  https://%{OVA_IP}:${GS_PAGE_PORT}/?login=true
    # complete installation on UI
    Open Firefox Browser
    Log In And Complete OVA Installation
    Close All Browsers

Global Teardown
    Log To Console  Running global teardown...
    Cleanup VIC Product OVA  %{OVA_NAME}
