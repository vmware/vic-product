# Deployment Prerequisites for vSphere Integrated Containers #

Before you deploy the vSphere Integrated Containers appliance and virtual container hosts (VCHs), you must ensure that the virtual infrastructure in which you are deploying it meets certain requirements.

- [License Requirements](#license)
- [Virtual Infrastructure Requirements](#vireqs)
  - [vSphere Integrated Containers Appliance Requirements](#appliancereqs)
  - [vSphere Client Requirements](#client)
  - [Supported Configurations for VCH Deployment](#configs)
  - [ESXi Host Firewall Requirements](#firewall)
  - [ESXi Host Storage Requirements for vCenter Server Clusters](#storage)
  - [Clock Synchronization](#clocksync)
- [Networking Requirements](#networkreqs)
  - [Networking Requirements for VCH Deployment](#vchnetworkreqs)
- [Custom Certificates](#customcerts)
- [User Accounts for VCH Deployment and Operation](#users)

## License Requirements <a id="license"></a>
vSphere Integrated Containers depends on certain features that are included in the following vSphere Editions:

- vSphere Enterprise Plus
- vSphere Remote Office Branch Office (ROBO) Advanced

All of the ESXi hosts in a cluster require an appropriate license. Deployment of VCHs fails if your environment includes one or more ESXi hosts that have inadequate licenses. 

## Virtual Infrastructure Requirements <a id="vireqs"></a>

The different components of vSphere Integrated Containers have different virtual infrastructure requirements.

### vSphere Integrated Containers Appliance Requirements <a id="appliancereqs"></a>

You deploy the vSphere Integrated Containers appliance on a vCenter Server instance. Deploying the appliance directly on an ESXi host is not supported.

- vCenter Server 6.0, 6.5, or 6.7.

  **NOTE**: vSphere Integrated Containers 1.4.x does not support vSphere 6.7u2. To run vSphere Integrated Containers with vSphere 6.7u2, you must upgrade to vSphere Integrated Containers 1.5.x.
- ESXi 6.0, 6.5, or 6.7 for all hosts.
- At least 2 vCPUs.
- At least 8GB RAM.
- At least 80GB free disk space on the datastore. The disk space for the appliance uses thin provisioning.

For the latest information about the compatibility of all vSphere Integrated Containers versions with vCenter Server, see the [VMware Product Interoperability Matrices](https://partnerweb.vmware.com/comp_guide2/sim/interop_matrix.php#interop&149=&2=).

### vSphere Client Requirements <a id="client"></a>

vSphere Integrated Containers provides an interactive plug-in for the HTML5 vSphere Client and a basic plug-in for the Flex-based vSphere Web Client: 

- The HTML5 plug-in for vSphere 6.5 and 6.7 allows you to deploy and interact with VCHs from the vSphere Client. The HTML5 vSphere Client plug-in for vSphere Integrated Containers requires vCenter Server 6.7 or vCenter Server 6.5.0d or later.

   **IMPORTANT**: If you use vSphere 6.7 update 1 or later, you must use vSphere Integrated Containers 1.4.3 or later. Due to significant changes in the HTML5 vSphere Client in version 6.7 update 1, previous versions of the vSphere Integrated Containers plug-in for the vSphere Client might not work with that version. Only version 1.4.3 and later releases have been verified with vSphere 6.7 update 1.
- The Flex-based plug-in for vSphere 6.0 has limited functionality and only provides basic information about VCHs and container VMs. 

### Supported Configurations for Virtual Container Host Deployment <a id="configs"></a>

You can deploy virtual container hosts (VCHs) in the following types of setup:

* vCenter Server 6.0, 6.5, or 6.7 managing a cluster of ESXi  6.0, 6.5, or 6.7 hosts. VMware recommends that you enable VMware vSphere Distributed Resource Scheduler (DRS) on clusters whenever possible, but this is not a requirement.
* vCenter Server 6.0, 6.5, or 6.7, managing one or more standalone ESXi 6.0, 6.5, or 6.7 hosts.
* Standalone ESXi 6.0, 6.5, or 6.7 host that is not managed by a vCenter Server instance.

Caveats and limitations:

- VMware does not support the use of nested ESXi hosts, namely running ESXi in virtual machines. Deploying vSphere Integrated Containers Engine to a nested ESXi host is acceptable for testing purposes only.
- If you deploy a VCH onto an ESXi host that is not managed by vCenter Server, and you then move that host into a cluster, the VCH might not function correctly.
- Clusters that do not implement DRS do not support resource pools. If you deploy a VCH to a cluster on which DRS is disabled, the VCH is created in a VM folder, rather than in a resource pool. This restricts your ability to configure resource usage limits on the VCH.

### ESXi Host Firewall Requirements <a id="firewall"></a>

To be valid targets for VCHs and container VMs, ESXi hosts must have the following firewall configuration:
- Allow outbound TCP traffic to port 2377 on the endpoint VM, for use by the interactive container shell.
- Allow inbound HTTPS/TCP traffic on port 443, for uploading to and downloading from datastores.

These requirements apply to standalone ESXi hosts and to ESXi hosts in vCenter Server clusters.

For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

### ESXi Host Storage Requirements for vCenter Server Clusters <a id="storage"></a>

All ESXi hosts in vCenter Server clusters must meet the following storage requirements in order to be usable by a VCH:

- Be attached to the datastores that you will use for image stores and volume stores. 
- Have access to shared storage to allow VCHs to use more than one host in the cluster.

For information about image stores and volumes stores, see [Virtual Container Host Storage](vch_storage.md).

### Clock Synchronization <a id="clocksync"></a>

Ensure that all vCenter Server instances and ESXi hosts in the environment in which you are deploying the appliance have network time protocol (NTP) running. Running NTP prevents problems arising from clock skew between the vSphere Integrated Containers appliance, virtual container hosts, and the vSphere infrastructure.

## Networking Requirements  <a id="networkreqs"></a>

The vSphere Integrated Containers appliance requires access to the external Internet, the vSphere Infrastructure, and to the network on which developers connect Docker clients. VCHs connect to multiple different networks, as shown in the image below.

![VCH Networking](graphics/vic_networking.png)

For more information about the networks that VCHs connect to, see [Virtual Container Host Networks](vch_networking.md)

**IMPORTANT**: If you configure a VCH to use separate networks for the public, management, and client networks, these networks must all be accessible by the vSphere Integrated Containers appliance.

### Networking Requirements for VCH Deployment <a id="vchnetworkreqs"></a>

The following network requirements apply to deployment of VCHs to standalone ESXi hosts and to vCenter Server:

- Use a trusted network for the deployment and use of vSphere Integrated Containers Engine.
- Use a trusted network for the management network. For more information about the role and requirements of the management network, see [Configure the Management Network](mgmt_network.md).
- Connections between Docker clients and the VCH are encrypted via TLS unless you explicitly disable TLS. The client network does not need to be trusted.
- Each VCH requires an IPv4 address on each of the networks that it is connected to. The bridge network is handled internally, but other interfaces must have a static IP configured on them, or be able to acquire one via DHCP.
- Each VCH requires access to at least one network, for use as the public network. You can share this network between multiple VCHs. The public network does not need to be trusted.

The following network requirements apply to the deployment of VCHs to vCenter Server: 
 
- Create a VMware vSphere Distributed Switch, and create a dedicated port group for use as the bridge network for each VCH. You can create multiple port groups on the same switch, but each VCH requires its own unique port group for the bridge network. 
  - For information about bridge networks, see [Configure Bridge Networks](bridge_network.md). 
  - For information about how to create a vSphere Distributed Switch and a port group, see [Create a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.networking.doc/GUID-D21B3241-0AC9-437C-80B1-0C8043CC1D7D.html) in the vSphere  documentation. 
  - For information about how to add hosts to a vSphere Distributed Switch, see [Add Hosts to a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.networking.doc/GUID-E90C1B0D-82CB-4A3D-BE1B-0FDCD6575725.html) in the vSphere  documentation.
- Create a port group for use as the VCH public network. The VCH endpoint VM must be able to obtain an IP address on this port group.  You can use the same port group as the public network for multiple VCHs. You cannot use the same port group for the public network as you use for the bridge network.
  - If you use the Create Virtual Container Host wizard to create VCHs, it is **mandatory** to use a port group for the public network.
  - If you use `vic-machine` to deploy VCHs, by default the VCH uses the VM Network, if present, for the public network. If the VM Network is present, it is therefore not mandatory to use a port group for the public network, but it is strongly recommended. Using the default VM Network for the public network instead of a port group prevents vSphere vMotion from moving the VCH endpoint VM between hosts in a cluster. If the VM Network is not present, you must create a port group for the public network.
  
    You can share the public network port group with the client and management networks. For information about VCH public networks, see [Configure the Public Network](public_network.md).
- Optionally create port groups for each of the management and client networks. You can use the same port group as the management and client network for multiple VCHs. For information about VCH client and management networks, see [Configure the Client Network](client_network.md) and [Configure the Management Network](mgmt_network.md).
- Optionally create port groups for use as mapped container networks. For information about container networks, see [Configure Container Networks](container_networks.md). 
- All hosts in a cluster should be attached to the port groups that you create for the VCH networks and for any mapped container networks.
- Isolate the bridge network and any mapped container networks. You can isolate networks by using a separate VLAN for each network. For information about how to assign a VLAN ID to a port group, see [VMware KB 1003825](https://kb.vmware.com/kb/1003825). For more information about private VLAN, see [VMware KB 1010691](https://kb.vmware.com/kb/1010691).

## Custom Certificates <a id="customcerts"></a>

If you intend to use a custom certificate, the vSphere Integrated Containers appliance supports PEM encoded PKCS#1 and PEM encoded PKCS#8 formats for TLS private keys. If you provide a PKCS#1 format certificate, vSphere Integrated Containers converts it to PKCS8 format. The appliance uses a single TLS certificate for all of the services that run in the appliance.

## User Accounts for VCH Deployment and Operation <a id="users"></a>

A VCH requires the appropriate permissions in vSphere to perform  tasks during VCH deployment and operation. Deployment of a VCH requires a user account with vSphere administrator privileges. However, day-to-day operation of a VCH requires fewer vSphere permissions than deployment. Consequently, you can configure a VCH to use different user accounts for deployment and for day-to-day operation. If you choose to use different accounts, the user account to use for day-to-day operation must exist before you deploy the VCH. For information about the operations user, see [Create the Operations User Account](create_ops_user.md).