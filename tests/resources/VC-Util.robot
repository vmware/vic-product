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
Documentation  This resource contains any keywords dealing with operations being performed on a Vsphere instance, mostly govc wrappers

*** Keywords ***
Check VCenter
    Log To Console  \nChecking vCenter availability...
    ${rc}  ${output}=  Run And Return Rc And Output  govc about -u=%{TEST_URL}
    Log To Console  ${output}
    Should Be Equal As Integers  ${rc}  0  vCenter %{TEST_URL} seems unavailable
    Should Contain  ${output}  VMware vCenter Server

Get VCenter Thumbprint
    [Tags]  secret
    ${rc}  ${thumbprint}=  Run And Return Rc And Output  openssl s_client -connect %{TEST_URL}:443 </dev/null 2>/dev/null | openssl x509 -fingerprint -noout | cut -d= -f2
    Should Be Equal As Integers  ${rc}  0
    [Return]  ${thumbprint}

Set Test VC Variables
    [Tags]  secret
    ${thumbprint}=  Get VCenter Thumbprint
    Set Global Variable  ${TEST_THUMBPRINT}  ${thumbprint}

Check Delete Success
    [Arguments]  ${name}
    ${out}=  Run  govc ls vm
    Log  ${out}
    Should Not Contain  ${out}  ${name}
    ${out}=  Run  govc datastore.ls
    Log  ${out}
    Should Not Contain  ${out}  ${name}
    ${out}=  Run  govc ls host/*/Resources/*
    Log  ${out}
    Should Not Contain  ${out}  ${name}

Run GOVC
    [Arguments]  ${cmd_options}
    ${rc}  ${output}=  Run And Return Rc And Output  govc ${cmd_options}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    [Return]  ${rc}