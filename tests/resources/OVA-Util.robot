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

*** Keywords ***
Set Test VCH Name
    ${name}=  Evaluate  'VCH-%{DRONE_BUILD_NUMBER}-' + str(random.randint(1000,9999))  modules=random
    Set Environment Variable  VCH_NAME  ${name}

Set Test Environment Variables
    Environment Variable Should Be Set  TEST_URL
    Environment Variable Should Be Set  TEST_USERNAME
    Environment Variable Should Be Set  TEST_PASSWORD

    # Finish setting up environment variables
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  DRONE_BUILD_NUMBER
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  DRONE_BUILD_NUMBER  0
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  PUBLIC_NETWORK
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  PUBLIC_NETWORK  'vm-network'
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  TEST_DATASTORE
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  TEST_DATASTORE  vsanDatastore
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  TEST_RESOURCE
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  TEST_RESOURCE  /vcqaDC/host/cls

    Set Test VCH Name

    Set Environment Variable  VCH_USERNAME_ROOT  root
    Set Environment Variable  VCH_PASSWORD_ROOT  e2eFunctionalTest

    Set Environment Variable  GOVC_URL  %{TEST_URL}
    Set Environment Variable  GOVC_USERNAME  %{TEST_USERNAME}
    Set Environment Variable  GOVC_PASSWORD  %{TEST_PASSWORD}
    
    Set Environment Variable  VCH_USERNAME_ROOT  root
    Set Environment Variable  VCH_PASSWORD_ROOT  e2eFunctionalTest

Install VIC Product OVA
    [Arguments]  ${ova-file}
    Set Test Environment Variables
    ${output}=  Run  ovftool --datastore=%{TEST_DATASTORE} --noSSLVerify --acceptAllEulas --name=%{VCH_NAME} --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='%{VCH_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}%{TEST_RESOURCE}'
    Should Contain  ${output}  Completed successfully
    Should Contain  ${output}  Received IP address:
    
    ${output}=  Split To Lines  ${output} 
    :FOR  ${line}  IN  @{output}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${line}  Received IP address:
    \   ${ip}=  Run Keyword If  ${status}  Fetch From Right  ${line}  ${SPACE}
    \   Run Keyword If  ${status}  Set Environment Variable  VCH_IP  ${ip}
    \   Return From Keyword If  ${status}  ${ip}

Cleanup VIC Product OVA
    [Arguments]  ${ova_target_vm_name}
    Set Environment Variable  GOVC_INSECURE  1
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.destroy ${ova_target_vm_name}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Run Keyword And Ignore Error  Run  govc object.destroy /%{TEST_DATASTORE}/vm/${ova_target_vm_name}
    Log To Console  \nVIC Product OVA deployment ${ova_target_vm_name} is cleaned up on test server %{TEST_URL}