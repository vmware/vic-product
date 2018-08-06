# Copyright 2018 VMware, Inc. All Rights Reserved.
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
Documentation  Test 5-01 DCH
Resource  ../../resources/Util.robot
Test Timeout  5 minutes
Test Setup  Run Keyword  Setup Base State

*** Variables ***
${dinv-namespace} vmware
${dinv-image-tag} 17.06
${sample-image-name}  dch-photon
${sample-image-tag}  test

*** Keywords ***
Setup Base State
    Download VIC Engine If Not Already  %{OVA_IP}
    ${vch-name}=  Install VCH  certs=${false}
    # push dch-photon:17.06 image
    ${harbor-image-name}=  Set Variable  %{OVA_IP}/${DEFAULT_HARBOR_PROJECT}/${sample-image-name}
    ${harbor-image-tagged}=  Set Variable  ${harbor-image-name}:${sample-image-tag}
    ${dinv-image-name}= Set Variable ${dinv-namespace}/${sample-image-name}:${dinv-image-tag}
    Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${DEFAULT_LOCAL_DOCKER_ENDPOINT} tag ${dinv-image-name} ${harbor-image-tagged}
    Log To Console  \n${dinv-image-name} tagged successfully
    Push Docker Image To Harbor Registry  %{OVA_IP}  ${harbor-image-tagged}

*** Test Cases ***
Verify non-tls is enabled for dch-photon
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12375:2375 ${harbor-image-tagged}
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  /dinv
    # verify 12375 could be accessed without any certs to show docker info
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12375 info
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  Containers

Verify tls enabled scenario for dch-photon
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12376:2376 ${harbor-image-tagged} --tls
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  --tls
    # verify 12376 could be accessed with --tls to show docker info
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12376 --tls info
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  Containers

Verify tlsverify enabled scenario for dch-photon
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12386:2376 ${harbor-image-tagged} --tlsverify
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  --tlsverify
    # verify 12386 could be accessed with --tls to show docker info
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12386 --tls info
    Should Be Equal As Integers  ${rc}  1
    Should Contain  ${output}  'bad certificate'

    [Teardown] Cleanup VCH