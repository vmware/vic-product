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
Documentation  Test 1-01 - Install Test
Resource  ../../resources/Util.robot
Test Timeout  5 minutes

*** Test Cases ***
Verify VIC engine download and create VCH
    Download VIC Engine  %{OVA_IP}

    ${vch-name}=  Install VCH  certs=${false}
    ${output}=  Run command and Return output  docker ${VCH-PARAMS} info
    Should Contain  ${output}  Storage Driver: vSphere Integrated Container
    Should Contain  ${output}  Backend Engine: RUNNING

    [Teardown]  Cleanup VCH  ${vch-name}
