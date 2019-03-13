# Interoperability with Other VMware Software

vSphere administrators can use the vSphere Client to view and manage the vSphere Integrated Containers appliance, virtual container hosts (VCHs), and container VMs. 

- You can use any vSphere feature to manage the vSphere Integrated Containers appliance without affecting its behavior. 
- VCHs have some specific requirements when using certain vSphere features and other VMware products.

This topic describes how vSphere features and other VMware products interact with vSphere Integrated Containers, VCHs, and container VMs. 
  
For information about the supported versions of VMware software that are compatible with vSphere Integrated Containers, see the [VMware Product Interoperability Matrices](https://partnerweb.vmware.com/comp_guide2/sim/interop_matrix.php#interop&149=&0=).

## VMware NSX&reg; Data Center<a id="nsx"></a>

You can deploy the vSphere Integrated Containers appliance on NSX Data Center for vSphere networks and NSX-T&trade; Data Center networks. 

VCHs require a dedicated network interface for the bridge network. It is also recommended to use a dedicated network interface for the public network. You can also optionally use separate network interfaces for the management, client, and container  networks. 

- You can deploy VCHs to NSX Data Center for vSphere networks if those networks are configured to provide distributed port groups.
- You can deploy VCHs that use NSX-T Data Center logical switches instead of port groups. vSphere Integrated Containers supports NSX-T Data Center versions 2.0, 2.1, 2.2, and 2.3.

For more information about how to use NSX Data Center and NSX-T Data Center networks with vSphere Integrated Containers, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).

## VMware vSAN&trade; and Other Storage <a id="vsan"></a>

VCHs maintain file system layers inherent in container images by mapping to discrete VMDK files. Consequently you can use any shared vSphere datastores, including vSAN, NFS, Fibre Channel, and iSCSI datastores when configuring storage for VCHs.

## VMware vSphere vMotion&reg; <a id="vmotion"></a>

You can use vMotion to move the vSphere Integrated Containers appliance and VCHs without needing to take the container VMs offline. The VCH endpoint VM does not need to be running for vMotion to occur on the container VMs. You can use vMotion on clusters with a mix of container VMs and non-container VMs. 

## VMware vSphere Distributed Resource Scheduler&trade; <a id="drs"></a>

You can deploy the vSphere Integrated Containers appliance to DRS enabled clusters. When deploying VCHs, VMware recommends that you enable DRS on the target clusters whenever possible, but this is not a requirement. For more information about VCHs and DRS, see Supported Configurations for VCH Deployment in [Virtual Infrastructure Requirements](vi_reqs.md#configs).

## VMware vRealize&reg; Automation&trade; <a id="vrealize"></a>

Your organization could use VMware vRealize Automation to provide a self-provisioning service for VCHs, by using the vRealize Automation interface or APIs to request VCHs. At the end of the provisioning process, vRealize Automation would communicate the VCH endpoint VM address to the requester. If you deploy VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. vRealize Automation could potentially provide the `env` file at the end of a provisioning process for VCHs.

- vRealize Automation 7.3 supports vSphere Integrated Containers 1.1.x. 
- vRealize Automation 7.4 supports vSphere Integrated Containers 1.3.x. 
- vRealize Automation 7.5 supports vSphere Integrated Containers 1.3.x and 1.4.x, up to and including 1.4.2. 

For the most up-to-date information about compatibility with vRealize Automation, see the [VMware Product Interoperability Matrices](https://partnerweb.vmware.com/comp_guide2/sim/interop_matrix.php#interop&114=&149=).

## General vSphere Operation and Other Features <a id="vsphere"></a>

- If you restart a VCH endpoint VM, it comes back up in the same state that it was in when it shut down. 
- If you use DHCP on the client network, the IP address of the VCH endpoint VM might change after a restart. Use `vic-machine inspect` to obtain the new IP address.
- Do not manually delete a VCH resource pool, the VCH endpoint VM, or container VMs. Always use the vSphere Integrated Containers plug-in for the vSphere Client or `vic-machine delete` to delete VCHs. Always use Docker commands or the vSphere Integrated Containers Management Portal to perform operations on container VMs.
- You can stop container VMs by selecting the **Power** > **Shut Down Guest OS** option. If you use this option the application will be stopped using the same escalating approach as running `docker stop`. The application first receives the `STOPSIGNAL` defined in the container image, then `SIGTERM`, `SIGKILL`, and finally the VM will power off. There is a 10 second delay between each step, to allow the application to exit gracefully.
- Do not restart or power off container VMs by selecting **Power** > **Reset** or **Power** > **Power Off**. Using those options can result in incorrect end-times for container operations.  Always use **Power** > **Shut Down Guest OS**, Docker commands, or the vSphere Integrated Containers Management Portal to perform restart and stop operations on container VMs.

### VMware vSphere High Availability <a id="ha"></a>

You can apply vSphere High Availability to clusters on which VCHs and container VMs run. If the host on which a VCH or container VMs are running goes offline, the VCH and container VMs migrate to another host in the cluster. VCHs restart on the new host immediately. Container VMs that were running before the migration restart one by one, after the VCH has restarted. For more information about VCHs and High Availability, see [Backing Up Virtual Container Host Data](backup_vch.md).

### Maintenance Mode <a id="maintmode"></a>

In a cluster with fully automated DRS, if you put a host into maintenance mode, DRS migrates the VCHs and container VMs to another host in the cluster. Putting hosts into maintenance mode requires manual intervention in certain circumstances:

- If VCHs and container VMs are running on a standalone ESXi host, you must power off the VCHs and container VMs before you put the host into maintenance mode.
- If container VMs have active `docker attach` sessions, you cannot put the host into maintenance mode until the `attach` sessions end. 

### Enhanced Linked Mode Environments <a id="elm"></a>
You can deploy VCHs in Enhanced Linked Mode environments. Any vCenter Server instance in the Enhanced Linked Mode environment can access VCH and container VM information.

### vSphere Features Not Supported in This Release <a id="notsupported"></a>
VCHs do not currently support the following vSphere features:

- vSphere Storage DRS&trade;: You cannot configure VCHs to use Storage DRS datastore clusters. 
- vSphere Fault Tolerance: vSphere Integrated Containers does not implement vSphere Fault Tolerance. However, VCH processes that stop unexpectedly do restart automatically, independently of vSphere Fault Tolerance.
- vSphere Virtual Volumes&trade;: You cannot use Virtual Volumes as the target datastores for image stores or volume stores.
- Snapshots: Creating and reverting to snapshots of the VCH endpoint VM or container VMs can cause vSphere Integrated Containers Engine not to function correctly.
- vCenter Server High Availabilty: You cannot deploy VCHs on a highly available vCenter Server, but you can apply vSphere High Availability to clusters on which VCHs and container VMs run. For more information, see [VMware vSphere High Availability](#ha).