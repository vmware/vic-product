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
Documentation  This resource provides any keywords related to VIC Product UI Installer
Resource  ../resources/Util.robot

*** Keywords ***
Install UI Plugin
    [Arguments]  ${ova-ip}  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Log To Console  \nInstalling the vic ui plugin...
    ${out}=  Call UI API With Preset  ${ova-ip}  install  H5  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Should Contain  ${out}  204
    ${out}=  Call UI API With Preset  ${ova-ip}  install  FLEX  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Should Contain  ${out}  204

    [Return]  ${out}

Remove UI Plugin
    [Arguments]  ${ova-ip}  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Log To Console  \nInstalling the vic ui plugin...
    ${out}=  Call UI API With Preset  ${ova-ip}  remove  H5  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Should Contain  ${out}  204
    ${out}=  Call UI API With Preset  ${ova-ip}  remove  FLEX  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Should Contain  ${out}  204

    [Return]  ${out}

Upgrade UI Plugin
    [Arguments]  ${ova-ip}  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Log To Console  \nInstalling the vic ui plugin...
    ${out}=  Call UI API With Preset  ${ova-ip}  upgrade  H5  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Should Contain  ${out}  204
    ${out}=  Call UI API With Preset  ${ova-ip}  upgrade  FLEX  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}
    Should Contain  ${out}  204

    [Return]  ${out}

Call UI API With Preset
    [Arguments]  ${ova_ip}  ${action}  ${plugin_preset}  ${vc}=%{TEST_URL}  ${vc_user}=%{TEST_USERNAME}  ${vc_pass}=%{TEST_PASSWORD}  ${vc_thumbprint}=%{TEST_THUMBPRINT}

    :FOR  ${i}  IN RANGE  10
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"vc":{"target":"%{vc}:443","user":"%{vc_user}","password":"%{vc_pass}","thumbprint":"%{vc_thumbprint}"},"plugin":{"preset":"${plugin_preset}"}}' https://${ova_ip}:9443/plugin/${action}
    \   Exit For Loop If  '204' in '''${out}'''
    \   Sleep  10s
    Log To Console  ${rc}
    Log To Console  ${out}

    Execute Command And Return Output  service-control --stop vsphere-ui
    Execute Command And Return Output  service-control --start vsphere-ui
    Execute Command And Return Output  service-control --stop vsphere-client
    Execute Command And Return Output  service-control --start vsphere-client

    [Return]  ${out}

Deploy OVA And Install UI Plugin And Run Regression Tests
    # Deploy OVA and then install UI plugin
    # run regression tests on UI wizard and docker commands on VCH created using UI
    [Arguments]  ${test-name}  ${ova-file}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${have-nested}=${TRUE}
    Log To Console  \nStarting test ${test-name}...
    Set Environment Variable  OVA_NAME  OVA-${test-name}
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # install ova
    Install And Initialize VIC Product OVA  ${ova-file}  %{OVA_NAME}
    # set browser variables
    Set Browser Variables
    # Install VIC Plugin
    Download VIC And Install UI Plugin  %{OVA_IP}
    # create vch using UI
    # retry UI steps if failed
    Wait Until Keyword Succeeds  3x  1m  Create VCH using UI And Set Docker Parameters  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${have-nested}
    # run vch regression tests
    Run Docker Regression Tests For VCH

Download VIC And Install UI Plugin
    [Arguments]  ${ova-ip}
    Open Connection  %{TEST_URL}
    Wait Until Keyword Succeeds  10x  5s  Login  root  vmware

    # extract vic bundle name
    ${download_url}=  Run command and Return output  curl -k https://${ova-ip}:9443 | tac | tac | grep -Po -m 1 '(?<=href=")[^"]*tar.gz'
    Log  ${download_url}
    ${first}  ${rest}=  Split String From Right  ${download_url}  /  1

    Set Global Variable  ${VIC_BUNDLE}  ${rest}
    Execute Command And Return Output  curl -kL https://${ova-ip}:9443/files/${VIC_BUNDLE} -o ${VIC_BUNDLE}
    Execute Command And Return Output  tar -zxf ${VIC_BUNDLE}
    Install UI Plugin  ${ova-ip}
    Close Connection

VIC UI OVA Setup
    [Timeout]    110 minutes
    ${ova-name}=  Get Test OVA Name
    Set Environment Variable  OVA_NAME  ${ova-name}
    Set Environment Variable  DOMAIN              eng.vmware.com
    
    Setup Simple VC And Test Environment
    Global Environment Setup
    
    ${ova-ip}=  Install And Initialize VIC Product OVA  vic-*.ova  %{OVA_NAME}
    Set Environment Variable  OVA_IP  ${ova-ip}
