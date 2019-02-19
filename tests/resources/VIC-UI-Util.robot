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

*** Variables ***
${ok}=  204
${html5}=  H5
${fail}=  FAIL

*** Keywords ***
Install UI Plugin
    [Arguments]  ${ova-ip}  ${plugin_preset}  ${vc}=%{TEST_URL}  ${vc_user}=%{TEST_USERNAME}  ${vc_pass}=%{TEST_PASSWORD}  ${vc_thumbprint}=${TEST_THUMBPRINT}  ${vic_password}=${OVA_PASSWORD_ROOT}
    Log To Console  \nInstalling the vic ui plugin...
    ${status}=  Call UI API With Preset  ${ova-ip}  install  ${plugin_preset}  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}  ${vic_password}
    Should Be Equal As Integers  ${status}  ${ok}

    [Return]  ${status}

Remove UI Plugin
    [Arguments]  ${ova-ip}  ${plugin_preset}  ${vc}=%{TEST_URL}  ${vc_user}=%{TEST_USERNAME}  ${vc_pass}=%{TEST_PASSWORD}  ${vc_thumbprint}=${TEST_THUMBPRINT}  ${vic_password}=${OVA_PASSWORD_ROOT}
    Log To Console  \nUninstalling the vic ui plugin...
    ${status}=  Call UI API With Preset  ${ova-ip}  remove  ${plugin_preset}  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}  ${vic_password}
    Should Be Equal As Integers  ${status}  ${ok}

    [Return]  ${status}

Upgrade UI Plugin
    [Arguments]  ${ova-ip}  ${plugin_preset}  ${vc}=%{TEST_URL}  ${vc_user}=%{TEST_USERNAME}  ${vc_pass}=%{TEST_PASSWORD}  ${vc_thumbprint}=${TEST_THUMBPRINT}  ${vic_password}=${OVA_PASSWORD_ROOT}
    Log To Console  \nUpgrading the vic ui plugin...
    ${status}=  Call UI API With Preset  ${ova-ip}  upgrade  ${plugin_preset}  ${vc}  ${vc_user}  ${vc_pass}  ${vc_thumbprint}  ${vic_password}
    Should Be Equal As Integers  ${status}  ${ok}

    [Return]  ${status}

Call UI API With Preset
    [Arguments]  ${ova_ip}  ${action}  ${plugin_preset}  ${vc}=%{TEST_URL}  ${vc_user}=%{TEST_USERNAME}  ${vc_pass}=%{TEST_PASSWORD}  ${vc_thumbprint}=${TEST_THUMBPRINT}  ${vic_password}=${OVA_PASSWORD_ROOT}

    :FOR  ${i}  IN RANGE  10
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"vc":{"target":"${vc}:443","user":"${vc_user}","password":"${vc_pass}","thumbprint":"${vc_thumbprint}"},"appliance":{"vicpassword":"${vic_password}"},"plugin":{"preset":"${plugin_preset}"}}' https://${ova_ip}:9443/plugin/${action}
    \   ${out}  ${status}=  Split String From Right  ${out}  \n  1
    \   Exit For Loop If  '${ok}' == '${status}'
    \   Sleep  10s
    Log To Console  ${rc}
    Log To Console  ${out}

    [Return]  ${status}

Download VIC And Install UI Plugin
    [Arguments]  ${ova-ip}
    Install UI Plugin  ${ova-ip}  ${html5}

    Open Connection  %{TEST_URL}
    Wait Until Keyword Succeeds  10x  5s  Login  root  vmware
    # check vic bundle exists
    ${download_url}=  Run command and Return output  curl -k https://${ova-ip}:9443 | grep -Po -m 1 '(?<=href=")[^"]*tar.gz'
    Log  ${download_url}
    #restart service to make registration sucessful for next steps
    Execute Command And Return Output  service-control --stop vsphere-ui
    Execute Command And Return Output  service-control --start vsphere-ui
    Execute Command And Return Output  service-control --stop vsphere-client
    Execute Command And Return Output  service-control --start vsphere-client
    Close Connection

VIC UI OVA Setup
    [Timeout]    110 minutes
    Set Environment Variable  DRONE_BUILD_NUMBER  0
    ${ova-name}=  Get Test OVA Name
    Set Environment Variable  OVA_NAME  ${ova-name}
    Set Environment Variable  DOMAIN              eng.vmware.com
    
    Setup Simple VC And Test Environment
    Global Environment Setup
    Set Test VC Variables
    
    ${ova-ip}=  Install And Initialize VIC Product OVA  ${local_ova_file}  %{OVA_NAME}
    Set Environment Variable  OVA_IP  ${ova-ip}
