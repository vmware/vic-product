# Copyright 2016-2017 VMware, Inc. All Rights Reserved.
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
Library  OperatingSystem
Library  String
Library  Collections
Library  requests
Library  Process
Library  SSHLibrary  5 minute
Library  DateTime
Resource  OVA-Util.robot
Resource  VC-Util.robot
Resource  VCH-Util.robot
Resource  UI-Util.robot
Library  Selenium2Library  timeout=30  implicit_wait=15  run_on_failure=Capture Page Screenshot  screenshot_root_directory=test-screenshots
# UI page object utils
Resource  page-objects/Getting-Started-Page-Util.robot
Resource  page-objects/Complete-Installation-Modal-Util.robot
Resource  page-objects/VC-Single-Sign-On-Util.robot
Resource  page-objects/Header-Util.robot
Resource  page-objects/Side-Nav-Util.robot
Resource  page-objects/Container-Hosts-Page-Util.robot
Resource  page-objects/New-Container-Host-Modal-Util.robot
Resource  page-objects/Verify-Certificate-Modal-Util.robot
Resource  page-objects/Remove-Host-Modal-Util.robot
Resource  page-objects/Containers-Page-Util.robot
Resource  page-objects/Provision-Container-Page-Util.robot
Resource  page-objects/Right-Context-Panel-Util.robot


*** Keywords ***
Run command and Return output
    [Arguments]  ${command}
    ${rc}  ${output}=  Run And Return Rc And Output  ${command}
    Log  ${output}
    Should Be Equal As Integers  ${rc}  0
    [Return]  ${output}