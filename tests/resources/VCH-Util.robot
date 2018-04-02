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

*** Keywords ***
Set Test VCH Variables
    # set the TLS config options suitable for vic-machine in this env
    ${domain}=  Get Environment Variable  DOMAIN  ''
    Run Keyword If  ${domain} == ''  Set Test Variable  ${vicmachinetls}  --no-tlsverify
    Run Keyword If  ${domain} != ''  Set Test Variable  ${vicmachinetls}  --tls-cname=*.${domain}

Get Random Test VCH Name
    ${name}=  Evaluate  'VCH-%{DRONE_BUILD_NUMBER}-' + str(random.randint(1000,9999))  modules=random
    [Return]  ${name}

Install VCH
    [Arguments]  ${vic-machine}=bin/vic-machine-linux  ${appliance-iso}=bin/appliance.iso  ${bootstrap-iso}=bin/bootstrap.iso  ${certs}=${true}  ${vol}=default  ${cleanup}=${true}  ${debug}=1  ${additional-args}=${EMPTY}

    ${vch-name}=  Get Random Test VCH Name
    # Install the VCH now
    Log To Console  \nInstalling VCH to test server...
    ${output}=  Run VIC Machine Command  ${vch-name}  ${vic-machine}  ${appliance-iso}  ${bootstrap-iso}  ${certs}  ${vol}  ${debug}  ${additional-args}
    Log  ${output}
    Should Contain  ${output}  Installer completed successfully

    Get VCH Docker Params  ${output}  ${certs}
    Log To Console  Installer completed successfully: ${vch-name}...

    [Return]  ${vch-name}

Run VIC Machine Command
    [Tags]  secret
    [Arguments]  ${vch-name}  ${vic-machine}  ${appliance-iso}  ${bootstrap-iso}  ${certs}  ${vol}  ${debug}  ${additional-args}

    Set Test VCH Variables

    ${output}=  Run Keyword If  ${certs}  Run  ${vic-machine} create --debug ${debug} --name=${vch-name} --target=%{TEST_URL} --thumbprint=${TEST_THUMBPRINT} --user=%{TEST_USERNAME} --password=%{TEST_PASSWORD} --image-store=%{TEST_DATASTORE} --appliance-iso=${appliance-iso} --bootstrap-iso=${bootstrap-iso} --bridge-network=%{BRIDGE_NETWORK} --public-network=%{PUBLIC_NETWORK} --compute-resource=%{TEST_RESOURCE} --timeout %{VCH_TIMEOUT} --insecure-registry harbor.ci.drone.local --volume-store=%{TEST_DATASTORE}/${vch-name}-VOL:${vol} ${vicmachinetls} ${additional-args}
    Run Keyword If  ${certs}  Should Contain  ${output}  Installer completed successfully
    Return From Keyword If  ${certs}  ${output}

    ${output}=  Run Keyword Unless  ${certs}  Run  ${vic-machine} create --debug ${debug} --name=${vch-name} --target=%{TEST_URL} --thumbprint=${TEST_THUMBPRINT} --user=%{TEST_USERNAME} --password=%{TEST_PASSWORD} --image-store=%{TEST_DATASTORE} --appliance-iso=${appliance-iso} --bootstrap-iso=${bootstrap-iso} --bridge-network=%{BRIDGE_NETWORK} --public-network=%{PUBLIC_NETWORK} --compute-resource=%{TEST_RESOURCE} --timeout %{VCH_TIMEOUT} --insecure-registry harbor.ci.drone.local --volume-store=%{TEST_DATASTORE}/${vch-name}-VOL:${vol} --no-tlsverify ${additional-args}
    Run Keyword Unless  ${certs}  Should Contain  ${output}  Installer completed successfully
    [Return]  ${output}

Get VCH Docker Params
    [Arguments]  ${output}  ${certs}

    @{output}=  Split To Lines  ${output}
    :FOR  ${item}  IN  @{output}
    \   ${status}  ${message}=  Run Keyword And Ignore Error  Should Contain  ${item}  DOCKER_HOST=
    \   Run Keyword If  '${status}' == 'PASS'  Set Suite Variable  ${line}  ${item}

    # If using the default logrus format
    ${status}=  Run Keyword And Return Status  Should Match Regexp  ${line}  msg\="([^"]*)"
    ${match}  ${vars}=  Run Keyword If  ${status}  Should Match Regexp  ${line}  msg\="([^"]*)"

    # Set env variables
    @{vars}=  Split String  ${vars}
    :FOR  ${var}  IN  @{vars}
    \   ${varname}  ${varval}=  Split String  ${var}  =
    \   Run Keyword If  '${varname}' == 'DOCKER_HOST'  Set Test Variable  ${DOCKER-HOST}  ${varval}

    Set Test Variable  ${VCH-URL}  https://${DOCKER-HOST}

    @{hostParts}=  Split String  ${DOCKER-HOST}  :
    ${ip}=  Strip String  @{hostParts}[0]
    ${port}=  Strip String  @{hostParts}[1]
    Set Test Variable  ${VCH-IP}  ${ip}
    Set Test Variable  ${VCH-PORT}  ${port}

    Run Keyword If  ${port} == 2376  Set Test Variable  ${VCH-PARAMS}  -H ${DOCKER-HOST} --tls
    Run Keyword If  ${port} == 2375  Set Test Variable  ${VCH-PARAMS}  -H ${DOCKER-HOST}

    # set vic admin var
    ${status}=                Run Keyword And Return Status  Should Match Regexp  ${line}  msg\="([^"]*)"
    ${ignore}  ${vic-admin}=  Run Keyword If      ${status}  Should Match Regexp  ${line}  msg\="([^"]*)"
                              ...  ELSE                      Split String From Right  ${line}  ${SPACE}  1
    Set Test Variable  ${VIC-ADMIN}  ${vic-admin}

Gather Logs From Test Server
    [Arguments]  ${vch-name}  ${name-suffix}=${EMPTY}
    Run Keyword And Continue On Failure  Run  zip ${vch-name}-certs -r ${vch-name}
    Curl Container Logs  ${vch-name}  ${name-suffix}
    ${host}=  Get VM Host Name  ${vch-name}
    Log  ${host}
    ${out}=  Run  govc datastore.download -host ${host} -ds %{TEST_DATASTORE} ${vch-name}/vmware.log ${vch-name}-vmware${name-suffix}.log
    Log  ${out}
    Should Contain  ${out}  OK
    ${out}=  Run  govc datastore.download -host ${host} -ds %{TEST_DATASTORE} ${vch-name}/tether.debug ${vch-name}-tether${name-suffix}.debug
    Log  ${out}
    Should Contain  ${out}  OK

Curl Container Logs
    [Arguments]  ${vch-name}  ${name-suffix}=${EMPTY}
    ${out1}  ${out2}  ${out3}=  Secret Curl Container Logs  ${vch-name}  ${name-suffix}
    Log  ${out1}
    Log  ${out2}
    Log  ${out3}
    Should Not Contain  ${out3}  SIGSEGV: segmentation violation

Secret Curl Container Logs
    [Tags]  secret
    [Arguments]  ${vch-name}  ${name-suffix}=${EMPTY}
    ${out1}=  Run  curl -k -D vic-admin-cookies -Fusername=%{TEST_USERNAME} -Fpassword=%{TEST_PASSWORD} ${VIC-ADMIN}/authentication
    ${out2}=  Run  curl -k -b vic-admin-cookies ${VIC-ADMIN}/container-logs.zip -o ${SUITE NAME}-${vch-name}-container-logs${name-suffix}.zip
    ${out3}=  Run  curl -k -b vic-admin-cookies ${VIC-ADMIN}/logs/port-layer.log
    Remove File  vic-admin-cookies
    [Return]  ${out1}  ${out2}  ${out3}

Cleanup VCH
    [Tags]  secret
    [Arguments]  ${vch-name}
    Log To Console  Deleting the VCH ${vch-name}
    Run Keyword And Continue On Failure  Gather Logs From Test Server  ${vch-name}
    ${rc}  ${output}=  Run And Return Rc And Output  bin/vic-machine-linux delete --name=${vch-name} --target=%{TEST_URL} --user=%{TEST_USERNAME} --password=%{TEST_PASSWORD} --force=true --compute-resource=%{TEST_RESOURCE} --timeout %{VCH_TIMEOUT}
    Wait Until Keyword Succeeds  6x  5s  Check Delete Success  ${vch-name}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  Completed successfully
    ${output}=  Run  rm -rf ${vch-name}
    [Return]  ${output}