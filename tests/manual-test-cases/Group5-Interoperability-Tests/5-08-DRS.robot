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
Suite Setup  Wait Until Keyword Succeeds  10x  10m  DRS Setup
Suite Teardown  Nimbus Cleanup  ${list}

*** Keywords ***
DRS Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    ${esx1}  ${esx2}  ${esx3}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${esx3-ip}  ${vc-ip}=  Create a Simple VC Cluster
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  ${esx3}  %{NIMBUS_USER}-${vc}

    Log To Console  Disable DRS on the cluster
    ${rc}  ${out}=  Run And Return Rc And Output  govc cluster.change -drs-enabled=false /ha-datacenter/host/cls
    Should Be Empty  ${out}
    Should Be Equal As Integers  ${rc}  0

    Set Environment Variable  TEST_RESOURCE  /ha-datacenter/host/cls/Resources

*** Test Cases ***
Test
    Log To Console  Create VCH with DRS disabled...
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-08-NO-DRS  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}

    Log To Console  Enable DRS on the cluster....
    ${rc}  ${out}=  Run And Return Rc And Output  govc cluster.change -drs-enabled /ha-datacenter/host/cls
    Should Be Empty  ${out}
    Should Be Equal As Integers  ${rc}  0

    Log To Console  Create VCH with DRS enabled...
    Create VCH using UI And Set Docker Parameters  5-08-TEST-DRS  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
    # run vch regression tests
    Run Docker Regression Tests For VCH
