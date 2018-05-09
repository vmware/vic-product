# Copyright 2018-2019 VMware, Inc. All Rights Reserved.
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
Documentation  This resource contains any keywords dealing with operations being performed on a VM, mostly govc wrappers
Resource  ../resources/Util.robot

*** Keywords ***
Get VM IP By Name
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.ip ${vm-name}
    Log  ${output}
    [Return]  ${rc}  ${output}

Power On VM
    [Arguments]  ${vm-name}
    ${output}=  Run command and Return output  govc vm.power -on=true "${vm-name}"
    [Return]  ${output}

Wait for VM Power Off
    [Arguments]  ${vm-name}
    Run command and Return output  govc vm.power -s=true "${vm-name}"
    Wait Until Keyword Succeeds  12x  15s  VM Is Powered Off  "${vm-name}"

VM Is Powered Off
    [Arguments]  ${vm-name}
    ${rc}  ${output}=  Run And Return Rc And Output  govc vm.info -json "${vm-name}" | jq -r ".VirtualMachines[].Runtime.PowerState"
    Log  ${output}
    Log  ${rc}
    Should Contain  ${output}  poweredOff

Get Datastore
    # Get datastore containing a VM
    [Arguments]  ${vm-name}
    ${output}=  Run command and Return output  govc vm.info -json "${vm-name}" | jq -r ".VirtualMachines[].Config.DatastoreUrl[0].Name"
    [Return]  ${output}

Get Disk File By ID
    # Get disk from VM based on it's position
    [Arguments]  ${vm-name}  ${id}
    ${output}=  Run command and Return output  govc vm.info -json "${vm-name}" | jq -r ".VirtualMachines[].Layout.Disk[${id}].DiskFile[0]" | awk '{print $NF}'
    [Return]  ${output}

Get Disk Name By ID
    # Get disk from VM based on it's position
    [Arguments]  ${vm-name}  ${id}
    ${output}=  Run command and Return output  govc device.ls -vm="${vm-name}" | grep disk- | tail -n +2 | awk '{print $1}'
    ${disk}=  Get Lines Containing String  ${output}  0-${id}
    [Return]  ${disk}

Detach Disk
    # Detach disk from VM
    [Arguments]  ${vm-name}  ${disk}
    ${output}=  Run command and Return output  govc device.remove -vm="${vm-name}" "${disk}"
    [Return]  ${output}

Attach Disk
    # Attach disk to VM
    [Arguments]  ${vm-name}  ${datastore}  ${disk}
    ${output}=  Run command and Return output  govc vm.disk.attach -vm="${vm-name}" -ds "${datastore}" -disk "${disk}"
    [Return]  ${output}