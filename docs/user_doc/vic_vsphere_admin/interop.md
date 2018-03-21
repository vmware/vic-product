# Interoperability of Virtual Container Hosts with Other VMware Software
vSphere administrators can use vSphere to view and manage the vSphere Integrated Containers appliance, virtual container hosts (VCHs), and container VMs. You can use any vSphere feature to manage the vSphere Integrated Containers appliance without affecting its behavior.

This topic describes the interoperability of VCHs with other vSphere features and VMware products. 

- [Performing Operations on VCHs and Container VMs in vSphere](#vms)
- [VMware vRealize&reg; Suite](#vrealize)
- [VMware vSphere vMotion&reg;](#vmotion)
- [VMware vSphere High Availability](#ha)
- [VMware NSX&reg;](#nsx)
- [Maintenance Mode](#maintmode)
- [Storage](#vsan)
- [Enhanced Linked Mode Environments](#elm)
- [vSphere Features Not Supported in This Release](#notsupported)

## Performing Operations on VCHs and Container VMs in vSphere <a id="vms"></a>

- If you restart a VCH endpoint VM, it comes back up in the same state that it was in when it shut down. 
- If you use DHCP on the client network, the IP address of the VCH endpoint VM might change after a restart. Use `vic-machine inspect` to obtain the new IP address.
- Do not manually delete a VCH vApp, the VCH endpoint VM, or container VMs. Always use `vic-machine delete` to delete VCHs and use Docker commands to perform operations on container VMs.
- Manually restarting container VMs, either individually or by manually restarting the VCH vApp, can result in incorrect end-times for container operations. Do not manually restart the vApp or container VMs. Always use Docker commands to perform operations on container VMs.

## VMware vRealize Suite <a id="vrealize"></a>
Your organization could use VMware vRealize Automation to provide a self-provisioning service  for VCHs, by using the vRealize Automation interface or APIs to request VCHs. At the end of the provisioning process, vRealize Automation would communicate the VCH endpoint VM address to the requester. If you deploy VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. vRealize Automation could potentially provide the `env` file at the end of a provisioning process for VCHs.

**NOTE**: vRealize Automation 7.3 supports vSphere Integrated Containers 1.1.x. Support for this release of vSphere Integrated Containers will be added in a future release of vRealize Automation.

## VMware vSphere vMotion <a id="vmotion"></a>

You can use vMotion to move VCHs without needing to take the container VMs offline. The VCH endpoint VM does not need to be running for vMotion to occur on the container VMs. Clusters with a mix of container VMs and non-container VMs can use vMotion with fully automated DRS. 

## VMware vSphere High Availability <a id="ha"></a>

You can apply vSphere High Availability to clusters on which VCHs and container VMs run. If the host on which a VCH or container VMs are running goes offline, the VCH and container VMs migrate to another host in the cluster. VCHs restart on the new host immediately. Container VMs that were running before the migration restart one by one, after the VCH has restarted. For more information about VCHs and High Availability, see [Backing Up Virtual Container Host Data](backup_vch.md).

## VMware NSX <a id="nsx"></a>

You can deploy the vSphere Integrated Containers appliance on an NSX network. VCHs require distributed port groups and a bridge network. You can deploy VCHs to NSX networks if those networks are configured to provide distributed port groups. You can use NSX networks for the management, bridge, public, and container networks. 

## Maintenance Mode <a id="maintmode"></a>

In a cluster with fully automated DRS, if you put a host into maintenance mode, DRS migrates the VCHs and container VMs to another host in the cluster. Putting hosts into maintenance mode requires manual intervention in certain circumstances:

- If VCHs and container VMs are running on a standalone ESXi host, you must power off the VCHs and container VMs before you put the host into maintenance mode.
- If container VMs have active `docker attach` sessions, you cannot put the host into maintenance mode until the `attach` sessions end. 

## Storage <a id="vsan"></a>
VCHs maintain file system layers inherent in container images by mapping to discrete VMDK files, all of which can be housed in shared vSphere datastores, including vSAN, NFS, Fibre Channel, and iSCSI datastores.

## Enhanced Linked Mode Environments <a id="elm"></a>
You can deploy VCHs in Enhanced Linked Mode environments. Any vCenter Server instance in the Enhanced Linked Mode environment can access VCH and container VM information.

## vSphere Features Not Supported in This Release <a id="notsupported"></a>
vSphere Integrated Containers Engine does not currently support the following vSphere features:

- vSphere Storage DRS&trade;: You cannot configure VCHs to use Storage DRS datastore clusters. However, you can specify the path to a specific datastore within a Storage DRS datastore cluster by specifying the full inventory path to the datastore in the `vic-machine create --image-store` option. For example, `--image-store /dc1/datastore/my-storage-pod/datastore1`. You can also specify the relative path from a datastore folder in a datacenter, for example `--image-store my-storage-pod/datastore1`.
- vSphere Fault Tolerance: vSphere Integrated Containers does not implement vSphere Fault Tolerance. However, VCH processes that stop unexpectedly do restart automatically, independently of vSphere Fault Tolerance.
- vSphere Virtual Volumes&trade;: You cannot use Virtual Volumes as the target datastores for image stores or volume stores.
- Snapshots: Creating and reverting to snapshots of the VCH endpoint VM or container VMs can cause vSphere Integrated Containers Engine not to function correctly.