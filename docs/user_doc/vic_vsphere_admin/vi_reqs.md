# Virtual Infrastructure Requirements <a id="vireqs"></a>

You must ensure that the vCenter Server instance and ESXi hosts on which you are deploying the vSphere Integrated Containers appliance and virtual container hosts (VCHs) meet certain requirements.

## License Requirements <a id="license"></a>
vSphere Integrated Containers depends on certain features that are included in the following vSphere Editions:

- vSphere Enterprise Plus
- vSphere Remote Office Branch Office (ROBO) Advanced

All of the ESXi hosts in a cluster require an appropriate license. Deployment of VCHs fails if your environment includes one or more ESXi hosts that have inadequate licenses.

## vSphere Integrated Containers Appliance Requirements <a id="appliancereqs"></a>

You deploy the vSphere Integrated Containers appliance on a vCenter Server instance. Deploying the appliance directly on an ESXi host is not supported.

- vSphere Integrated Containers 1.5.5: 6.7 vCenter Server update 3, 7.0
- vSphere Integrated Containers 1.5.0-1.5.4: vCenter Server 6.5, 6.7, 6.7 update 1, or 6.7 update 2.
- vSphere Integrated Containers 1.5.5: ESXi 6.7, 7.0 for all hosts.
- vSphere Integrated Containers 1.5.0-1.5.4: ESXi 6.5, or 6.7 for all hosts.
- At least 2 vCPUs.
- At least 8GB RAM.
- At least 80GB free disk space on the datastore. The disk space for the appliance uses thin provisioning.

For the latest information about the compatibility of all vSphere Integrated Containers versions with vCenter Server, see the [VMware Product Interoperability Matrices](https://partnerweb.vmware.com/comp_guide2/sim/interop_matrix.php#interop&149=&2=).

## vSphere Client Requirements <a id="client"></a>

vSphere Integrated Containers provides an interactive plug-in for the HTML5 vSphere Client and a basic plug-in for the Flex-based vSphere Web Client: 

- The HTML5 plug-in for vSphere 6.5 and 6.7 allows you to deploy and interact with VCHs from the vSphere Client. The HTML5 vSphere Client plug-in for vSphere Integrated Containers requires vCenter Server 6.7 or vCenter Server 6.5.0d or later.
- The Flex-based plug-in for vSphere 6.0 has limited functionality and only provides basic information about VCHs and container VMs. 

## Supported Configurations for VCH Deployment <a id="configs"></a>

You can deploy VCHs in the following types of setup:

* vCenter Server 6.0, 6.5, 6.7, 6.7 update 1, or 6.7 update 2, managing a cluster of ESXi  6.0, 6.5, or 6.7 hosts. VMware recommends that you enable VMware vSphere Distributed Resource Scheduler (DRS) on clusters whenever possible, but this is not a requirement.
* vCenter Server 6.0, 6.5, 6.7, 6.7 update 1, or 6.7 update 2, managing one or more standalone ESXi 6.0, 6.5, or 6.7 hosts.
* Standalone ESXi 6.0, 6.5, or 6.7 host that is not managed by a vCenter Server instance.

Caveats and limitations:

- VMware does not support the use of nested ESXi hosts, namely running ESXi in virtual machines. Deploying vSphere Integrated Containers Engine to a nested ESXi host is acceptable for testing purposes only.
- If you deploy a VCH onto an ESXi host that is not managed by vCenter Server, and you then move that host into a cluster, the VCH might not function correctly.
- Clusters that do not implement DRS do not support resource pools. If you deploy a VCH to a cluster on which DRS is disabled, the VCH is created in a VM folder, rather than in a resource pool. This restricts your ability to configure resource usage limits on the VCH.

## ESXi Host Firewall Requirements <a id="firewall"></a>

To be valid targets for VCHs and container VMs, ESXi hosts must have the following firewall configuration:
- Allow outbound TCP traffic to port 2377 on the endpoint VM, for use by the interactive container shell.
- Allow inbound HTTPS/TCP traffic on port 443, for uploading to and downloading from datastores.

These requirements apply to standalone ESXi hosts and to ESXi hosts in vCenter Server clusters.

For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

## ESXi Host Storage Requirements for vCenter Server Clusters <a id="storage"></a>

All ESXi hosts in vCenter Server clusters must meet the following storage requirements in order to be usable by a VCH:

- Be attached to the datastores that you will use for image stores and volume stores. 
- Have access to shared storage to allow VCHs to use more than one host in the cluster.

For information about image stores and volumes stores, see [Virtual Container Host Storage](vch_storage.md).

## Clock Synchronization <a id="clocksync"></a>

Ensure that all vCenter Server instances and ESXi hosts in the environment in which you are deploying the appliance have network time protocol (NTP) running. Running NTP prevents problems arising from clock skew between the vSphere Integrated Containers appliance, virtual container hosts, and the vSphere infrastructure.

## User Accounts for VCH Deployment and Operation <a id="users"></a>

A VCH requires the appropriate permissions in vSphere to perform  tasks during VCH deployment and operation. Deployment of a VCH requires a user account with vSphere administrator privileges. However, day-to-day operation of a VCH requires fewer vSphere permissions than deployment. Consequently, you can configure a VCH to use different user accounts for deployment and for day-to-day operation. If you choose to use different accounts, the user account to use for day-to-day operation must exist before you deploy the VCH. For information about the operations user, see [Create the Operations User Account](create_ops_user.md).
