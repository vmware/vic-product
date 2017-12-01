# Deployment Prerequisites for vSphere Integrated Containers #

Before you deploy the vSphere Integrated Containers appliance and virtual container hosts (VCHs), you must ensure that the virtual infrastructure in which you are deploying it meets certain requirements.

- [License Requirements](#license)
- [Virtual Infrastructure Requirements](#vireqs)
  - [vSphere Client Requirements](#client)
  - [Supported Configurations for VCH Deployment](#configs)
  - [ESXi Host Firewall Requirements](#firewall)
  - [ESXi Host Storage Requirements for vCenter Server Clusters](#storage)
  - [Clock Synchronization](#clocksync)
- [Networking Requirements](#networkreqs)
  - [Networking Requirements for VCH Deployment](#vchnetworkreqs)
- [Custom Certificates](#customcerts)

## License Requirements <a id="license"></a>
vSphere Integrated Containers requires a vSphere Enterprise Plus license.

All of the ESXi hosts in a cluster require an appropriate license. Deployment of VCHs fails if your environment includes one or more ESXi hosts that have inadequate licenses. 

## Virtual Infrastructure Requirements <a id="vireqs"></a>

You deploy the vSphere Integrated Containers appliance on a vCenter Server instance. Deploying the appliance directly on an ESXi host is not supported.

- vCenter Server 6.0 or 6.5.
- ESXi 6.0 or 6.5 for all hosts.
- At least 2 vCPUs.
- At least 8GB RAM.
- At least 80GB free disk space on the datastore. The disk space for the appliance uses thin provisioning.

### vSphere Client Requirements <a id="client"></a>

vSphere Integrated Containers provides a basic plug-in for the Flex-based vSphere Web Client and a more feature-complete plug-in for the HTML5 vSphere Client: 

- The Flex-based plug-in for vSphere 6.0 and 6.5 has limited functionality and only provides information about VCHs and container VMs. 
- The HTML5 plug-in for vSphere 6.5 has a more extensive feature set that allows you to deploy and interact with VCHs. The HTML5 vSphere Client plug-in for vSphere Integrated Containers requires vCenter Server 6.5.0d or later.

### Supported Configurations for Virtual Container Host Deployment <a id="configs"></a>

You can deploy virtual container hosts (VCHs) in the following types of setup:

* vCenter Server 6.0 or 6.5, managing a cluster of ESXi 6.0 or 6.5 hosts, with VMware vSphere Distributed Resource Scheduler&trade; (DRS) enabled.
* vCenter Server 6.0 or 6.5, managing one or more standalone ESXi 6.0 or 6.5 hosts.
* Standalone ESXi 6.0 or 6.5 host that is not managed by a vCenter Server instance.

Caveats and limitations:

- VMware does not support the use of nested ESXi hosts, namely running ESXi in virtual machines. Deploying vSphere Integrated Containers Engine to a nested ESXi host is acceptable for testing purposes only.
- If you deploy a VCH onto an ESXi host that is not managed by vCenter Server, and you then move that host into a cluster, the VCH might not function correctly.

### ESXi Host Firewall Requirements <a id="firewall"></a>

To be valid targets for VCHs and container VMs, ESXi hosts must have the following firewall configuration:
- Allow outbound TCP traffic to port 2377 on the endpoint VM, for use by the interactive container shell.
- Allow inbound HTTPS/TCP traffic on port 443, for uploading to and downloading from datastores.

These requirements apply to standalone ESXi hosts and to ESXi hosts in vCenter Server clusters.

For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

### ESXi Host Storage Requirements for vCenter Server Clusters <a id="storage"></a>

ESXi hosts in vCenter Server clusters must meet the following storage requirements in order to be usable by a VCH:
- Be attached to the datastores that you will use for image stores and volume stores. 
- Have access to shared storage to allow VCHs to use more than one host in the cluster.

For information about image stores and volumes stores, see [Virtual Container Host Storage](vch_storage.md).

### Clock Synchronization <a id="clocksync"></a>

Ensure that all vCenter Server instances and ESXi hosts in the environment in which you are deploying the appliance have network time protocol (NTP) running. Running NTP prevents problems arising from clock skew between the vSphere Integrated Containers appliance, virtual container hosts, and the vSphere infrastructure.

## Networking Requirements  <a id="networkreqs"></a>

The vSphere Integrated Containers appliance requires access to the external Internet, the vSphere Infrastructure, and to the network on which developers connect Docker clients. VCHs connect to multiple different networks, as shown in the image below.

![VCH Networking](graphics/vic_networking.png)

For more information about the networks that VCHs connect to, see [Virtual Container Host Networking](vch_networking.md)

**IMPORTANT**: If you configure a VCH to use separate networks for the public, management, and client networks, these networks must be accessible by the vSphere Integrated Containers appliance.

### Networking Requirements for VCH Deployment <a id="vchnetworkreqs"></a>

The following network requirements apply to deployment of VCHs to standalone ESXi hosts and to vCenter Server:

- Use a trusted network for the deployment and use of vSphere Integrated Containers Engine.
- Use a trusted network for the management network. For more information about the role and requirements of the management network, see [Configure the Management Network](mgmt_network.md).
- Connections between Docker clients and the VCH are encrypted via TLS unless you explicitly disable TLS. The client network does not need to be trusted.
- Each VCH requires an IPv4 address on each of the networks that it is connected to. The bridge network is handled internally, but other interfaces must have a static IP configured on them, or be able to acquire one via DHCP.
- Each VCH requires access to at least one network, for use as the public network. You can share this network between multiple VCHs. The public network does not need to be trusted.

The following network requirements apply to the deployment of VCHs to vCenter Server: 
 
- Create a distributed virtual switch with a port group for each VCH, for use as the bridge network. You can create multiple port groups on the same distributed virtual switch, but each VCH requires its own port group for the bridge network. 
  - For information about bridge networks, see [Configure Bridge Networks](bridge_network.md). 
  - For information about how to create a distributed virtual switch and a port group, see [Create a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-D21B3241-0AC9-437C-80B1-0C8043CC1D7D.html) in the vSphere  documentation. 
  - For information about how to add hosts to a distributed virtual switch, see [Add Hosts to a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-E90C1B0D-82CB-4A3D-BE1B-0FDCD6575725.html) in the vSphere  documentation.
- Optionally create port groups for use as mapped container networks. For information about container networks, see [Configure Container Networks](container_networks.md). 
- Optionally create port groups for each of the public, management, and client networks.
- All hosts in a cluster must be attached to the port groups that you will use for the VCH bridge network and for any mapped container networks.
- Isolate the bridge network and any mapped container networks. You can isolate networks by using a separate VLAN for each network. For information about how to assign a VLAN ID to a port group, see [VMware KB 1003825](https://kb.vmware.com/kb/1003825). For more information about private VLAN, see [VMware KB 1010691](https://kb.vmware.com/kb/1010691).

## Custom Certificates <a id="customcerts"></a>

If you intend to use custom certificates, vSphere Integrated Containers Management Portal requires the TLS private key to be supplied as a PEM-encoded PKCS#8-formatted file. For information about how to convert keys to the correct format, see [Converting Keys for Use with vSphere Integrated Containers Management Portal](vic_cert_reference.md#convertkeys).
