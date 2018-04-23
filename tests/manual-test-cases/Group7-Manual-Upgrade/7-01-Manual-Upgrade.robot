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
Documentation  Test 7-01 - Manual Upgrade
Resource  ../../resources/Util.robot
Suite Setup     Wait Until Keyword Succeeds  10x  10m  OVA Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}
Test Teardown   Cleanup VIC Product OVA  %{OVA_NAME}

*** Variables ***
${datacenter}=  ha-datacenter

*** Keywords ***

*** Test Cases ***

Upgrade from v1.2.1
    ${old-ova-file-name}=  vic-v1.2.1-4104e5f9.ova
    ${old-ova-save-file}=  upgrade-${old-ova}
    ${old-ova-vm-name}=    ${old-ova-file-name}-7-01-Manual-Upgrade
    ${new-ova-vm-name}=    ${test-name}-LATEST

    OVA Upgrade Test Setup  ${old-ova-file-name}  ${old-ova-save-file}  ${datacenter}

    Set Environment Variable  OVA_NAME  ${old-ova-vm-name}
    ${old-ova-ip}=  Install And Initialize VIC Product OVA  ${old-ova-file-name}  %{OVA_NAME}

    Set Environment Variable  OVA_NAME  ${new-ova-vm-name}
    ${new-ova-ip}=  Install VIC Product OVA And Wait For Home Page  vic-*.ova  %{OVA_NAME}

    # Copy data disk and attach to new appliance
    Copy and Attach Disk v1.2.1  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}

    Execute Upgrade Script Manual Disk Move  ${old-ova-ip}  ${new-ova-ip}

Upgrade from v1.3.0
    ${old-ova-file-name}=  vic-v1.3.0-3033-f8cc7317.ova
    ${old-ova-save-file}=  upgrade-${old-ova}
    ${old-ova-vm-name}=    ${old-ova-file-name}-7-01-Manual-Upgrade
    ${new-ova-vm-name}=    ${test-name}-LATEST

    OVA Upgrade Test Setup  ${old-ova-file-name}  ${old-ova-save-file}  ${datacenter}

    Set Environment Variable  OVA_NAME  ${old-ova-vm-name}
    ${old-ova-ip}=  Install And Initialize VIC Product OVA  ${old-ova-file-name}  %{OVA_NAME}

    Set Environment Variable  OVA_NAME  ${new-ova-vm-name}
    ${new-ova-ip}=  Install VIC Product OVA And Wait For Home Page  vic-*.ova  %{OVA_NAME}

    # Copy data, log, db disks and attach to new appliance
    Copy and Attach Disks  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}

    Execute Upgrade Script Manual Disk Move  ${old-ova-ip}  ${new-ova-ip}

Upgrade from v1.3.1
    ${old-ova-file-name}=  vic-v1.3.1-3409-132fb13d.ova
    ${old-ova-save-file}=  upgrade-${old-ova}
    ${old-ova-vm-name}=    ${old-ova-file-name}-7-01-Manual-Upgrade
    ${new-ova-vm-name}=    ${test-name}-LATEST

    OVA Upgrade Test Setup  ${old-ova-file-name}  ${old-ova-save-file}  ${datacenter}

    Set Environment Variable  OVA_NAME  ${old-ova-vm-name}
    ${old-ova-ip}=  Install And Initialize VIC Product OVA  ${old-ova-file-name}  %{OVA_NAME}

    Set Environment Variable  OVA_NAME  ${new-ova-vm-name}
    ${new-ova-ip}=  Install VIC Product OVA And Wait For Home Page  vic-*.ova  %{OVA_NAME}

    # Copy data, log, db disks and attach to new appliance
    Copy and Attach Disks  ${old-ova-vm-name}  ${new-ova-vm-name}  ${datacenter}

    Execute Upgrade Script Manual Disk Move  ${old-ova-ip}  ${new-ova-ip}
