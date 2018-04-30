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
Documentation  Test 8-01 - Manual Upgrade
Resource  ../../resources/Util.robot
Suite Setup     Wait Until Keyword Succeeds  10x  10m  Test Environment Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown   Cleanup VIC Product OVA  %{OVA_NAME}

*** Variables ***
${datacenter}=  ha-datacenter

*** Keywords ***
Test Environment Setup
    vSphere and Test Environment Setup
    # Used by Install VIC Appliance Secret keyword
    Set Global Variable       ${OVA_USERNAME_ROOT}  root
    Set Global Variable       ${OVA_PASSWORD_ROOT}  e2eFunctionalTest

*** Test Cases ***

Upgrade from v1.2.1
    ${old-ova-file-name}=   vic-v1.2.1-4104e5f9.ova
    ${old-ova-save-file}=   upgrade-${old-ova}
    ${old-appliance-name}=  ${old-ova-file-name}-8-01-Manual-Upgrade
    ${new-appliance-name}=  ${test-name}-LATEST

    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}

    Set Environment Variable  OVA_NAME  ${old-appliance-name}
    ${old-appliance-ip}=  Install And Initialize VIC Product OVA  ${old-ova-file-name}  %{OVA_NAME}
    Install VCH With Test Container And Push Image to Harbor

    # Deploy new appliance but do not power on
    Set Environment Variable  OVA_NAME  ${new-appliance-name}
    ${output}=  Deploy VIC Appliance  vic-*.ova  %{OVA_NAME}  ${EMPTY}  ${EMPTY}  ${EMPTY}  False

    # Copy data disk and attach to new appliance
    Copy and Attach Disk v1.2.1  ${old-appliance-name}  ${new-appliance-name}  ${datacenter}

    Power On VM  ${new-appliance-name}
    ${new-appliance-ip}=  Get VM IP By Name  ${new-appliance-name}

    Execute Upgrade Script Manual Disk Move  ${old-appliance-ip}  ${new-appliance-ip}
    Verify Running Test Container And Pushed Image


Upgrade from v1.3.0
    ${old-ova-file-name}=   vic-v1.3.0-3033-f8cc7317.ova
    ${old-ova-save-file}=   upgrade-${old-ova}
    ${old-appliance-name}=  ${old-ova-file-name}-8-01-Manual-Upgrade
    ${new-appliance-name}=  ${test-name}-LATEST

    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}

    Set Environment Variable  OVA_NAME  ${old-appliance-name}
    ${old-appliance-ip}=  Install And Initialize VIC Product OVA  ${old-ova-file-name}  %{OVA_NAME}
    Install VCH With Test Container And Push Image to Harbor

    # Deploy new appliance but do not power on
    Set Environment Variable  OVA_NAME  ${new-appliance-name}
    ${output}=  Deploy VIC Appliance  vic-*.ova  %{OVA_NAME}  ${EMPTY}  ${EMPTY}  ${EMPTY}  False

    # Copy data, log, db disks and attach to new appliance
    Copy and Attach Disks  ${old-appliance-name}  ${new-appliance-name}  ${datacenter}

    Power On VM  ${new-appliance-name}
    ${new-appliance-ip}=  Get VM IP By Name  ${new-appliance-name}

    Execute Upgrade Script Manual Disk Move  ${old-appliance-ip}  ${new-appliance-ip}
    Verify Running Test Container And Pushed Image


Upgrade from v1.3.1
    ${old-ova-file-name}=   vic-v1.3.1-3409-132fb13d.ova
    ${old-ova-save-file}=   upgrade-${old-ova}
    ${old-appliance-name}=  ${old-ova-file-name}-8-01-Manual-Upgrade
    ${new-appliance-name}=  ${test-name}-LATEST

    ${old-ova-save-file}=  Get OVA Release File For Nightly  ${old-ova-file-name}

    Set Environment Variable  OVA_NAME  ${old-appliance-name}
    ${old-appliance-ip}=  Install And Initialize VIC Product OVA  ${old-ova-file-name}  %{OVA_NAME}
    Install VCH With Test Container And Push Image to Harbor

    # Deploy new appliance but do not power on
    Set Environment Variable  OVA_NAME  ${new-appliance-name}
    ${output}=  Deploy VIC Appliance  vic-*.ova  %{OVA_NAME}  ${EMPTY}  ${EMPTY}  ${EMPTY}  False

    # Copy data, log, db disks and attach to new appliance
    Copy and Attach Disks  ${old-appliance-name}  ${new-appliance-name}  ${datacenter}

    Power On VM  ${new-appliance-name}
    ${new-appliance-ip}=  Get VM IP By Name  ${new-appliance-name}

    Execute Upgrade Script Manual Disk Move  ${old-appliance-ip}  ${new-appliance-ip}
    Verify Running Test Container And Pushed Image
