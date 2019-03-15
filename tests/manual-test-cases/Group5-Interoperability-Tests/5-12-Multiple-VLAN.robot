# Copyright 2018 VMware, Inc. All Rights Reserved.
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
Documentation  Test 5-12 - Multiple VLAN
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  Multiple VLAN Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Collect Appliance and VCH Logs  ${VCH-NAME}
Test Timeout  90 minutes

*** Keywords ***
Multiple VLAN Setup
    [Timeout]    60 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    Setup Simple VC And Test Environment with Shared iSCSI Storage

    ${out}=  Run  govc dvs.portgroup.change -vlan 1 bridge
    Should Contain  ${out}  OK
    ${out}=  Run  govc dvs.portgroup.change -vlan 2 management
    Should Contain  ${out}  OK

*** Test Cases ***
Test
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-12-TEST  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
