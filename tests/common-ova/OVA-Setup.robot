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
Documentation  Common OVA Install
Resource  ../resources/Util.robot
Test Timeout  30 minutes
Suite Setup  Global Environment Setup

*** Variables ***
${default-ova-file-path}  installer/bin/vic-*.ova


*** Test Cases ***
Install Common OVA
    Log To Console  \nInstalling ova, enrolling psc, and checking online component status...
    Install Common OVA If Not Already  ${default-ova-file-path}