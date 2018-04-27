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
Documentation  Test 7-01 - Upgrade 1.2.1
Resource  ../../resources/Util.robot
Suite Setup  Wait Until Keyword Succeeds  10x  10m  OVA Upgrade Setup
Suite Teardown  Run Keyword And Ignore Error  Nimbus Cleanup  ${list}

*** Variables ***
${esx_number}=  2
${cluster}=  cls
${ha-datacenter}=  ha-datacenter
${old-ova-file-name}=  vic-v1.2.1-4104e5f9.ova
${old-ova-save-file}=  old-${old-ova-file-name}
${old-ova-version}=  v1.2.1
${old-ova-cert-path}=  /data/admiral/ca_download
${new-ova-cert-path}=  /storage/data/admiral/ca_download

*** Keywords ***
OVA Upgrade Setup
    OVA Upgrade Test Setup  ${old-ova-file-name}  ${old-ova-save-file}  ${ha-datacenter}

*** Test Cases ***
Upgrade OVA 1.2.1
    Auto Upgrade OVA With Verification  7-01-UPGRADE-1-2-1  ${old-ova-save-file}  ${old-ova-version}  ${old-ova-cert-path}  ${new-ova-cert-path}  ${ha-datacenter}
