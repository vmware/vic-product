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
Documentation  Test 5-6-1 - VSAN-Simple
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  Simple VSAN Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Copy Support Bundle  %{OVA_IP}
Test Timeout  90 minutes

*** Keywords ***
Simple VSAN Setup
    [Timeout]    60 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    ${name}=  Evaluate  'vic-vsan-' + str(random.randint(1000,9999))  modules=random
    Set Suite Variable  ${user}  %{NIMBUS_PERSONAL_USER}
    ${out}=  Deploy Nimbus Testbed  spec=vic-vsan.rb  args=--plugin testng --noSupportBundles --vcvaBuild "${VC_VERSION}" --esxPxeDir "${ESX_VERSION}" --esxBuild "${ESX_VERSION}" --testbedName vic-vsan-simple-pxeBoot-vcva --runName ${name}
    Log  ${out}
    Should Contain  ${out}  "deployment_result"=>"PASS"

    ${out}=  Execute Command  ${NIMBUS_LOCATION_FULL} USER=%{NIMBUS_PERSONAL_USER} %{NIMBUS_CLI_PATH}/nimbus-ctl ip %{NIMBUS_PERSONAL_USER}-${name}.vc.0 | grep %{NIMBUS_PERSONAL_USER}-${name}.vc.0
    ${vc_ip}=  Fetch From Right  ${out}  ${SPACE}
    Log  ${vc_ip}

    ${pod}=  Fetch Pod  ${name}
    Log  ${pod}
    # set nimbus variable
    Set Suite Variable  ${nimbus_pod}  ${pod}
    Set Suite Variable  ${testbedname}  ${name}

    Log To Console  Deploy VIC to the VC cluster
    Set Environment Variable  TEST_URL  ${vc_ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_DATASTORE  vsanDatastore
    Set Environment Variable  TEST_RESOURCE  /dc1/host/cls1
    Set Environment Variable  VCH_TIMEOUT  30m0s

    # govc env variables
    Set Environment Variable  GOVC_URL  %{TEST_URL}
    Set Environment Variable  GOVC_USERNAME  %{TEST_USERNAME}
    Set Environment Variable  GOVC_PASSWORD  %{TEST_PASSWORD}
    Set Environment Variable  GOVC_INSECURE  1

*** Test Cases ***
Simple VSAN
    [Timeout]    90 minutes
    Log To Console  \nStarting test...
    Wait Until Keyword Succeeds  10x  30s  Check No VSAN DOMs In Datastore  %{TEST_DATASTORE}
    # install ova and verify
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-06-1-TEST  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
    # clean up OVA and VCH
    Download VIC Engine If Not Already  %{OVA_IP}
    Delete VCH Successfully  ${VCH-NAME}
    Cleanup VIC Product OVA  %{OVA_NAME}
    # check vsan doms
    Wait Until Keyword Succeeds  10x  30s  Check No VSAN DOMs In Datastore  %{TEST_DATASTORE}
