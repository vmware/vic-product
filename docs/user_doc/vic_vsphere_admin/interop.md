# Interoperability of vSphere Integrated Containers Engine with Other VMware Software
vSphere administrators can use vSphere to view and manage virtual container hosts (VCHs) and container VMs. vSphere Integrated Containers Engine works with the following vSphere features and VMware products. 

## Performing Operations on VCHs and Container VMs in vSphere ##

- If you restart a VCH endpoint VM, it comes back up in the same state that it was in when it shut down. 
- If you shut down the VCH vApp, the VCH endpoint VM and all of the container VMs that it manages power off. When you restart the vApp, only the VCH powers back on. Container VMs do not power back on when you restart the vApp. This is consistent with standard Docker behavior.
- If you use DHCP on the client network, the IP address of the VCH endpoint VM might change after a restart. Use `vic-machine inspect` to obtain the new IP address.
- Do not manually delete a VCH vApp or VCH endpoint VM. Use `vic-machine delete` to delete VCHs.
- Manually powering off container VMs can result in incorrect end-times for container operations. Do not manually delete a container VM. Use Docker commands to perform operations on container VMs.

## VMware vRealize&reg; Suite 
Your organization could use VMware vRealize Automation to provide a self-provisioning service  for VCHs, by using the vRealize Automation interface or APIs to request VCHs. At the end of the provisioning process, vRealize Automation would communicate the VCH endpoint VM address to the requester. If you deploy VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. vRealize Automation could potentially provide the `env` file at the end of a provisioning process for VCHs.

## VMware vSphere vMotion&reg;  

You can use vMotion to move VCHs without needing to take the container VMs offline. The VCH endpoint VM does not need to be running for vMotion to occur on the container VMs. Clusters with a mix of container VMs and non-container VMs can use vMotion with fully automated DRS. 

## VMware vSphere High Availability ##

You can apply vSphere High Availability to clusters on which VCHs and container VMs run. If the host on which a VCH or container VMs are running goes offline, the VCH and container VMs migrate to another host in the cluster. VCHs restart on the new host immediately. Container VMs that were running before the migration must be restarted manually by using the `docker run --restart` command.

## Maintenance Mode ##

In a cluster with fully automated DRS, if you put a host into maintenance mode, DRS migrates the VCHs and container VMs to another host in the cluster. Putting hosts into maintenance mode requires manual intervention in certain circumstances:

- If VCHs and container VMs are running on a standalone ESXi host, you must power off the VCHs and container VMs before you put the host into maintenance mode.
- If container VMs have active `docker attach` sessions, you cannot put the host into maintenance mode until the `attach` sessions end. 

## VMware vSAN&trade;
VCHs maintain filesystem layers inherent in container images by mapping to discrete VMDK files, all of which can be housed in shared vSphere datastores, including vSAN, NFS, and iSCSI datastores.

## Enhanced Linked Mode Environments
You can deploy VCHs in Enhanced Linked Mode environments. Any vCenter Server instance in the Enhanced Linked Mode environment can access VCH and container VM information.

## vSphere Features Not Supported in This Release
vSphere Integrated Containers Engine does not currently support the following vSphere features:

- vSphere Storage DRS&trade;: You cannot configure VCHs to use Storage DRS datastore clusters. However, you can specify the path to a specific datastore within a Storage DRS datastore cluster by specifying the full inventory path to the datastore in the `vic-machine create --image-store` option. For example, `--image-store /dc1/datastore/my-storage-pod/datastore1`. You can also specify the relative path from a datastore folder in a datacenter, for example `--image-store my-storage-pod/datastore1`.
- vSphere Fault Tolerance: You cannot configure Fault Tolerance on VCHs.
- vSphere Virtual Volumes&trade;: You cannot use Virtual Volumes as the target datastores for image stores or volume stores.
- Snapshots: Creating and reverting to snapshots of the VCH endpoint VM or container VMs can cause vSphere Integrated Containers Engine not to function correctly.