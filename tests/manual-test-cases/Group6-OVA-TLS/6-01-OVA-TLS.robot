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
Suite Setup     Wait Until Keyword Succeeds  10x  10m  OVA Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown   Cleanup VIC Product OVA  %{OVA_NAME}

*** Variables ***
${esx_number}=  3
${datacenter}=  ha-datacenter

*** Keywords ***
OVA Setup
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}

    ${latest-ova}=  Download Latest VIC Appliance OVA
    Set Environment Variable  LATEST_OVA  ${latest-ova}

    ${esx1}  ${esx2}  ${esx3}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${esx3-ip}  ${vc-ip}=  Create a Simple VC Cluster
    Log To Console  Finished Creating Cluster ${vc}
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  ${esx3}  %{NIMBUS_USER}-${vc}

    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /ha-datacenter/host/cls
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  TEST_DATASTORE  datastore1

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

    ${ova-ip}=  Install VIC Product OVA And Initialize Using UI  %{LATEST_OVA}  %{OVA_NAME}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}

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

    ${ova-ip}=  Install VIC Product OVA And Initialize Using UI  %{LATEST_OVA}  %{OVA_NAME}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}

    Wait Until Keyword Succeeds  10x  15s  Verify VIC Appliance TLS Certificates  ${ova-ip}  issuer=/C=US/ST=California/L=Los Angeles/O=Stark Enterprises/OU=Stark Enterprises Certificate Authority/CN=Stark Enterprises Global CA
    Cleanup Generated Certificate
