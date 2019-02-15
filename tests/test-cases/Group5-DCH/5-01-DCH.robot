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
Test Timeout  20 minutes
Test Setup  Run Keyword  Setup Base State

*** Variables ***
${dinv-image-tag}  17.06
${dinv-image-name}  dch-photon
${harbor-image-name}  %{HARBOR_CI_REGISTRY}/${DEFAULT_HARBOR_PROJECT}/${dinv-image-name}
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
    :FOR  ${IDX}  IN RANGE  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12375 info 
    \   Log  ${output}
    \   Exit For Loop If  Should Not Contain  ${output}  'Is the docker daemon running'
    \   Sleep  3s 
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
    :FOR  ${IDX}  IN RANGE  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12376 --tls info   
    \   Log  ${output}
    \   Exit For Loop If  Should Not Contain  ${output}  'Is the docker daemon running'
    \   Sleep  3s 
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
    :FOR  ${IDX}  IN RANGE  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12386 --tls info 
    \   Log  ${output}
    \   Exit For Loop If  Should Not Contain  ${output}  'Is the docker daemon running'
    \   Sleep  3s 
    Should Be Equal As Integers  ${rc}  1
    Should Contain  ${output}  --tlsverify

    [Teardown]  Cleanup VCH  ${vch-name}

Verify the certificate is not signed by nil when vic-ip is not specified
    ${vch-name}=  Install VCH  certs=${false}
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12396:2376 --name my-test ${harbor-image-tagged} -tlsverify
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    # Copy certs to local for test
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} cp my-test:/certs .
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    # The IP address for eth0 (172.16.xx.xx) in server cert will be returned when vic-ip is not specified
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12396 --tlsverify --tlscacert ./certs/ca.crt --tlskey ./certs/docker-client.key --tlscert ./certs/docker-client.crt info
    Log  ${output}
    Should Contain  ${output}  certificate is valid for 172

    [Teardown]  Cleanup VCH  ${vch-name}

Verify the certificate is not signed by nil when vic-ip is specified with FQDN
    ${vch-name}=  Install VCH  certs=${false}
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12376:2376 --name my-test ${harbor-image-tagged} -tlsverify -vic-ip foo.com
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    # Copy certs to local for test
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} cp my-test:/certs .
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    # The IP address for FQDN foo.com will be signed
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12376 --tlsverify --tlscacert ./certs/ca.crt --tlskey ./certs/docker-client.key --tlscert ./certs/docker-client.crt info
    Log  ${output}
    Should Not Contain  ${output}  certificate is valid for ,

    [Teardown]  Cleanup VCH  ${vch-name}

Verify local enabled scenario for dch-photon
    ${vch-name}=  Install VCH  certs=${false}
    ${rc}=  Run command and Return output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} run -d -p 12389:2376 ${harbor-image-tagged} -tls -local

    # Verify 12389 could not be accessed with -local due to dockerd only monitors local unix socket
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} -H ${VCH-IP}:12389 --tls ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  1
    Should Contain  ${output}  Cannot connect to the Docker daemon at tcp://${VCH-IP}:12389

    [Teardown]  Cleanup VCH  ${vch-name}
