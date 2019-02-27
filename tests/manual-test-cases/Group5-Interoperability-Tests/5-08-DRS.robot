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
Documentation  Test 5-08 - DRS
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  DRS Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Collect Appliance and VCH Logs  ${VCH-NAME}
Test Timeout  90 minutes

*** Keywords ***
DRS Setup
    [Timeout]    60 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    Setup Simple VC And Test Environment with Shared iSCSI Storage

    Log To Console  Disable DRS on the cluster
    ${rc}  ${out}=  Run And Return Rc And Output  govc cluster.change -drs-enabled=false %{TEST_RESOURCE}
    Should Be Empty  ${out}
    Should Be Equal As Integers  ${rc}  0

*** Test Cases ***
Test
    Log To Console  Create VCH with DRS disabled...
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-08-NO-DRS  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}

    Log To Console  Enable DRS on the cluster....
    ${rc}  ${out}=  Run And Return Rc And Output  govc cluster.change -drs-enabled %{TEST_RESOURCE}
    Should Be Empty  ${out}
    Should Be Equal As Integers  ${rc}  0

    Log To Console  Create VCH with DRS enabled...
    # create vch and set docker params
    Wait Until Keyword Succeeds  3x  1m  Create VCH using UI And Set Docker Parameters  5-08-TEST-DRS  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
    # run vch regression tests
    Run Docker Regression Tests For VCH
