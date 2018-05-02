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
Documentation  Test 6-01 - OVA TLS
Resource  ../../resources/Util.robot
Suite Setup     Wait Until Keyword Succeeds  10x  10m  Test Environment Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown   Cleanup VIC Product OVA  %{OVA_NAME}

*** Variables ***
${esx_number}=  3
${datacenter}=  ha-datacenter

*** Keywords ***
Test Environment Setup
    [Timeout]    110 minutes
    Setup Simple VC And Test Environment
    Set Environment Variable  DOMAIN              eng.vmware.com

*** Test Cases ***

User Provided Certificate
    Log To Console  \nStarting user provided certificate test...
    ${ova-name}=  Get Test OVA Name
    Set Environment Variable  OVA_NAME  ${ova-name}
    Global Environment Setup

    # Generate CA and wildcard cert for *.<DOMAIN>
    Cleanup Generated Certificate
    Log  Generating certificates for %{DOMAIN}
    Generate Certificate Authority
    Generate Wildcard Server Certificate

    ${tls_cert}=      Get Server Certificate  "*.%{DOMAIN}".cert.pem
    ${tls_cert_key}=  Get Server Key  "*.%{DOMAIN}".key.pem
    ${ca_cert}=       Get Certificate Authority CRT

    Log  ${tls_cert}
    Log  ${tls_cert_key}
    Log  ${ca_cert}

    ${ova-ip}=  Install VIC Product OVA And Initialize Using UI  vic-*.ova  %{OVA_NAME}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}

    Wait Until Keyword Succeeds  10x  15s  Verify VIC Appliance TLS Certificates  ${ova-ip}  issuer=/C=US/ST=California/L=Los Angeles/O=Stark Enterprises/OU=Stark Enterprises Certificate Authority/CN=Stark Enterprises Global CA
    Cleanup Generated Certificate


User Provided Certificate PKCS8
    Log To Console  \nStarting user provided certificate test...
    ${ova-name}=  Get Test OVA Name
    Set Environment Variable  OVA_NAME  ${ova-name}
    Global Environment Setup

    # Generate CA and wildcard cert for *.<DOMAIN>
    Cleanup Generated Certificate
    Log  Generating certificates for %{DOMAIN}
    Generate Certificate Authority
    Generate Wildcard Server Certificate

    ${tls_cert}=      Get Server Certificate  "*.%{DOMAIN}".cert.pem
    ${tls_cert_key}=  Get Server Key  "*.%{DOMAIN}".key.pem
    ${ca_cert}=       Get Certificate Authority CRT

    Log  ${tls_cert}
    Log  ${tls_cert_key}
    Log  ${ca_cert}

    ${ova-ip}=  Install VIC Product OVA And Initialize Using UI  vic-*.ova  %{OVA_NAME}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}

    Wait Until Keyword Succeeds  10x  15s  Verify VIC Appliance TLS Certificates  ${ova-ip}  issuer=/C=US/ST=California/L=Los Angeles/O=Stark Enterprises/OU=Stark Enterprises Certificate Authority/CN=Stark Enterprises Global CA
    Cleanup Generated Certificate
