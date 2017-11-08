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
Resource  page-objects/Getting-Started-Page-Util.robot
Library  Selenium2Library  timeout=30  implicit_wait=15  run_on_failure=Capture Page Screenshot  screenshot_root_directory=test-screenshots
