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
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
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

Generate CA
    ${rc}  ${out}=  Run And Return Rc And Output  openssl req -newkey rsa:1024 -nodes -sha256 -keyout ca.key -x509 -days 825 -out ca.crt -subj "/C=US/ST=CA/L=PA/O=VMW/OU=VIC/CN=Testing"
    Log  ${rc}
    Log  ${out}
    Should Be Equal As Integers  ${rc}  0
    ${ca}=  OperatingSystem.Get File  ca.crt
    # format ca.crt follow HTML5 pattern
    ${ca}=  Replace String  ${ca}  \n  ${SPACE}
    Set Suite Variable  ${ca}  ${ca}

Generate OVA Certs
    [Arguments]  ${ip}
    ${rc}  ${out}=  Run And Return Rc And Output  openssl req -newkey rsa:1024 -nodes -keyout ova.key -subj "/C=US/ST=CA/L=PA/O=VMW/CN=*.eng.vmware.com" -out ova.csr
    Log  ${rc}
    Log  ${out}
    Should Be Equal As Integers  ${rc}  0
    ${key}=  OperatingSystem.Get File  ova.key
    Log  ${key}
    # format ova.key follow HTML5 pattern
    ${key}=  Replace String  ${key}  \n  ${SPACE}
    Log  ${key}
    Set Suite Variable  ${key}  ${key}

    Create File  ext.conf  subjectAltName=IP:${ip}"
    ${rc}  ${out}=  Run And Return Rc And Output  openssl x509 -req -days 825 -in ova.csr -CA ca.crt -CAkey ca.key -CAcreateserial -extfile ext.conf -out ova.crt
    Log  ${rc}
    Log  ${out}
    Should Be Equal As Integers  ${rc}  0  
    ${rc}  ${out}=  Run And Return Rc And Output  openssl x509 -in ova.crt -noout -text
    Log  ${out}
    ${certs}=  OperatingSystem.Get File  ova.crt
    Log  ${certs}
    # format ova.crt follow HTML5 pattern
    ${certs}=  Replace String  ${certs}  \n  ${SPACE}
    Log  ${certs}
    Set Suite Variable  ${certs}  ${certs}

*** Test Cases ***
Generate CA and Certs
    Generate CA
    Generate OVA Certs  &{static}[ip]  

Deploy OVA With Customized Configurations
    Log To Console  \nStarting test...
    
    Set Environment Variable  OVA_NAME  OVA-2-05-TEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    
    # install ova using static ip, remote syslog server TODO: ntp, proxy
    Install And Initialize VIC Product OVA  vic-*.ova  %{OVA_NAME}  ${certs}  ${key}  ${ca}  static-ip=&{static}[ip]  netmask=&{static}[netmask]  gateway=&{static}[gateway]  dns=${dns-nimbus}  searchpath=${searchpath-nimbus}  syslog_srv_host=${syslog_srv_host}  syslog_srv_protocol=${syslog_srv_protocol}  syslog_srv_port=${syslog_srv_port}
    
Verify Network
    # verify network details
    Verify OVA Network Information  %{OVA_IP}  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}  &{static}[ip]  &{static}[prefix]  &{static}[gateway]  ${dns-nimbus}  ${searchpath-nimbus}

#TODO:Verify NTP
#TODO:Verify Proxy

Verify Syslog
    Log To Console  Check harbor is up
    Open Connection  %{OVA_IP}
    Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}
    Wait Until Keyword Succeeds  10x  30s  Execute Command And Return Output  docker-compose -f /etc/vmware/harbor/docker-compose.yml top | grep rsyslogd
    Close Connection
    Log To Console  Get syslog
    Open Connection  ${syslog_srv_host}
    Login  ${syslog_srv_user}  ${syslog_srv_passowrd}
    ${out}=  Execute Command  cat /var/log/syslog
    Close Connection
    Log  ${out}
    Should Match Regexp  ${out}  localhost admiral.* https://%{OVA_IP}:8282.*  msg="Log with Admiral tag"
    Should Match Regexp  ${out}  localhost adminserver  msg="Log with Harbor tag"
    Should Match Regexp  ${out}  localhost vic-machine-server  msg="Log with VIC Machine Server tag"

Verify Custom Certs
    Wait Until Keyword Succeeds  10x  15s  Verify VIC Appliance TLS Certificates  %{OVA_IP}  issuer=/C=US/ST=CA/L=PA/O=VMW/OU=VIC/CN=Testing
    Set Global Variable  ${OVA_CERT_PATH}  /storage/data/harbor/ca_download
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER}  docker
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER_ENDPOINT}  unix:///var/run/docker.sock
    Setup CA Cert for Harbor Registry  %{OVA_IP}
    Wait Until Keyword Succeeds  12x  5s  Docker Login To Harbor Registry  %{OVA_IP}