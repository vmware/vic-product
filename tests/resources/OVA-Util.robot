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

Get VM IP By Name
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.ip  ${vm-name}
    Log  ${output}
    [Return]  ${rc}  ${output}  ${vm-ip}

Set Test OVA IP If Available
    Log To Console  \nCheck VIC appliance and set OVA_IP env variable...
    Set Common Test OVA Name
    ${rc}  ${output}  ${vm-ip}=  Get VM IP By Name  %{OVA_NAME}
    Run Keyword Unless  ${rc} == 0  Should Contain  ${output}  not found
    Run Keyword If  ${rc} == 0  Set Environment Variable  OVA_IP  ${vm-ip}
    [Return]  ${rc}

# This is a secret keyword and does not log information for debugging
# Prefer "Install VIC Product OVA and Wait For Home Page" or
# "Install and Initialize VIC Product OVA" keywords
Install VIC Appliance Secret
    # Requires OVA_PASSWORD_ROOT set as global variable
    [Tags]  secret
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True
    Log To Console  \nInstalling VIC appliance...
    ${output}=  Run Keyword If  ${power} == True  Run  ovftool --datastore=%{TEST_DATASTORE} --noSSLVerify --acceptAllEulas --name=${ova-name} --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --prop:appliance.tls_cert="${tls_cert}" --prop:appliance.tls_cert_key="${tls_cert_key}" --prop:appliance.ca_cert="${ca_cert}" --prop:network.ip0="${static-ip}" --prop:network.netmask0="${netmask}" --prop:network.gateway="${gateway}" --prop:network.DNS="${dns}" --prop:network.searchpath="${searchpath}" --prop:network.fqdn="${fqdn}" --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}%{TEST_RESOURCE}'
    ${output}=  Run Keyword If  ${power} != True  Run  ovftool --datastore=%{TEST_DATASTORE} --noSSLVerify --acceptAllEulas --name=${ova-name} --diskMode=thin --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --prop:appliance.tls_cert="${tls_cert}" --prop:appliance.tls_cert_key="${tls_cert_key}" --prop:appliance.ca_cert="${ca_cert}" --prop:network.ip0="${static-ip}" --prop:network.netmask0="${netmask}" --prop:network.gateway="${gateway}" --prop:network.DNS="${dns}" --prop:network.searchpath="${searchpath}" --prop:network.fqdn="${fqdn}" --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}%{TEST_RESOURCE}'
    [Return]  ${output}

Deploy VIC Appliance
    # Deploy but do not initialize
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True
    ${output}=  Install VIC Appliance Secret  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}  ${static-ip}  ${netmask}  ${gateway}  ${dns}  ${searchpath}  ${fqdn}  ${power}
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
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True
    Deploy VIC Appliance  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}  ${static-ip}  ${netmask}  ${gateway}  ${dns}  ${searchpath}  ${fqdn}  ${power}
    Wait For OVA Home Page  %{OVA_IP}

Install And Initialize VIC Product OVA
    # Deploy OVA and initialize it using API
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True
    Log To Console  \nInstalling VIC appliance
    Deploy VIC Appliance  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}  ${static-ip}  ${netmask}  ${gateway}  ${dns}  ${searchpath}  ${fqdn}  ${power}

Install VIC Product OVA And Initialize Using UI
    # Deploy OVA and initialize it using browser UI
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True
    Log To Console  \nInstalling VIC appliance
    Install VIC Product OVA And Wait For Home Page  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}  ${static-ip}  ${netmask}  ${gateway}  ${dns}  ${searchpath}  ${fqdn}  ${power}

    # Initialize appliance using UI
    Log To Console  Initializing the OVA using the getting started ui...
    Set Browser Variables
    Open Firefox Browser
    Log In And Complete OVA Installation
    Close All Browsers

    # Wait for components to start
    Wait For Online Components  %{OVA_IP}
    Wait For SSO Redirect  %{OVA_IP}

    [Return]  %{OVA_IP}

Install And Initialize Common OVA If Not Already
    [Arguments]  ${ova-file}
    ${rc}=  Set Test OVA IP If Available
    ${ova-ip}=  Run Keyword Unless  ${rc} == 0  Install VIC Product OVA And Initialize Using UI  ${ova-file}  %{OVA_NAME}

Setup And Install Specific OVA Version
    [Arguments]  ${ova-file}  ${ova-name}
    Log To Console  \nSetting OVA variables...
    Set Environment Variable  OVA_NAME  ${ova-name}
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # install OVA appliance
    Log To Console  \nInstall specific version of OVA...
    Install VIC Product OVA And Initialize Using UI  ${ova-file}  ${ova-name}

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

Initialize OVA From API
    [Arguments]  ${ova-ip}
    # check for optional env variables
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  EXTERNAL_PSC
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  EXTERNAL_PSC  ''
    ${status}  ${message}=  Run Keyword And Ignore Error  Environment Variable Should Be Set  PSC_DOMAIN
    Run Keyword If  '${status}' == 'FAIL'  Set Environment Variable  PSC_DOMAIN  ''

    Log To Console  \nInitializing VIC appliance by API when API is available
    :FOR  ${i}  IN RANGE  30
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"target":"%{TEST_URL}:443","user":"%{TEST_USERNAME}","password":"%{TEST_PASSWORD}","externalpsc":"%{EXTERNAL_PSC}","pscdomain":"%{PSC_DOMAIN}"}' https://${ova-ip}:9443/register
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
    # Use "Copy Support Bundle" to copy from appliance to executor
    Log To Console  \nGathering VIC Appliance support bundle
    ${out}=  Execute Command  /etc/vmware/support/appliance-support.sh
    [Return]  ${out}

Get Support Bundle File
    # Use "Copy Support Bundle" to copy from appliance to executor
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

Get OVA Release File For Nightly
    # Get release OVA file from cached dir '/vic-cache' on nightly executer VM
    # OR download it locally if not found
    [Arguments]  ${release-file-name}
    Log To Console  \nLooking for release file ${release-file-name}...
    ${exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  /vic-cache/${release-file-name}
    ${old-ova-save-file}=  Run Keyword If  ${exists}  Set Variable  /vic-cache/${release-file-name}
    Run Keyword If  ${exists}  Log To Console  \nFound release file in /vic-cache
    Return From Keyword If  ${exists}  ${old-ova-save-file}
    # if not exists in cache, then download it after checking locally
    ${old-ova-save-file}=  Set Variable  old-${release-file-name}
    ${exists-local}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${old-ova-save-file}
    Run Keyword If  ${exists-local}  Log To Console  \nRelease file already downloaded so skipping download...
    Run Keyword Unless  ${exists-local}  Log To Console  \nDownloading release file...
    ${output}=  Run Keyword Unless  ${exists-local}  Run command and Return output  wget -nc -O ${old-ova-save-file} https://storage.googleapis.com/vic-product-ova-releases/${release-file-name}
    Run Keyword Unless  ${exists-local}  Log  ${output}
    [Return]  ${old-ova-save-file}

Verify OVA Network Information
    [Arguments]  ${ova-ip}  ${ova-root-user}  ${ova-root-pwd}  ${ip}  ${prefix}  ${gateway}  ${dns}  ${searchpath}
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${ova-root-pwd} ssh -o StrictHostKeyChecking\=no ${ova-root-user}@${ova-ip}
    Log To Console  open connection...
    Open Connection  ${ova-ip}

    Log To Console  login...
    Wait Until Keyword Succeeds  10x  5s  Login  ${ova-root-user}  ${ova-root-pwd}

    Log To Console  verify network details...
    ${output}=  Execute Command And Return Output  cat /etc/systemd/network/09-vic.network
    Should Contain  ${output}  Address=${ip}/${prefix}
    Should Contain  ${output}  Gateway=${gateway}
    Should Contain  ${output}  DNS=${dns}
    Should Contain  ${output}  Domains=${searchpath}

    ${output}=  Execute Command And Return Output  ip addr
    Should Contain  ${output}  inet ${ip}/${prefix}

    ${output}=  Execute Command And Return Output  ip route show
    Should Contain  ${output}  default via ${gateway}
    Should Contain  ${output}  src ${ip}

    ${output}=  Execute Command And Return Output  cat /etc/resolv.conf
    Should Contain  ${output}  nameserver ${dns}
    Should Contain  ${output}  search ${searchpath}

    Close connection

Setup Simple VC And Test Environment
    # set up nimbus test bed and env variables
    [Timeout]    110 minutes
    Run Keyword And Ignore Error  Nimbus Cleanup  ${list}  ${false}
    # setup nimbus testbed
    ${esx1}  ${esx2}  ${vc}  ${esx1-ip}  ${esx2-ip}  ${vc-ip}=  Create a Simple VC Cluster  ha-datacenter  cls  2
    Log To Console  Finished Creating Cluster ${vc}
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  %{NIMBUS_USER}-${vc}
    # set test variables
    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /ha-datacenter/host/cls
    Set Environment Variable  TEST_TIMEOUT  30m
    Set Environment Variable  TEST_DATASTORE  datastore1
    # set VC variables
    Set Test VC Variables
    # set VCH variables
    Set Environment Variable  DRONE_BUILD_NUMBER  0
    Set Environment Variable  VCH_TIMEOUT  20m0s
    # set docker variables
    # not using dind but host dockerd for these nightly tests
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER}  docker
    Set Global Variable  ${DEFAULT_LOCAL_DOCKER_ENDPOINT}  unix:///var/run/docker.sock
    # set harbor variables
    Set Global Variable  ${DEFAULT_HARBOR_PROJECT}  default-project
    # check VC
    Check VCenter

Install VCH With Test Container And Push Image to Harbor
    # download and install a vch
    # create a running busybox container
    Download VIC Engine If Not Already  %{OVA_IP}
    Install VCH And Create Running Busybox Container  %{OVA_IP}
    # tag and push an image to harbor
    ${harbor-image-name}=  Set Variable  %{OVA_IP}/${DEFAULT_HARBOR_PROJECT}/${busybox}
    ${harbor-image-tagged}=  Set Variable  ${harbor-image-name}:${sample-image-tag}
    Pull And Tag Docker Image  ${busybox}  ${harbor-image-tagged}
    Push Docker Image To Harbor Registry  %{OVA_IP}  ${harbor-image-tagged}

Verify Running Test Container And Pushed Image
    [Arguments]  ${cert-path}
    # verify previously created container is migrated and still running
    ${rc}  ${output}=  Run And Return Rc And Output  ${DEFAULT_LOCAL_DOCKER} ${VCH-PARAMS} ps
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  /bin/top
    # verify previously tagged and pushed image is still available
    Pull And Verify Image In Harbor Registry  %{OVA_IP}  ${busybox}  ${sample-image-tag}  ${cert-path}

Auto Upgrade OVA With Verification
    # This is a complete keyword to run auto upgrade process and verify that upgrade is successful
    # This assumes that testbed is already setup
    [Arguments]  ${test-name}  ${old-ova-file-name}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  ${old-ova-datacenter}
    Set Global Variable  ${OVA_CERT_PATH}  ${old-ova-cert-path}
    # get ova file
    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}
    # setup and deploy old version of ova
    Setup And Install Specific OVA Version  ${old-ova-save-file}  ${test-name}
    Install VCH With Test Container And Push Image to Harbor
    # save IP of old ova appliance
    Set Environment Variable  OVA_IP_OLD  %{OVA_IP}

    # install latest OVA appliance and don't initialize
    Log To Console  \nInstall latest version of OVA and auto upgrade...
    Set Environment Variable  OVA_NAME  ${test-name}-LATEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA And Wait For Home Page  vic-*.ova  %{OVA_NAME}

    Execute Upgrade Script  %{OVA_IP}  %{OVA_IP_OLD}  ${old-ova-datacenter}  ${old-ova-version}
    Verify Running Test Container And Pushed Image  ${new-ova-cert-path}

Execute Upgrade Script
    # SSH into OVA appliance and execute ./upgrade script
    # Also, gather and save log bundle
    [Arguments]  ${new-appliance-ip}  ${old-appliance-ip}  ${datacenter}  ${old-appliance-version}
    ${fingerprint}=  Get VCenter GOVC Fingerprint
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${new-appliance-ip}
    Log To Console  open connection...
    Open Connection  ${new-appliance-ip}

    Log To Console  login...
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    # run upgrade script
    Log To Console  upgrade ova...
    Execute Command And Return Output  cd /etc/vmware/upgrade && ./upgrade.sh --target %{TEST_URL} --username %{TEST_USERNAME} --password %{TEST_PASSWORD} --embedded-psc --fingerprint '${fingerprint}' --ssh-insecure-skip-verify --appliance-version ${old-appliance-version} --dc ${datacenter} --appliance-username ${OVA_USERNAME_ROOT} --appliance-password ${OVA_PASSWORD_ROOT} --appliance-target ${old-appliance-ip}

    Copy Support Bundle

Execute Upgrade Script Manual Disk Move
    # Executes the VIC appliance upgrade script using --manual-disks flag
    # Assumes old disks are already attached to the new appliance
    [Arguments]  ${new-appliance-ip}  ${old-appliance-ip}  ${datacenter}  ${old-appliance-version}
    ${fingerprint}=  Get VCenter GOVC Fingerprint
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${new-appliance-ip}
    Log To Console  open connection...
    Open Connection  ${new-appliance-ip}

    Log To Console  login...
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    # run upgrade script
    Log To Console  upgrade ova...
    Execute Command And Return Output  cd /etc/vmware/upgrade && ./upgrade.sh --target %{TEST_URL} --username %{TEST_USERNAME} --password %{TEST_PASSWORD} --embedded-psc --fingerprint '${fingerprint}' --ssh-insecure-skip-verify --appliance-version ${old-appliance-version} --dc ${datacenter} --appliance-username ${OVA_USERNAME_ROOT} --appliance-password ${OVA_PASSWORD_ROOT} --appliance-target ${old-appliance-ip}  --manual-disks

    Copy Support Bundle

Deploy OVA And Install UI Plugin And Run Regression Tests
    # Deploy OVA and then install UI plugin
    # run regression tests on UI wizard and docker commands on VCH created using UI
    [Arguments]  ${test-name}  ${ova-file}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}=1
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
    Wait Until Keyword Succeeds  3x  1m  Create VCH using UI And Set Docker Parameters  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}
    # run vch regression tests
    Run Docker Regression Tests For VCH

# TODO Remove after end of 1.2.1 support
Copy and Attach Disk v1.2.1
    # This powers off the old appliance to copy data disk
    # Blank data disk is detached from the new appliance
    # Copied disk is attached to the new appliance
    [Arguments]  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}
    ${old-ds}=  Get Datastore  ${old-ova-vm-name}
    ${new-ds}=  Get Datastore  ${new-ova-vm-name}

    Wait for VM Power Off  ${old-ova-vm-name}

    # Detach blank disk from new VM
    ${data-disk}=  Get Disk By ID      ${new-ova-vm-name}  1
    Detach Disk    ${new-ova-vm-name}  ${data-disk}

    # Find disk to copy
    ${old-data-disk}=  Get Disk By ID  ${old-ova-vm-name}  1

    # Copy old disk to new datastore location
    Copy Disk  ${old-ds}  ${new-ds}  ${old-data-disk}  ${data-disk}

    # Attach copied disk
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${data-disk}

Copy and Attach Disk
    # This powers off the old appliance to copy disks
    # Blank disks are detached from the new appliance
    # Copied disks are attached to the new appliance
    [Arguments]  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}
    ${old-ds}=  Get Datastore  ${old-ova-vm-name}
    ${new-ds}=  Get Datastore  ${new-ova-vm-name}

    Wait for VM Power Off  ${old-ova-vm-name}

    # Detach blank disks from new VM
    ${data-disk}=  Get Disk By ID      ${new-ova-vm-name}  1
    ${db-disk}=    Get Disk By ID      ${new-ova-vm-name}  2
    ${log-disk}=   Get Disk By ID      ${new-ova-vm-name}  3
    Detach Disk    ${new-ova-vm-name}  ${data-disk}
    Detach Disk    ${new-ova-vm-name}  ${db-disk}
    Detach Disk    ${new-ova-vm-name}  ${log-disk}

    # Find disks to copy
    ${old-data-disk}=  Get Disk By ID  ${old-ova-vm-name}  1
    ${old-db-disk}=    Get Disk By ID  ${old-ova-vm-name}  2
    ${old-log-disk}=   Get Disk By ID  ${old-ova-vm-name}  3

    # Copy old disk to new datastore location
    Copy Disk  ${old-ds}  ${new-ds}  ${old-data-disk}  ${data-disk}
    Copy Disk  ${old-ds}  ${new-ds}  ${old-db-disk}  ${db-disk}
    Copy Disk  ${old-ds}  ${new-ds}  ${old-log-disk}  ${log-disk}

    # Attach copied disks
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${data-disk}
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${db-disk}
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${log-disk}

Get Datastore
    # Get datastore containing a VM
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.info -json "${vm-name}" | jq -r ".VirtualMachines[].Config.DatastoreUrl[0].Name"
    Log  ${output}
    Should Be Equal  ${rc}  0
    [Return]  ${output}

Get Disk By ID
    # Get disk from VM based on it's position
    [Arguments] ${vm-name}  ${id}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.info -json "${vm-name}" | jq -r ".VirtualMachines[].Layout.Disk[${id}].DiskFile[0]" | awk '{print $NF}'
    Log  ${output}
    Should Be Equal  ${rc}  0
    [Return]  ${output}

Detach Disk
    # Detach disk from VM
    [Arguments]  ${vm-name}  ${disk}
    ${rc}  ${output}=  Run And Return Rc And Output  govc device.remove -vm="${vm-name}" "${disk}"
    Log ${output}
    Should Be Equal  ${rc}  0
    [Return]  ${output}

Attach Disk
    # Attach disk to VM
    [Arguments]  ${vm-name}  ${datastore}  ${disk}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.disk.attach -vm="$vm-name" -ds "${datastore}" -disk "${disk}"
    Log ${output}
    Should Be Equal  ${rc}  0
    [Return]  ${output}


Copy Disk
    [Arguments]  ${old-datastore}  ${new-datastore}  ${old-disk}  ${new-disk}
    ${rc}  ${output}=  Run And Return Rc And Output  govc datastore.cp -ds "${old-datastore}" -ds-target "${new-datastore}" "${old-disk}" "${new-disk}"
    Log ${output}
    Should Be Equal  ${rc}  0
    [Return]  ${output}

Power On VM
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.power -on=true "${vm-name}"
    Log ${output}
    Should Be Equal  ${rc}  0
    [Return]  ${output}

Wait for VM Power Off
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.power -s=true "${vm-name}"
    Log  ${output}
    Log  ${rc}
    Should Be Equal  ${rc}  0

		Wait Until Keyword Succeeds  12x  15s  VM Is Powered Off  "${vm-name}"

VM Is Powered Off
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.info -json "${vm-name}" | jq -r ".VirtualMachines[].Runtime.PowerState"
    Log  ${output}
    Log  ${rc}
    Should Contain  ${output}  "poweredOff"
