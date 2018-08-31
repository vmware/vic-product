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
Documentation  Test 2-01 Getting Started
Resource  ../../resources/Util.robot
Test Timeout  5 minutes
Test Setup  Open Firefox Browser
Test Teardown  Close All Browsers

*** Test Cases ***
Verify Getting Started page
    Log To Console  Initializing the OVA using the getting started ui...
    Navigate To Getting Started Page
    Verify Getting Started Page Title
    #Log In And Complete OVA Installation
