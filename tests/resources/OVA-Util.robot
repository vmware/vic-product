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
    ${rc}  ${output}=  Get VM IP By Name  %{OVA_NAME}
    Run Keyword Unless  ${rc} == 0  Should Contain  ${output}  not found
    Run Keyword If  ${rc} == 0  Set Environment Variable  OVA_IP  ${output}
    [Return]  ${rc}

# This is a secret keyword and does not log information for debugging
# Prefer "Install VIC Product OVA and Wait For Home Page" or
# "Install and Initialize VIC Product OVA" keywords
Install VIC Appliance Secret
    # Requires OVA_PASSWORD_ROOT set as global variable
    [Tags]  secret
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True  ${syslog_srv_ip}=${EMPTY}  ${syslog_srv_protocol}=${EMPTY}  ${syslog_srv_port}=${EMPTY}
    Log To Console  \nInstalling VIC appliance...
    ${output}=  Run Keyword If  ${power}  Run  ovftool --datastore='%{TEST_DATASTORE}' --noSSLVerify --acceptAllEulas --name=${ova-name} --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --prop:appliance.tls_cert="${tls_cert}" --prop:appliance.tls_cert_key="${tls_cert_key}" --prop:appliance.ca_cert="${ca_cert}" --prop:network.ip0="${static-ip}" --prop:network.netmask0="${netmask}" --prop:network.gateway="${gateway}" --prop:network.DNS="${dns}" --prop:network.searchpath="${searchpath}" --prop:network.fqdn="${fqdn}" --prop:syslog_server.syslog_srv_ip="${syslog_srv_ip}" --prop:syslog_server.syslog_srv_protocol="${syslog_srv_protocol}" --prop:syslog_server.syslog_srv_port="${syslog_srv_port}" --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}/%{TEST_RESOURCE}'
    Return From Keyword If  ${power}  ${output}  # Preserve output and return

    ${output}=  Run Keyword Unless  ${power}  Run  ovftool --datastore='%{TEST_DATASTORE}' --noSSLVerify --acceptAllEulas --name=${ova-name} --diskMode=thin --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}' --prop:appliance.permit_root_login=True --prop:appliance.tls_cert="${tls_cert}" --prop:appliance.tls_cert_key="${tls_cert_key}" --prop:appliance.ca_cert="${ca_cert}" --prop:network.ip0="${static-ip}" --prop:network.netmask0="${netmask}" --prop:network.gateway="${gateway}" --prop:network.DNS="${dns}" --prop:network.searchpath="${searchpath}" --prop:network.fqdn="${fqdn}" --prop:syslog_server.syslog_srv_ip="${syslog_srv_ip}" --prop:syslog_server.syslog_srv_protocol="${syslog_srv_protocol}" --prop:syslog_server.syslog_srv_port="${syslog_srv_port}" --net:"Network"="%{PUBLIC_NETWORK}" ${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}/%{TEST_RESOURCE}'
    [Return]  ${output}

Deploy VIC Appliance
    # Deploy but do not initialize
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True  ${syslog_srv_ip}=${EMPTY}  ${syslog_srv_protocol}=${EMPTY}  ${syslog_srv_port}=${EMPTY}
    ${output}=  Install VIC Appliance Secret  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}  ${static-ip}  ${netmask}  ${gateway}  ${dns}  ${searchpath}  ${fqdn}  ${power}  ${syslog_srv_ip}  ${syslog_srv_protocol}  ${syslog_srv_port}
    Log  ${output}
    Should Contain  ${output}  Completed successfully
    Run Keyword If  ${power}  Should Contain  ${output}  Received IP address:

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
    [Arguments]  ${ova-file}  ${ova-name}  ${tls_cert}=${EMPTY}  ${tls_cert_key}=${EMPTY}  ${ca_cert}=${EMPTY}  ${static-ip}=${EMPTY}  ${netmask}=${EMPTY}  ${gateway}=${EMPTY}  ${dns}=${EMPTY}  ${searchpath}=${EMPTY}  ${fqdn}=${EMPTY}  ${power}=True  ${syslog_srv_ip}=${EMPTY}  ${syslog_srv_protocol}=${EMPTY}  ${syslog_srv_port}=${EMPTY}
    Log To Console  \nInstalling VIC appliance
    Deploy VIC Appliance  ${ova-file}  ${ova-name}  ${tls_cert}  ${tls_cert_key}  ${ca_cert}  ${static-ip}  ${netmask}  ${gateway}  ${dns}  ${searchpath}  ${fqdn}  ${power}  ${syslog_srv_ip}  ${syslog_srv_protocol}  ${syslog_srv_port}
    Initialize OVA From API  %{OVA_IP}

    # wait for component services to get started
    Wait For Online Components  %{OVA_IP}
    Wait For SSO Redirect  %{OVA_IP}
    Wait For OVA Home Page  %{OVA_IP}
    [Return]  %{OVA_IP}

Install And Initialize Common OVA If Not Already
    [Arguments]  ${ova-file}
    ${rc}=  Set Test OVA IP If Available
    ${ova-ip}=  Run Keyword Unless  ${rc} == 0  Install And Initialize VIC Product OVA  ${ova-file}  %{OVA_NAME}

Setup And Install Specific OVA Version
    [Arguments]  ${ova-file}  ${ova-name}
    Log To Console  \nSetting OVA variables...
    Set Environment Variable  OVA_NAME  ${ova-name}
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    # install OVA appliance
    Log To Console  \nInstall specific version of OVA...
    Install And Initialize VIC Product OVA  ${ova-file}  ${ova-name}

Download VIC Engine
    [Arguments]  ${ova-ip}  ${target_dir}=bin
    Log To Console  \nDownloading VIC engine...
    ${download_url}=  Wait Until Keyword Succeeds  5x  5s  Run command and Return output  curl -k https://${ova-ip}:9443 | tac | tac | grep -Po -m 1 '(?<=href=")[^"]*tar.gz'
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
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -s -o /dev/null -w "\%{http_code}\\n" --header "Content-Type: application/json" -X POST --data '{"target":"%{TEST_URL}:443","user":"%{TEST_USERNAME}","password":"%{TEST_PASSWORD}","vicpassword":"${OVA_PASSWORD_ROOT}","thumbprint":"${TEST_THUMBPRINT}","externalpsc":"%{EXTERNAL_PSC}","pscdomain":"%{PSC_DOMAIN}"}' https://${ova-ip}:9443/register
    \   Exit For Loop If  '200' in '''${out}'''
    \   Sleep  180s
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
    \   ${rc}  ${out}=  Run And Return Rc And Output  curl -k -s -o /dev/null -w "\%{http_code}\\n" https://${ova-ip}:8282
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
    Log To Console  bundle file is ${file}

    Close connection

    # copy log bundle
    ${output}=  Run command and Return output  sshpass -p ${OVA_PASSWORD_ROOT} scp -o StrictHostKeyChecking\=no -o UserKnownHostsFile=/dev/null ${OVA_USERNAME_ROOT}@${ova-ip}:${file} ${OUTPUT DIR}

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
    Log  Looking for release file ${release-file-name}
    ${exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  /vic-cache/${release-file-name}
    ${old-ova-save-file}=  Run Keyword If  ${exists}  Set Variable  /vic-cache/${release-file-name}
    Run Keyword If  ${exists}  Log  Found release file in /vic-cache/${release-file-name}
    Return From Keyword If  ${exists}  ${old-ova-save-file}
    # if not exists in cache, then download it after checking locally
    ${old-ova-save-file}=  Set Variable  old-${release-file-name}
    ${exists-local}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${old-ova-save-file}
    Run Keyword If  ${exists-local}  Log  Release file already downloaded (${old-ova-save-file})
    Run Keyword Unless  ${exists-local}  Log  Downloading release file ${release-file-name}
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
    Set Suite Variable  @{list}  ${esx1}  ${esx2}  %{NIMBUS_PERSONAL_USER}-${vc}
    # set test variables
    Set Environment Variable  TEST_URL  ${vc-ip}
    Set Environment Variable  TEST_USERNAME  Administrator@vsphere.local
    Set Environment Variable  TEST_PASSWORD  Admin\!23
    Set Environment Variable  BRIDGE_NETWORK  bridge
    Set Environment Variable  PUBLIC_NETWORK  vm-network
    Set Environment Variable  TEST_RESOURCE  /ha-datacenter/host/cls
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

Auto Upgrade OVA With Verification
    # This is a complete keyword to run auto upgrade process and verify that upgrade is successful
    # This assumes that testbed is already setup
    [Arguments]  ${test-name}  ${old-ova-file-name}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  ${old-ova-datacenter}
    Set Global Variable  ${OVA_CERT_PATH}  ${old-ova-cert-path}
    # get ova file
    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}
    # setup and deploy old version of ova
    Setup And Install Specific OVA Version  ${old-ova-save-file}  ${test-name}
    # install VCH, create running container and push image to harbor
    Download VIC Engine If Not Already  %{OVA_IP}
    Install VCH With Busybox Container And Push That Image to Harbor  %{OVA_IP}  ${sample-image-tag}
    # save IP of old ova appliance
    Set Environment Variable  OVA_IP_OLD  %{OVA_IP}

    # install latest OVA appliance and don't initialize
    Log To Console  \nInstall latest version of OVA and auto upgrade...
    Set Environment Variable  OVA_NAME  ${test-name}-LATEST
    Set Global Variable  ${OVA_USERNAME_ROOT}  root
    Set Global Variable  ${OVA_PASSWORD_ROOT}  e2eFunctionalTest
    Install VIC Product OVA And Wait For Home Page  ${local_ova_file}  %{OVA_NAME}

    Execute Upgrade Script  %{OVA_IP}  %{OVA_IP_OLD}  ${old-ova-datacenter}  ${old-ova-version}
    Check Services Running Status
    Verify Running Busybox Container And Its Pushed Harbor Image  %{OVA_IP}  ${sample-image-tag}  ${new-ova-cert-path}  docker-endpoint=${VCH-PARAMS}

# check services Running state were good after upgrade
Check Services Running Status
    Open Connection  %{OVA_IP}
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}
    ${output}=  Execute Command And Return Output  docker ps
    Log  ${output}
    Should Not Contain  ${output}  seconds
    ${service_count}=  Execute Command And Return Output  docker ps | grep -v "PORTS" | wc -l
    Log  ${service_count}
    Should Be Equal As Integers  ${service_count}  15
    ${create_times}=  Execute Command And Return Output  docker ps | grep -v "PORTS" | awk -F "ago" '{print $1}' | awk '{ print $(NF-1) }' |xargs
    Log  ${create_times}
    ${up_times}=  Execute Command And Return Output  docker ps | grep -v "PORTS" | awk -F "Up" '{print $2}' |awk '{print $1}'|xargs
    Log  ${up_times}
    Should Be Equal  ${create_times}  ${up_times}
    Close Connection
    @{create_times}=  Split String  ${create_times}
    @{up_times}=  Split String  ${up_times}

    :FOR  ${IDX}  IN RANGE  ${service_count}
    \   ${lower_limit}=  Evaluate  int(@{create_times}[${IDX}])-2
    \   ${up_time}=  Evaluate  int(@{up_times}[${IDX}])
    \   ${upper_limit}=  Evaluate  int(@{create_times}[${IDX}])
    \   Should Be True  ${lower_limit} <= ${up_time} <= ${upper_limit}

Execute Upgrade Script
    # SSH into OVA appliance and execute ./upgrade script
    # Also, gather and save log bundle
    [Arguments]  ${new-appliance-ip}  ${old-appliance-ip}  ${datacenter}  ${old-appliance-version}  ${manual-disk}=False
    ${fingerprint}=  Get VCenter GOVC Fingerprint
    Log To Console  ssh into appliance...
    ${out}=  Run  sshpass -p ${OVA_PASSWORD_ROOT} ssh -o StrictHostKeyChecking\=no ${OVA_USERNAME_ROOT}@${new-appliance-ip}
    Log To Console  open connection...
    Open Connection  ${new-appliance-ip}

    Log To Console  login...
    Wait Until Keyword Succeeds  10x  5s  Login  ${OVA_USERNAME_ROOT}  ${OVA_PASSWORD_ROOT}

    :FOR  ${index}  IN RANGE  1  10
    \    Sleep  60
    \    ${out}=  Execute Command  systemctl status landing_server.service
    \    Log  ${out}
    \    ${status}=  Run Keyword And Return Status  Should Contain  ${out}  Stopped VIC Appliance Landing Page Server
    \    Log  ${status}
    \    Run Keyword If  ${status} == True  Exit For Loop

    # run upgrade script
    Run Keyword Unless  ${manual-disk}  Write  cd /etc/vmware/upgrade && ./upgrade.sh --target %{TEST_URL} --username %{TEST_USERNAME} --password Admin\\!23 --embedded-psc --fingerprint '${fingerprint}' --ssh-insecure-skip-verify --appliance-version ${old-appliance-version} --dc ${datacenter} --appliance-username ${OVA_USERNAME_ROOT} --appliance-password ${OVA_PASSWORD_ROOT} --appliance-target ${old-appliance-ip} --upgrade-password ${OVA_PASSWORD_ROOT} --upgrade-ui-plugin

    Run Keyword If  ${manual-disk}  Write  cd /etc/vmware/upgrade && ./upgrade.sh --target %{TEST_URL} --username %{TEST_USERNAME} --password Admin\\!23 --embedded-psc --fingerprint '${fingerprint}' --ssh-insecure-skip-verify --appliance-version ${old-appliance-version} --dc ${datacenter} --appliance-username ${OVA_USERNAME_ROOT} --appliance-password ${OVA_PASSWORD_ROOT} --appliance-target ${old-appliance-ip} --upgrade-password ${OVA_PASSWORD_ROOT} --manual-disks --upgrade-ui-plugin
    # Sleep for ensuring normal output when executing upgrade script
    Sleep  1m
    ${temp_output}=  Read
    Log  ${temp_output}
    ${status}=  Run Keyword And Return Status  Should Contain  ${temp_output}  Do you wish to proceed? [y/n]
    Run Keyword If  ${status}  Write  y
    ${result}=  Custom Read Until
    Log  ${result}
    Should Not Contain Any  ${result}  failed  Error

    Sleep  120
    Log To Console  to check docker ps 
    :FOR  ${index}  IN RANGE  1  4
    \   ${out}=  Execute Command  docker ps
    \   Log  ${out}
    \   Sleep  120
    Copy Support Bundle  ${new-appliance-ip}

Custom Read Until
    :FOR  ${idx}  IN RANGE  1  20
    \   Sleep  1m
    \   ${output}=  Read
    \   ${status}=  Run Keyword And Return Status  Should Contain  ${output}  Do you wish to proceed? [y/n]
    \   Run Keyword If  ${status}  Write  y
    \   ${end_status}=  Run Keyword And Return Status  Should Contain  ${output}  root@localhost
    \   Return From Keyword If  ${end_status}  ${output}

Deploy OVA And Install UI Plugin And Run Regression Tests
    # Deploy OVA and then install UI plugin
    # run regression tests on UI wizard and docker commands on VCH created using UI
    [Arguments]  ${test-name}  ${ova-file}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}=1
    Log To Console  \nStarting test ${test-name}...
    Set Test VC Variables
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

    Cache VCH Test Variable
    Test VCH Table Show State  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}

    Reload VCH Test Variable
    # run vch regression tests
    Run Docker Regression Tests For VCH
    Delete VCH Using UI
    Delete VCH Using UI

Cache VCH Test Variable
    [Arguments]  ${vch_ip}=${VCH-IP}  ${vch_port}=${VCH-PORT}  ${vch_admin}=${VIC-ADMIN}  ${vch_params}=${VCH-PARAMS}  ${vch_name}=${VCH-NAME}
    Set Test Variable  ${cache_vch_ip}  ${vch_ip}
    Set Test Variable  ${cache_vch_port}  ${vch_port}
    Set Test Variable  ${cache_vch_admin}  ${vch_admin}
    Set Test Variable  ${cache_vch_params}  ${vch_params}
    Set Test Variable  ${cache_vch_name}  ${vch_name}

Reload VCH Test Variable
    [Arguments]  ${vch_ip}=${cache_vch_ip}  ${vch_port}=${cache_vch_port}  ${vch_admin}=${cache_vch_admin}  ${vch_params}=${cache_vch_params}  ${vch_name}=${cache_vch_name}
    Set Test Variable  ${VCH-IP}  ${vch_ip}
    Set Test Variable  ${VCH-PORT}  ${vch_port}
    Set Test Variable  ${VIC-ADMIN}  ${vch_admin}
    Set Test Variable  ${VCH-PARAMS}  ${vch_params}
    Set Test Variable  ${VCH-NAME}  ${vch_name}

Test VCH Table Show State
    [Arguments]  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}=1
    Set Environment Variable  DRONE_BUILD_NUMBER  0
    ${vch_list}=  Create List
    :FOR  ${i}  IN RANGE  30
    \  Reload Page
    \  ${visible}=  Check VCH Fail Alert
    \  Should Not Be True  ${visible}
    \  ${vch_count}=  Get Create VCH Count
    \  Should Be True  ${vch_count}
    \  ${is_zero}=  Evaluate  ${i}\%10
    \  ${vch-name}=  Run Keyword If  ${is_zero} == 0  Test Create VCH Using UI  ${test-name}  ${datastore}  ${bridge-network}  ${public-network}  ${ops-user}  ${ops-pwd}  ${tree-node}
    \  Run Keyword If  ${is_zero} == 0  Append To List  ${vch_list}  ${vch-name}
    \  Run Keyword If  ${is_zero} == 0  Reload Page
    \  ${vch_count}=  Run Keyword If  ${is_zero} == 0  Get Create VCH Count
    \  ...            ELSE            Evaluate  ${vch_count}
    \  ${create_vch_count}=  Get Length  ${vch_list}
    \  ${vch_add}=  Evaluate  ${create_vch_count}+1
    \  Should Be Equal As Integers  ${vch_count}  ${vch_add}

# TODO Remove after end of 1.2.1 support
Copy and Attach Disk v1.2.1
    # This powers off the old appliance to copy data disk
    # Blank data disk is detached from the new appliance
    # Copied disk is attached to the new appliance
    [Arguments]  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}
    ${old-ds}=  Get Datastore  ${old-ova-vm-name}
    ${new-ds}=  Get Datastore  ${new-ova-vm-name}

    Wait for VM Power Off  ${old-ova-vm-name}

    # Find disk file to copy
    ${old-data-disk-file}=  Get Disk File By ID  ${old-ova-vm-name}  1
    ${data-disk-file}=  Get Disk File By ID      ${new-ova-vm-name}  1

    # Detach blank disk from new VM
    ${data-disk-name}=  Get Disk Name By ID      ${new-ova-vm-name}  1
    Detach Disk    ${new-ova-vm-name}  ${data-disk-name}

    # Copy old disk to new datastore location
    Copy Disk  ${old-ds}  ${new-ds}  ${old-data-disk-file}  ${data-disk-file}

    # Attach copied disk
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${data-disk-file}

Copy and Attach Disk
    # This powers off the old appliance to copy disks
    # Blank disks are detached from the new appliance
    # Copied disks are attached to the new appliance
    [Arguments]  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}
    ${old-ds}=  Get Datastore  ${old-ova-vm-name}
    ${new-ds}=  Get Datastore  ${new-ova-vm-name}

    Wait for VM Power Off  ${old-ova-vm-name}

    # Find disk files to copy
    ${old-data-disk-file}=  Get Disk File By ID  ${old-ova-vm-name}  1
    ${old-db-disk-file}=    Get Disk File By ID  ${old-ova-vm-name}  2
    ${old-log-disk-file}=   Get Disk File By ID  ${old-ova-vm-name}  3

    ${data-disk-file}=  Get Disk File By ID      ${new-ova-vm-name}  1
    ${db-disk-file}=    Get Disk File By ID      ${new-ova-vm-name}  2
    ${log-disk-file}=   Get Disk File By ID      ${new-ova-vm-name}  3

    # Detach blank disks from new VM
    ${data-disk-name}=  Get Disk Name By ID      ${new-ova-vm-name}  1
    ${db-disk-name}=    Get Disk Name By ID      ${new-ova-vm-name}  2
    ${log-disk-name}=   Get Disk Name By ID      ${new-ova-vm-name}  3
    Detach Disk    ${new-ova-vm-name}  ${data-disk-name}
    Detach Disk    ${new-ova-vm-name}  ${db-disk-name}
    Detach Disk    ${new-ova-vm-name}  ${log-disk-name}

    # Copy old disk to new datastore location
    Copy Disk  ${old-ds}  ${new-ds}  ${old-data-disk-file}  ${data-disk-file}
    Copy Disk  ${old-ds}  ${new-ds}  ${old-db-disk-file}  ${db-disk-file}
    Copy Disk  ${old-ds}  ${new-ds}  ${old-log-disk-file}  ${log-disk-file}

    # Attach copied disks
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${data-disk-file}
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${db-disk-file}
    Attach Disk  ${new-ova-vm-name}  ${new-ds}  ${log-disk-file}

Manual Upgrade Environment Setup
    [Arguments]  ${old-ova-file-name}  ${old-appliance-name}  ${new-appliance-name}
    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}

    Set Environment Variable  OVA_NAME  ${old-appliance-name}
    Install And Initialize VIC Product OVA  ${old-ova-save-file}  %{OVA_NAME}

    Download VIC Engine If Not Already  %{OVA_IP}
    Install VCH With Busybox Container And Push That Image to Harbor  %{OVA_IP}  ${sample-image-tag}
    Set Environment Variable  OLD_OVA_IP  %{OVA_IP}

    # Deploy new appliance but do not power on
    Set Environment Variable  OVA_NAME  ${new-appliance-name}
    ${output}=  Deploy VIC Appliance  ${local_ova_file}  %{OVA_NAME}  power=False

Power On Appliance
    [Arguments]  ${new-appliance-name}
    Power On VM  ${new-appliance-name}
    ${rc}  ${new-appliance-ip}=  Get VM IP By Name  ${new-appliance-name}
    Set Environment Variable  OVA_IP  ${new-appliance-ip}
    Wait For OVA Home Page  ${new-appliance-ip}

    [Return]  ${new-appliance-ip}

Power On Appliance And Run Manual Disk Upgrade
    [Arguments]  ${new-appliance-name}  ${old-appliance-ip}  ${old-ova-version}  ${datacenter}
    ${new-appliance-ip}=  Power On Appliance  ${new-appliance-name}

    Execute Upgrade Script  ${new-appliance-ip}  ${old-appliance-ip}  ${datacenter}  ${old-ova-version}  True

Collect Appliance and VCH Logs
    [Arguments]  ${vch-name}
    Copy Support Bundle  %{OVA_IP} 
    Curl Container Logs  ${vch-name}
