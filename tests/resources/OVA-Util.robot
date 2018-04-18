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

*** Variables ***
${busybox}=  busybox
${sample-image-tag}=  test

*** Keywords ***
Set Common Test OVA Name
    ${name}=  Evaluate  'OVA-%{DRONE_BUILD_NUMBER}'
    Set Environment Variable  OVA_NAME  ${name}

Get Test OVA Name
    ${name}=  Evaluate  'OVA-%{DRONE_BUILD_NUMBER}-' + str(random.randint(1000,9999))  modules=random
    [Return]  ${name}

Download Latest VIC Appliance OVA
    ${latest-ova}=  Run  gsutil ls -l gs://vic-product-ova-builds/ | grep -v TOTAL | sort -k2r | (head -n1 ; dd of=/dev/null 2>&1 /dev/null) | xargs | cut -d ' ' -f 3 | cut -d '/' -f 4
    Log To Console  \nStart downloading ${latest-ova}...
    # ${pid1}=  Start Process  wget https://storage.googleapis.com/vic-product-ova-builds/${latest-ova}  shell=True
    ${pid1}=  Start Process  gsutil cp gs://vic-product-ova-builds/${latest-ova} .  shell=True
    ${ret}=  Wait For Process  ${pid1}
    ${output}=  Run  ls -alh
    Log  ${output}
    Log  ${ret.stdout}
    Log  ${ret.stderr}
    Log To Console  \nFinished downloading ${latest-ova}
    [Return]  ${latest-ova}

Set Test OVA IP If Available
    Log To Console  \nCheck VIC appliance and set OVA_IP env variable...
    Set Common Test OVA Name
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.ip %{OVA_NAME}
    Run Keyword Unless  ${rc} == 0  Should Contain  ${output}  not found
    Run Keyword If  ${rc} == 0  Set Environment Variable  OVA_IP  ${output}
    [Return]  ${rc}

# This is a secret keyword and does not log information for debugging
# Prefer "Install VIC Product OVA" keyword for deploying
Install VIC Product OVA Only
    # Deploy OVA but do not initialize
    [Tags]  secret
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}
    Log To Console  \nInstalling VIC appliance...
    ${output}=  Run  ovftool --datastore=%{TEST_DATASTORE} --noSSLVerify --acceptAllEulas --name=${ova-name} --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --prop:appliance.tls_cert="${tls_cert}" --prop:appliance.tls_cert_key="${tls_cert_key}" --prop:appliance.ca_cert="${ca_cert}" --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}%{TEST_RESOURCE}'
    Log  ${output}
    Should Contain  ${output}  Completed successfully
    Should Contain  ${output}  Received IP address:

    ${output}=  Split To Lines  ${output}
    ${ova-ip}=  Set Variable  NULL
    :FOR  ${line}  IN  @{output}
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${line}  Received IP address:
    \   ${ip}=  Run Keyword If  ${status}  Fetch From Right  ${line}  ${SPACE}
    \   ${ova-ip}=  Run Keyword If  ${status}  Set Variable  ${ip}  ELSE  Set Variable  ${ova-ip}

    Log  ${ova-ip}
    Set Environment Variable  OVA_IP  ${ova-ip}
    [Return]  ${output}

Install VIC Product OVA And Wait For Home Page
    # Deploy OVA but do not initialize and wait for home page to come up
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}
    Install VIC Product OVA Only  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}
    Wait For OVA Home Page  %{OVA_IP}

Install And Initialize VIC Product OVA
    # Deploy OVA and initialize it without using browser UI
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}
    Log To Console  \nInstalling VIC appliance and validating services...
    Install VIC Product OVA Only  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}
    # initialize ova
    Initialize OVA And Wait For Register Page  %{OVA_IP}

Install VIC Product OVA And Initialize Using UI
    # Deploy OVA and initialize it using browser UI
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}
    Log To Console  \nInstalling VIC appliance and validating services...
    Install VIC Product OVA Only  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}
    # initialize ova
    Initialize OVA And Wait For Register Page  %{OVA_IP}
    # set env var for ova ip
    Wait For Online Components  %{OVA_IP}

    # validate complete installation on UI
    Log To Console  Initializing the OVA using the getting started ui...
    Set Browser Variables
    Open Firefox Browser
    Log In And Complete OVA Installation
    Close All Browsers

    # wait for component services to get started
    Wait For Online Components  %{OVA_IP}
    Wait For SSO Redirect  %{OVA_IP}

    [Return]  %{OVA_IP}

Install And Initialize Common OVA If Not Already
    [Arguments]  ${ova-file}
    ${rc}=  Set Test OVA IP If Available
    ${ova-ip}=  Run Keyword Unless  ${rc} == 0  Install VIC Product OVA And Initialize Using UI  ${ova-file}  %{OVA_NAME}

Setup And Install Specific OVA Version
    [Arguments]  ${ova-name}  ${ova-file}
    Log To Console  \nSetting OVA variables...
    Set Environment Variable  OVA_NAME  ${ova-name}
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # install OVA appliance
    Log To Console  \nInstall specific version of OVA...
    Install VIC Product OVA And Initialize Using UI  ${ova-file}  %{OVA_NAME}

Download VIC Engine
    [Arguments]  ${ova-ip}  ${target_dir}=bin
    Log To Console  \nDownloading VIC engine...
    ${download_url}=  Run command and Return output  curl -k https://${ova-ip}:9443 | tac | tac | grep -Po -m 1 '(?<=href=")[^"]*tar.gz'
    Run command and Return output  mkdir -p ${target_dir}
    Run command and Return output  curl -k ${download_url} --output ${target_dir}/vic.tar.gz
    Run command and Return output  tar -xvzf ${target_dir}/vic.tar.gz --strip-components=1 --directory=${target_dir}

Download VIC Engine If Not Already
    [Arguments]  ${ova-ip}  ${target_dir}=bin
    ${status}=  Run Keyword And Return Status  Directory Should Not Be Empty  ${target_dir}
    Run Keyword Unless  ${status}  Download VIC engine  ${ova-ip}  ${target_dir}

Cleanup VIC Product OVA
    [Arguments]  ${ova_target_vm_name}
    Log To Console  \nCleaning up VIC appliance...
    ${rc}=  Wait Until Keyword Succeeds  10x  5s  Run GOVC  vm.destroy ${ova_target_vm_name}
    Run Keyword And Ignore Error  Run GOVC  datastore.rm /%{TEST_DATASTORE}/vm/${ova_target_vm_name}
    Run Keyword if  ${rc}==0  Log To Console  \nVIC Product OVA deployment ${ova_target_vm_name} is cleaned up on test server %{TEST_URL}

Initialize OVA And Wait For Register Page
    [Arguments]  ${ova-ip}
    Log To Console  \nInitializing and Waiting for Getting Started Page to Come Up...
    :FOR  ${i}  IN RANGE  30
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"target":"%{TEST_URL}:443","user":"%{TEST_USERNAME}","password":"%{TEST_PASSWORD}"}' https://${ova-ip}:9443/register
    \   Exit For Loop If  '200' in '''${out}'''
    \   Sleep  60s
    Log To Console  ${rc}
    Log To Console  ${out}
    Should Contain  ${out}  200

Wait For OVA Home Page
    [Arguments]  ${ova-ip}
    Log To Console  \nWaiting for OVA Home Page to Come Up...
    :FOR  ${i}  IN RANGE  30
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -s -o /dev/null -w "\%{http_code}\\n" https://${ova-ip}:9443
    \   Exit For Loop If  '200' in '''${out}'''
    \   Sleep  60s
    Log  ${rc}
    Log  ${out}
    Should Contain  ${out}  200

Wait For Online Components
    [Arguments]  ${ova-ip}
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${ova-ip}
    Log To Console  open connection...
    Open Connection  ${ova-ip}

    Log To Console  login...
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    Log To Console  check service...
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

Verify VIC Appliance TLS Certificates
    # Verify that services are using the provided TLS certificate
    # Match based on {validate-string} from openssl output
    [Arguments]  ${ova-ip}  ${validate-string}
    # Verify that the supplied certificate is presented on web interface
    ${output}=  Get Remote Certificate  ${ova-ip}:9443
    Should Contain  ${output}  ${validate-string}

    # Verify that the supplied certificate is presented on the Admiral interface
    ${output}=  Get Remote Certificate  ${ova-ip}:8282
    Should Contain  ${output}  ${validate-string}

    # Verify that the supplied certificate is presented on the VIC Machine API interface
    ${output}=  Get Remote Certificate  ${ova-ip}:8443
    Should Contain  ${output}  ${validate-string}

    # Verify that the supplied certificate is presented on the Harbor interface
    ${output}=  Get Remote Certificate  ${ova-ip}:443
    Should Contain  ${output}  ${validate-string}

Execute Upgrade Script
    # SSH into OVA appliance and execute ./upgrade script
    # Also, gather and save log bundle
    [Arguments]  ${ova-ip}  ${ova-ip-old}  ${datacenter-old}  ${version-old}
    ${fingerprint}=  Get VCenter GOVC Fingerprint
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${ova-ip}
    Log To Console  open connection...
    Open Connection  ${ova-ip}

    Log To Console  login...
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    # run upgrade script
    Log To Console  upgrade ova...
    Execute Command And Return Output  cd /etc/vmware/upgrade && ./upgrade.sh --target %{TEST_URL} --username %{TEST_USERNAME} --password %{TEST_PASSWORD} --embedded-psc --fingerprint '${fingerprint}' --ssh-insecure-skip-verify --appliance-version ${version-old} --dc ${datacenter-old} --appliance-username ${OVA_USERNAME_ROOT} --appliance-password ${OVA_PASSWORD_ROOT} --appliance-target ${ova-ip-old}

    # get support bundle file
    ${output}=  Gather Support Bundle
    Should Contain  ${output}  Created log bundle
    ${file}=  Get Support Bundle File  ${output}

    Close Connection

    # copy log bundle
    ${output}=  Run command and Return output  sshpass -p ${OVA_PASSWORD_ROOT} scp -o StrictHostKeyChecking\=no -o UserKnownHostsFile=/dev/null ${OVA_USERNAME_ROOT}@${ova-ip}:${file} .

OVA Upgrade Test Setup
    # This is a test setup keyword for auto upgrade tests,
    # which will download previous version of OVA and setup test bed in Nimbus
    [Arguments]  ${old-ova-file-name}  ${old-ova-save-file}  ${datacenter}
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    # start downloading ova file
    Log To Console  \nStart downloading ${old-ova-file-name}...
    ${pid1}=  Start Process  wget -nc -o ${old-ova-save-file} https://storage.googleapis.com/vic-product-ova-releases/${old-ova-file-name}  shell=True
    # setup nimbus testbed
    ${esx1}  ${esx2}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${vc-ip}=  Create a Simple VC Cluster  ${ha-datacenter}  ${cluster}  ${esx_number}
    Log To Console  Finished Creating Cluster ${vc}
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  %{NIMBUS_USER}-${vc}
    # set test variables
    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /${datacenter}/host/cls
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  TEST_DATASTORE  datastore1
    # wait for ova file download
    ${ret}=  Wait For Process  ${pid1}
    # set VC variables
    Set Test VC Variables
    # set OVA variables
    Set Global Variable  ${OVA_CERT_PATH}  ${old-ova-cert-path}
    # set VCH variables
    Set Environment Variable  DRONE_BUILD_NUMBER  0
    Set Environment Variable  VCH_TIMEOUT  20m0s
    # set docker variables
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER}  DOCKER_API_VERSION=1.23 docker
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER_ENDPOINT}  unix:///var/run/docker-local.sock
    # set harbor variables
    Set Global Variable  ${DEFAULT_HARBOR_PROJECT}  default-project
    # check VC
    Check VCenter

Auto Upgrade OVA With Verification
    # This is a complete keyword to run auto upgrade process and verify that upgrade is successful
    # This assumes that testbed and OVA files are already setup
    [Arguments]  ${test-name}  ${old-ova-file}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  ${old-ova-datacenter}
    # setup and deploy old version of ova
    Setup And Install Specific OVA Version  ${test-name}  ${old-ova-file}
    # download and install a vch
    # create a running busybox container
    Download VIC Engine If Not Already  %{OVA_IP}
    Install VCH And Create Running Busybox Container  %{OVA_IP}
    # tag and push an image to harbor
    Setup Docker Daemon
    ${harbor-image-name}=  Set Variable  %{OVA_IP}/${DEFAULT_HARBOR_PROJECT}/${busybox}
    ${harbor-image-tagged}=  Set Variable  ${harbor-image-name}:${sample-image-tag}
    Pull And Tag Docker Image  ${busybox}  ${harbor-image-tagged}
    Push Docker Image To Harbor Registry  %{OVA_IP}  ${harbor-image-tagged}
    # save IP of old ova appliance
    Set Environment Variable  OVA_IP_OLD  %{OVA_IP}
    # install latest OVA appliance and don't initialize
    Log To Console  \nInstall latest version of OVA and auto upgrade...
    Set Environment Variable  OVA_NAME  ${test-name}-LATEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA And Wait For Home Page  vic-*.ova  %{OVA_NAME}
    # run upgrade script
    Execute Upgrade Script  %{OVA_IP}  %{OVA_IP_OLD}  ${old-ova-datacenter}  ${old-ova-version}
    # verify previously created container is migrated and still running
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  /bin/top
    # verify previously tagged and pushed image is still available
    Pull And Verify Image In Harbor Registry  %{OVA_IP}  ${busybox}  ${sample-image-tag}  ${new-ova-cert-path}
