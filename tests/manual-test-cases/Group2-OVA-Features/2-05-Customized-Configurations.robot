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
Documentation  Test 2-05 - Customized Configurations
Resource  ../../resources/Util.robot
Suite Setup  Setup VC With Static IP
#Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown  Run Keyword If  '${TEST STATUS}' != 'PASS'  Copy Support Bundle  %{OVA_IP}

*** Variables ***
${dns-nimbus}=  10.170.16.48
${searchpath-nimbus}=  eng.vmware.com
${syslog_srv_host}=  10.158.214.132
${syslog_srv_user}=  vic
${syslog_srv_passowrd}=  Admin!23
${syslog_srv_protocol}=  tcp
${syslog_srv_port}=  514
*** Keywords ***
Setup VC With Static IP
    ${name}=  Evaluate  'vic-2-05-' + str(random.randint(1000,9999))  modules=random
    Nimbus Suite Setup  Create Simple VC Cluster With Static IP  ${name}

*** Test Cases ***
Deploy OVA With Customized Configurations
    Log To Console  \nStarting test...
    
    Set Environment Variable  OVA_NAME  OVA-2-05-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # install ova using static ip, remote syslog server TODO: ntp, proxy
    Install And Initialize VIC Product OVA  vic-*.ova  %{OVA_NAME}  static-ip=&{static}[ip]  netmask=&{static}[netmask]  gateway=&{static}[gateway]  dns=${dns-nimbus}  searchpath=${searchpath-nimbus}  syslog_srv_host=${syslog_srv_host}  syslog_srv_protocol=${syslog_srv_protocol}  syslog_srv_port=${syslog_srv_port}

Verify Network
    # verify network details
    Verify OVA Network Information  %{OVA_IP}  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}  &{static}[ip]  &{static}[prefix]  &{static}[gateway]  ${dns-nimbus}  ${searchpath-nimbus}

#TODO:Verify NTP
#TODO:Verify Proxy

Verify Syslog
    ${syslog-conn}=  Open Connection  ${syslog_srv_host}
    Login  ${syslog_srv_user}  ${syslog_srv_passowrd}
    Wait Until Keyword Succeeds  10x  30s  Execute Command And Return Output  docker-compose -f /etc/vmware/harbor/docker-compose.yml top | grep rsyslogd
    ${out}=  Execute Command  cat /var/log/syslog
    Close Connection
    Log  ${out}
    Should Match Regexp  ${out}  localhost admiral.* https://%{OVA_IP}:8282.*  msg="Log with Admiral tag"
    Should Match Regexp  ${out}  localhost adminserver  msg="Log with Harbor tag"
    Should Match Regexp  ${out}  localhost vic-machine-server  msg="Log with VIC Machine Server tag"
