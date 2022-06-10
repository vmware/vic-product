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
Documentation  Test 5-04 - Multiple Clusters
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  Multiple Cluster Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Pod Cleanup  ${nimbus_pod}  ${testbedname}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Collect Appliance and VCH Logs  ${VCH-NAME}
Test Timeout  90 minutes

*** Keywords ***
Multiple Cluster Setup
# set up nimbus test bed and env variables
    [Timeout]    60 minutes
    ${name}=  Evaluate  'vic-multi-cluster-' + str(random.randint(1000,9999))  modules=random
    Log To Console  Create a new simple vc cluster with spec vic-multi-cls.rb...
    ${out}=  Deploy Nimbus Testbed  spec=vic-multi-cls.rb  args=--noSupportBundles --plugin testng --vcvaBuild "${VC_VERSION}" --esxBuild "${ESX_VERSION}" --testbedName vic-multi-cluster --runName ${name}
    Log  ${out}
    Log To Console  Finished creating cluster ${name}

    ${out}=  Execute Command  ${NIMBUS_LOCATION_FULL} USER=%{NIMBUS_PERSONAL_USER} %{NIMBUS_CLI_PATH}/nimbus-ctl ip %{NIMBUS_PERSONAL_USER}-${name}.vc.0 | grep %{NIMBUS_PERSONAL_USER}-${name}.vc.0
    ${vc_ip}=  Fetch From Right  ${out}  ${SPACE}
    Log  ${vc_ip}

    ${out}=  Execute Command  ${NIMBUS_LOCATION_FULL} USER=%{NIMBUS_PERSONAL_USER} %{NIMBUS_CLI_PATH}/nimbus-ctl ip %{NIMBUS_PERSONAL_USER}-${name}.esx.0 | grep %{NIMBUS_PERSONAL_USER}-${name}.esx.0
    ${esx0_ip}=  Fetch From Right  ${out}  ${SPACE}
    Log  ${esx0_ip}

    ${pod}=  Fetch Pod  ${name}
    Log  ${pod}
    # set nimbus variable
    Set Suite Variable  ${nimbus_pod}  ${pod}
    Set Suite Variable  ${testbedname}  ${name}

    # set test variables
    Set Environment Variable  TEST_URL  ${vc_ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    
    # govc env variables
    Set Environment Variable  GOVC_URL  %{TEST_URL}
    Set Environment Variable  GOVC_USERNAME  %{TEST_USERNAME}
    Set Environment Variable  GOVC_PASSWORD  %{TEST_PASSWORD}
    Set Environment Variable  GOVC_INSECURE  1

    # get cluster and datastore
    ${rc}  ${test_resource}=  Run And Return Rc And Output  govc host.info ${esx0_ip} | grep Path | awk -F: '{print $2}'
    Log  ${test_resource}
    ${test_resource}=  Remove String  ${test_resource}  /${esx0_ip}
    ${test_resource}=  Strip String  ${test_resource}
    Log  ${test_resource}
 
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  ${test_resource}
    
    # Make sure we use correct datastore
    ${rc}  ${datastore}=  Run And Return Rc And Output  govc host.info -host.ip=${esx0_ip} -json | jq -r '.HostSystems[].Config.FileSystemVolume.MountInfo[].Volume | select(.Type == "VMFS" and .Local == false) | .Name'
    Log  ${datastore}
    Set Environment Variable  TEST_DATASTORE  ${datastore}
    
    # set VC variables
    Set Test VC Variables
    # set VCH variables
    Set Environment Variable  DRONE_BUILD_NUMBER  0
    Set Environment Variable  VCH_TIMEOUT  20m0s
    # set docker variables
    # not using dind but host dockerd for these nightly tests
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER}  docker
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER_ENDPOINT}  unix:///var/run/docker.sock
    # set harbor variables
    Set Global Variable  ${DEFAULT_HARBOR_PROJECT}  default-project
    # govc env variables
    Set Environment Variable  GOVC_URL  %{TEST_URL}
    Set Environment Variable  GOVC_USERNAME  %{TEST_USERNAME}
    Set Environment Variable  GOVC_PASSWORD  %{TEST_PASSWORD}
    Set Environment Variable  GOVC_INSECURE  1
    # check VC
    Check VCenter

*** Test Cases ***
Test
    Deploy OVA And Install UI Plugin And Run Regression Tests  5-04-TEST  vic-*.ova  %{TEST_DATASTORE}  %{BRIDGE_NETWORK}  %{PUBLIC_NETWORK}  %{TEST_USERNAME}  %{TEST_PASSWORD}
