# Container VMs Orphaned After Upgrade

After you upgrade vSphere Integrated Containers from version  1.2.x or 1.3.x to 1.4.0 or later, associations between container VMs and virtual container hosts (VCH) are broken and the container VMs appear as orphaned in the vSphere Client. When you try to manage the container VMs through the Docker client, the container VMS are not listed.

## Problem

After an upgrade, when you run `docker container ls` on the Docker client, the container VMs might not be listed. 

## Cause

This error can occur in one of the following situations:

* The container VMS that are not listed were missing before the upgrade. 
* The container VMS are not in the VM folder that is created in the image store during the upgrade procedure.
* The container VMs and the VCH Endpoint VM are already moved to the container VM folder before the upgrade.

## Solution

If the container VMs that are not listed on the Docker client are present in the vSphere client, verify if they are in the VM folder in the image store after the upgrade. If they are not present, then manually move the container VMs into that folder.