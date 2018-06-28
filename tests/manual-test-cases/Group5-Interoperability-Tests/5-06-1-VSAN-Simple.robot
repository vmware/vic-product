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

*** Keywords ***
Simple VSAN Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    ${name}=  Evaluate  'vic-vsan-' + str(random.randint(1000,9999))  modules=random
    Set Suite Variable  ${user}  %{NIMBUS_USER}
    ${out}=  Deploy Nimbus Testbed  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  spec=vic-vsan.rb  args=--plugin testng --noSupportBundles --vcvaBuild ${VC_VERSION} --esxPxeDir ${ESX_VERSION} --esxBuild ${ESX_VERSION} --testbedName vic-vsan-simple-pxeBoot-vcva --runName ${name}

    Log  ${out}
    Should Contain  ${out}  "deployment_result"=>"PASS"

    Log To Console   Get VC IP ...
    Open Connection  %{NIMBUS_GW}
    Wait Until Keyword Succeeds  10 min  30 sec  Login  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    ${vc-ip}=  Get IP  ${name}.vcva-${VC_VERSION}
    Close Connection

    Set Suite Variable  @{list}  ${user}-${name}.vcva-${VC_VERSION}  ${user}-${name}.esx.0  ${user}-${name}.esx.1  ${user}-${name}.esx.2  ${user}-${name}.esx.3  ${user}-${name}.nfs.0  ${user}-${name}.iscsi.0
    Log To Console   Finished Creating Simple VSAN

    Log To Console  Set environment variables up for GOVC
    Set Environment Variable  GOVC_INSECURE  1
    Set Environment Variable  GOVC_URL  ${vc-ip}
    Set Environment Variable  GOVC_USERNAME  Administrator@vsphere.local
    Set Environment Variable  GOVC_PASSWORD  Admin\!23

    Add Host To Distributed Switch  /vcqaDC/host/cls

    Log To Console  Enable DRS and VSAN on the cluster
    ${out}=  Run  govc cluster.change -drs-enabled /vcqaDC/host/cls
    Should Be Empty  ${out}

    Log To Console  Deploy VIC to the VC cluster
    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Remove Environment Variable  TEST_DATACENTER
    Set Environment Variable  TEST_DATASTORE  vsanDatastore
    Set Environment Variable  TEST_RESOURCE  /vcqaDC/host/cls
    Set Environment Variable  VCH_TIMEOUT  30m0s

*** Test Cases ***
Simple VSAN
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
