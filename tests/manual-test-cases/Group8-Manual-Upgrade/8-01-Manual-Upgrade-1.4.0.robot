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
Documentation  Test 8-01 - Manual Upgrade 1.4.0
Resource  ../../resources/Util.robot
Suite Setup  Nimbus Suite Setup  Test Environment Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${datacenter}=  ha-datacenter
${busybox}=  busybox
${sample-image-tag}=  test

*** Keywords ***
Test Environment Setup
    Setup Simple VC And Test Environment
    # Used by Install VIC Appliance Secret keyword
    Set Global Variable       ${OVA_USERNAME_ROOT}  root
    Set Global Variable       ${OVA_PASSWORD_ROOT}  e2eFunctionalTest

*** Test Cases ***
Upgrade from v1.4.0
    ${old-ova-file-name}=        Set Variable  vic-v1.4.0-4944-f168720a.ova
    ${old-ova-version}=          Set Variable  v1.4.0
    ${old-appliance-name}=       Set Variable  manual-upgrade-${old-ova-file-name}
    ${new-appliance-name}=       Set Variable  manual-upgrade-from-1.4.0-LATEST
    ${old-appliance-cert-path}=  Set Variable  /storage/data/admiral/ca_download
    ${new-appliance-cert-path}=  Set Variable  /storage/data/admiral/ca_download

    Set Global Variable  ${OVA_CERT_PATH}  ${old-appliance-cert-path}
    # Deploy old ova, install vch, create container, push an image to harbor and deploy new appliance
    Manual Upgrade Environment Setup  ${old-ova-file-name}  ${old-appliance-name}  ${new-appliance-name}
    # Copy data disk and attach to new appliance
    Copy and Attach Disk  ${old-appliance-name}  ${new-appliance-name}  ${datacenter}
    # Power on new appliance and run upgrade script
    Power On Appliance And Run Manual Disk Upgrade  ${new-appliance-name}  %{OLD_OVA_IP}  ${old-ova-version}  ${datacenter}
    # verify container and image in harbor
    Verify Running Busybox Container And Its Pushed Harbor Image  %{OVA_IP}  ${sample-image-tag}  ${new-appliance-cert-path}  docker-endpoint=${VCH-PARAMS}
