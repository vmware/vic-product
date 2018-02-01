# Copyright 2017 VMware, Inc. All Rights Reserved.
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
Documentation  This resource provides any keywords related to VIC Product OVA
Resource  ../resources/Util.robot

*** Keywords ***
Set Common Test OVA Name
    ${name}=  Evaluate  'OVA-%{DRONE_BUILD_NUMBER}'
    Set Environment Variable  OVA_NAME  ${name}

Get Test OVA Name
    ${name}=  Evaluate  'OVA-%{DRONE_BUILD_NUMBER}-' + str(random.randint(1000,9999))  modules=random
    [Return]  ${name}

Set Test OVA IP If Available
    Log To Console  \nCheck VIC appliance and set OVA_IP env variable...
    Set Common Test OVA Name
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.ip %{OVA_NAME}
    Run Keyword Unless  ${rc} == 0  Should Contain  ${output}  not found
    Run Keyword If  ${rc} == 0  Set Environment Variable  OVA_IP  ${output}
    [Return]  ${rc}

Install VIC Product OVA
    [Tags]  secret
    [Arguments]  ${ova-file}  ${ova-name}
    Log To Console  \nInstalling VIC appliance...
    ${output}=  Run  ovftool --datastore=%{TEST_DATASTORE} --noSSLVerify --acceptAllEulas --name=${ova-name} --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}%{TEST_RESOURCE}'
    Should Contain  ${output}  Completed successfully
    Should Contain  ${output}  Received IP address:
    
    ${output}=  Split To Lines  ${output}
    ${ova-ip}=  Set Variable  NULL
    :FOR  ${line}  IN  @{output}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${line}  Received IP address:
    \   ${ip}=  Run Keyword If  ${status}  Fetch From Right  ${line}  ${SPACE}
    \   ${ova-ip}=  Run Keyword If  ${status}  Set Variable  ${ip}  ELSE  Set Variable  ${ova-ip}

    Wait For Register Page  ${ova-ip}

    # set env var for ova ip
    Set Environment Variable  OVA_IP  ${ova-ip}
    Wait For Online Components
    
    # validate complete installation on UI
    Log To Console  Initializing the OVA using the getting started ui...
    Set Browser Variables
    Open Firefox Browser
    Log In And Complete OVA Installation
    Close All Browsers

    # wait for component services to get started
    Wait For Online Components  ${ova-ip}
    Wait For SSO Redirect  ${ova-ip}

    [Return]  ${ova-ip}

Install Common OVA If Not Already
    [Arguments]  ${ova-file}
    ${rc}=  Set Test OVA IP If Available
    ${ova-ip}=  Run Keyword Unless  ${rc} == 0  Install VIC Product OVA  ${ova-file}  %{OVA_NAME}

Download VIC Engine
    [Arguments]  ${ova-ip}  ${target_dir}=bin
    Log To Console  \nDownloading VIC engine...
    ${download_url}=  Run command and Return output  curl -k https://${ova-ip}:9443 | tac | tac | grep -Po -m 1 '(?<=href=")[^"]*tar.gz'
    Run command and Return output  mkdir -p ${target_dir}
    Run command and Return output  curl -k ${download_url} --output ${target_dir}/vic.tar.gz
    Run command and Return output  tar -xvzf ${target_dir}/vic.tar.gz --strip-components=1 --directory=${target_dir}

Download VIC Engine If Not Already
    [Arguments]  ${target_dir}=bin
    ${status}=  Run Keyword And Return Status  Directory Should Not Be Empty  ${target_dir}
    Run Keyword Unless  ${status}  Download VIC engine

Cleanup VIC Product OVA
    [Arguments]  ${ova_target_vm_name}
    Log To Console  \nCleaning up VIC appliance...
    ${rc}=  Wait Until Keyword Succeeds  10x  5s  Run GOVC  vm.destroy ${ova_target_vm_name}
    Run Keyword And Ignore Error  Run GOVC  datastore.rm /%{TEST_DATASTORE}/vm/${ova_target_vm_name}
    Run Keyword if  ${rc}==0  Log To Console  \nVIC Product OVA deployment ${ova_target_vm_name} is cleaned up on test server %{TEST_URL}

Wait For Register Page
    [Arguments]  ${ova-ip}
    Log To Console  \nWaiting for Getting Started Page to Come Up...
    :FOR  ${i}  IN RANGE  20
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"target":"%{TEST_URL}:443","user":"%{TEST_USERNAME}","password":"%{TEST_PASSWORD}"}' https://${ova-ip}:9443/register
    \   Exit For Loop If  '200' in '''${out}'''
    \   Sleep  3s
    Log To Console  ${rc}
    Log To Console  ${out}
    Should Contain  ${out}  200

Wait For Online Components
    [Arguments]  ${ova-ip}
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${ova-ip}

    Open Connection  ${ova-ip}
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    Wait Until Keyword Succeeds  20x  10s  Check service running  fileserver
    Wait Until Keyword Succeeds  20x  10s  Check service running  admiral
    Wait Until Keyword Succeeds  20x  10s  Check service running  harbor

    Close connection

Wait For SSO Redirect
    [Arguments]  ${ova-ip}
    Log To Console  \nWaiting for SSO redirect to come up...
    :FOR  ${i}  IN RANGE  20
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" https://${ova-ip}:8282
    \   Exit For Loop If  '302' in '''${out}'''
    \   Sleep  3s
    Log To Console  ${rc}
    Log To Console  ${out}
    Should Contain  ${out}  302

Gather Support Bundle
    Log To Console  \nGathering VIC Appliance support bundle
    ${out}=  Execute Command  /etc/vmware/support/appliance-support.sh
    [Return]  ${out}

Get Support Bundle File
    # ${command_output} is return value from Gather Support Bundle
    [Arguments]  ${command_output}
    ${lines}=  Get Lines Matching Pattern  ${command_output}  Created log bundle*
    ${num}=    Get Line Count  ${lines}
    Should Be Equal As Integers  ${num}  1

    ${file}=  Fetch From Right  ${lines}  Created log bundle
    Should Not Contain  ${file}  ' '
    [Return]  ${file.strip()}

Copy Support Bundle
    [Arguments]  ${ova-ip}
    Log To Console  \nGather support bundle and copy locally...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${ova-ip}

    Open Connection  ${ova-ip}
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    # get support bundle file
    ${output}=  Gather Support Bundle
    Should Contain  ${output}  Created log bundle
    ${file}=  Get Support Bundle File  ${output}

    Close connection

    # copy log bundle
    ${output}=  Run command and Return output  sshpass -p ${OVA_PASSWORD_ROOT} scp -o StrictHostKeyChecking\=no -o UserKnownHostsFile=/dev/null ${OVA_USERNAME_ROOT}@${ova-ip}:${file} .
