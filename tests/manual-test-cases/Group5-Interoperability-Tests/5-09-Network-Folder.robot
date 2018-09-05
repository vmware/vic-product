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
Documentation  Test 5-09 - Network Folder
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  DVS Under Network Folder Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${datacenter}=  ha-datacenter
${cluster}=  cls
${esx_number}=  2
${dvs}=  test-ds
${folder}=  /${datacenter}/network/testFolder

*** Keywords ***
DVS Under Network Folder Setup
    [Timeout]    110 minutes
    Log To Console  \nStarting VC cluster deploy with DVS in network folder...
    ${vc}=  Evaluate  'VC-' + str(random.randint(1000,9999)) + str(time.clock())  modules=random,time
    ${pid}=  Deploy Nimbus vCenter Server Async  ${vc}

    &{esxes}=  Deploy Multiple Nimbus ESXi Servers in Parallel  ${esx_number}  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}  "${ESX_VERSION}"
    @{esx_names}=  Get Dictionary Keys  ${esxes}
    @{esx_ips}=  Get Dictionary Values  ${esxes}

    Set Suite Variable  @{list}  @{esx_names}[0]  @{esx_names}[1]  %{NIMBUS_USER}-${vc}

    # Finish vCenter deploy
    ${output}=  Wait For Process  ${pid}
    Should Contain  ${output.stdout}  Overall Status: Succeeded

    Open Connection  %{NIMBUS_GW}
    Wait Until Keyword Succeeds  2 min  30 sec  Login  %{NIMBUS_USER}  %{NIMBUS_PASSWORD}
    ${vc_ip}=  Get IP  ${vc}
    Close Connection

    Set Environment Variable  GOVC_INSECURE  1
    Set Environment Variable  GOVC_USERNAME  Administrator@vsphere.local
    Set Environment Variable  GOVC_PASSWORD  Admin!23
    Set Environment Variable  GOVC_URL  ${vc_ip}

    Log To Console  Create a datacenter on the VC
    ${out}=  Run  govc datacenter.create ${datacenter}
    Should Be Empty  ${out}

    Log To Console  Create a cluster on the VC
    ${out}=  Run  govc cluster.create ${cluster}
    Should Be Empty  ${out}

    Log To Console  Add ESX host to the VC
    :FOR  ${IDX}  IN RANGE  ${esx_number}
    \   ${out}=  Run  govc cluster.add -hostname=@{esx_ips}[${IDX}] -username=root -dc=${datacenter} -password=${NIMBUS_ESX_PASSWORD} -noverify=true
    \   Should Contain  ${out}  OK

    Log To Console  Create a new network folder...
    ${out}=  Run  govc folder.create ${folder}
    Should Be Empty  ${out}
    Log To Console  Create a distributed switch under a new network folder...
    ${out}=  Run  govc dvs.create -dc=${datacenter} -folder=${folder} ${dvs}
    Should Contain  ${out}  OK
    Log To Console  Create three new distributed switch port groups for management and vm network traffic
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=${datacenter} -dvs=${dvs} management
    Should Contain  ${out}  OK
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=${datacenter} -dvs=${dvs} vm-network
    Should Contain  ${out}  OK
    ${out}=  Run  govc dvs.portgroup.add -nports 12 -dc=${datacenter} -dvs=${dvs} bridge
    Should Contain  ${out}  OK

    Wait Until Keyword Succeeds  10x  3 minutes  Add Host To Distributed Switch  /${datacenter}/host/${cluster}  ${dvs}

    Log To Console  Enable DRS on the cluster
    ${out}=  Run  govc cluster.change -drs-enabled /${datacenter}/host/${cluster}
    Should Be Empty  ${out}

    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_URL  ${vc_ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  TEST_DATASTORE  datastore1
    Set Environment Variable  TEST_DATACENTER  /${datacenter}
    Set Environment Variable  TEST_RESOURCE  /${datacenter}/host/${cluster}

*** Test Cases ***
Test
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-09-TEST  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
