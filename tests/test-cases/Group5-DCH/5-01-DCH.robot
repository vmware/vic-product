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
${harbor-ci-registry}  harbor.ci.drone.local
${dinv-image-tag}  17.06
${dinv-image-name}  dch-photon
${harbor-image-name}  ${harbor-ci-registry}/${dinv-image-name}
${harbor-image-tagged}  ${harbor-image-name}:${dinv-image-tag}

*** Keywords ***
Setup Base State
    Download VIC Engine If Not Already  %{OVA_IP}

*** Test Cases ***
Verify non-tls is enabled for dch-photon
    ${vch-name}=  Install VCH  certs=${false}
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12375:2375 ${harbor-image-tagged}
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  /dinv
    # verify 12375 could be accessed without any certs to show docker info
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12375 info
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  Containers

    [Teardown]  Cleanup VCH  ${vch-name}

Verify tls enabled scenario for dch-photon
    ${vch-name}=  Install VCH  certs=${false}
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12376:2376 ${harbor-image-tagged} -tls
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  -tls
    # verify 12376 could be accessed with --tls to show docker info
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12376 --tls info
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  Containers

    [Teardown]  Cleanup VCH  ${vch-name}

Verify tlsverify enabled scenario for dch-photon
    ${vch-name}=  Install VCH  certs=${false}
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12386:2376 ${harbor-image-tagged} -tlsverify
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  -tlsverify
    # verify 12386 could not be accessed with --tls due to missing certs
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12386 --tls info
    Should Be Equal As Integers  ${rc}  1
    Should Contain  ${output}  'bad certificate'

    [Teardown]  Cleanup VCH  ${vch-name}