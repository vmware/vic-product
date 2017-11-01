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
Set VCH Test Environment Variables
    Set Environment Variable  TEST_DATACENTER  /datacenter1
    Set Environment Variable  VCH_TIMEOUT  20m0s

    # set the TLS config options suitable for vic-machine in this env
    ${domain}=  Get Environment Variable  DOMAIN  ''
    Run Keyword If  $domain == ''  Set Suite Variable  ${vicmachinetls}  --no-tlsverify
    Run Keyword If  $domain != ''  Set Suite Variable  ${vicmachinetls}  --tls-cname=*.${domain}

    ${thumbprint}=  Get vCenter Thumbprint
    Set Environment Variable  TEST_THUMBPRINT  ${thumbprint}

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

    Set VCH Test Environment Variables

    ${output}=  Run Keyword If  ${certs}  Run  ${vic-machine} create --debug ${debug} --name=${vch-name} --target=%{TEST_URL} --thumbprint=%{TEST_THUMBPRINT} --user=%{TEST_USERNAME} --password=%{TEST_PASSWORD} --image-store=%{TEST_DATASTORE} --appliance-iso=${appliance-iso} --bootstrap-iso=${bootstrap-iso} --bridge-network=%{BRIDGE_NETWORK} --public-network=%{PUBLIC_NETWORK} --compute-resource=%{TEST_RESOURCE} --timeout %{VCH_TIMEOUT} --insecure-registry harbor.ci.drone.local --volume-store=%{TEST_DATASTORE}/${vch-name}-VOL:${vol} ${vicmachinetls} ${additional-args}
    Run Keyword If  ${certs}  Should Contain  ${output}  Installer completed successfully
    Return From Keyword If  ${certs}  ${output}

    ${output}=  Run Keyword Unless  ${certs}  Run  ${vic-machine} create --debug ${debug} --name=${vch-name} --target=%{TEST_URL} --thumbprint=%{TEST_THUMBPRINT} --user=%{TEST_USERNAME} --password=%{TEST_PASSWORD} --image-store=%{TEST_DATASTORE} --appliance-iso=${appliance-iso} --bootstrap-iso=${bootstrap-iso} --bridge-network=%{BRIDGE_NETWORK} --public-network=%{PUBLIC_NETWORK} --compute-resource=%{TEST_RESOURCE} --timeout %{VCH_TIMEOUT} --insecure-registry harbor.ci.drone.local --volume-store=%{TEST_DATASTORE}/${vch-name}-VOL:${vol} --no-tlsverify ${additional-args}
    Run Keyword Unless  ${certs}  Should Contain  ${output}  Installer completed successfully
    [Return]  ${output}

Get VCH Docker Params
    [Arguments]  ${output}  ${certs}

    # Ensure we start from a clean slate with docker env vars
    Remove Environment Variable  DOCKER_HOST  DOCKER_TLS_VERIFY  DOCKER_CERT_PATH  CURL_CA_BUNDLE  COMPOSE_PARAMS  COMPOSE_TLS_VERSION

    @{output}=  Split To Lines  ${output}
    :FOR  ${item}  IN  @{output}
    \   ${status}  ${message}=  Run Keyword And Ignore Error  Should Contain  ${item}  DOCKER_HOST=
    \   Run Keyword If  '${status}' == 'PASS'  Set Suite Variable  ${line}  ${item}

    # Split the log log into pieces, discarding the initial log decoration, and assign to env vars
    ${logmon}  ${logday}  ${logyear}  ${logtime}  ${loglevel}  ${vars}=  Split String  ${line}  max_split=5
    # Set env variables
    @{vars}=  Split String  ${vars}
    :FOR  ${var}  IN  @{vars}
    \   ${varname}  ${varval}=  Split String  ${var}  =
    \   Set Environment Variable  ${varname}  ${varval}

    ${dockerHost}=  Get Environment Variable  DOCKER_HOST

    @{hostParts}=  Split String  ${dockerHost}  :
    ${ip}=  Strip String  @{hostParts}[0]
    ${port}=  Strip String  @{hostParts}[1]
    Set Environment Variable  VCH-IP  ${ip}
    Set Environment Variable  VCH-PORT  ${port}

    Run Keyword If  ${port} == 2376  Set Environment Variable  VCH-PARAMS  -H ${dockerHost} --tls
    Run Keyword If  ${port} == 2375  Set Environment Variable  VCH-PARAMS  -H ${dockerHost}

Cleanup VCH
    [Arguments]  ${vch-name}
    Log To Console  Deleting the VCH appliance ${vch-name}
    ${rc}  ${output}=  Run And Return Rc And Output  bin/vic-machine-linux delete --name=${vch-name} --target=%{TEST_URL} --user=%{TEST_USERNAME} --password=%{TEST_PASSWORD} --force=true --compute-resource=%{TEST_RESOURCE} --timeout %{VCH_TIMEOUT}
    Wait Until Keyword Succeeds  6x  5s  Check Delete Success  ${vch-name}
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  Completed successfully
    ${output}=  Run  rm -rf ${vch-name}
    [Return]  ${output}