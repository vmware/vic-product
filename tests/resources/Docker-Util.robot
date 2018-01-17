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
Documentation  This resource contains any keywords dealing with docker operations
Library  OperatingSystem
Library  Process

*** Keywords ***
# The local dind version is embedded in Dockerfile
# docker:1.13-dind
# If you are running this keyword in a container, make sure it is run with --privileged turned on
Start Docker Daemon Locally
    [Arguments]  ${dockerd-path}=/usr/local/bin/dockerd-entrypoint.sh  ${log}=./daemon-local.log
    OperatingSystem.File Should Exist  ${dockerd-path}
    Log To Console  Starting docker daemon locally
    ${pid}=  Run  pidof dockerd
    Run Keyword If  '${pid}' != '${EMPTY}'  Run  kill -9 ${pid}
    Run Keyword If  '${pid}' != '${EMPTY}'  Log To Console  \nKilling local dangling dockerd process: ${pid}
    ${handle}=  Start Process  ${dockerd-path} >${log} 2>&1  shell=True
    Process Should Be Running  ${handle}
    :FOR  ${IDX}  IN RANGE  5
    \   ${pid}=  Run  pidof dockerd
    \   Run Keyword If  '${pid}' != '${EMPTY}'  Set Test Variable  ${dockerd-pid}  ${pid}
    \   Exit For Loop If  '${pid}' != '${EMPTY}'
    \   Sleep  1s
    Should Not Be Equal  '${dockerd-pid}'  '${EMPTY}'
    :FOR  ${IDX}  IN RANGE  10
    \   ${rc}=  Run And Return Rc  DOCKER_API_VERSION=1.23 docker -H unix:///var/run/docker-local.sock ps
    \   Return From Keyword If  '${rc}' == '0'  ${handle}  ${dockerd-pid}
    \   Sleep  1s
    Fail  Failed to initialize local dockerd
    [Return]  ${handle}  ${dockerd-pid}

Kill Local Docker Daemon
    [Arguments]  ${handle}  ${dockerd-pid}
    Terminate Process  ${handle}
    Process Should Be Stopped  ${handle}
    ${rc}=  Run And Return Rc  kill -9 ${dockerd-pid}
    Should Be Equal As Integers  ${rc}  0

Download CA Cert
    [Arguments]  ${ova-ip}  ${download-path}=.
    :FOR  ${IDX}  IN RANGE  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  sshpass -p ${OVA_PASSWORD_ROOT} scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${OVA_USERNAME_ROOT}@${ova-ip}:${OVA_CERT_PATH}/ca.crt ${download-path}
    \   Exit For Loop If  '${rc}' == '0'
    \   Sleep  5s
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0

Setup CA Cert for Harbor Registry
    [Arguments]  ${ova-ip}
    Download CA Cert  ${ova-ip}
    Run command and Return output  mkdir -p /etc/docker/certs.d/${ova-ip}
    Run command and Return output  mv ca.crt /etc/docker/certs.d/${ova-ip}/ca.crt
    Run command and Return output  ls /etc/docker/certs.d/${ova-ip}

Docker Login To Harbor Registry
    [Tags]  secret
    [Arguments]  ${registry_ip}  ${docker}=${DEFAULT_LOCAL_DOCKER}  ${docker_endpoint}=${DEFAULT_LOCAL_DOCKER_ENDPOINT}
    ${output}=  Run command and Return output  ${docker} -H ${docker_endpoint} login ${registry_ip} --username %{TEST_USERNAME} --password %{TEST_PASSWORD}
    Should Contain  ${output}  Login Succeeded
    Log To Console  \nDocker login successfully

Pull And Tag Docker Image
    [Arguments]  ${image-name}  ${tagged-image}  ${docker}=${DEFAULT_LOCAL_DOCKER}  ${docker-endpoint}=${DEFAULT_LOCAL_DOCKER_ENDPOINT}
    Run command and Return output  ${docker} -H ${docker-endpoint} pull ${image-name}
    ${output}=  Run command and Return output  ${docker} -H ${docker-endpoint} image ls
    Should Contain  ${output}  ${image-name}
    Log To Console  \n${image-name} pulled successfully
    Run command and Return output  ${docker} -H ${docker-endpoint} tag ${image-name} ${tagged-image}
    Log To Console  \n${image-name} tagged successfully
    [Return]  ${tagged-image}

Push Docker Image To Harbor Registry
    [Arguments]  ${registry-ip}  ${image-tag}  ${docker}=${DEFAULT_LOCAL_DOCKER}  ${docker-endpoint}=${DEFAULT_LOCAL_DOCKER_ENDPOINT}
    Setup CA Cert for Harbor Registry  ${registry-ip}
    Wait Until Keyword Succeeds  3x  4s  Docker Login To Harbor Registry  ${registry-ip}
    ${rc}=  Run And Return Rc  ${docker} -H ${docker-endpoint} push ${image-tag}
    Should Be Equal As Integers  ${rc}  0
    Log To Console  \n${image-tag} pushed successfully