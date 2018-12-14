# Networking Requirements #

- [Appliance Networking Requirements](#networkreqs)
- [Ports and Protocols](#ports)
- [Understanding Docker and VCH Networking](#understanding)
- [Networking Requirements for VCH Deployment](#vchnetworkreqs)

## Appliance Networking Requirements <a id="networkreqs"></a>

The vSphere Integrated Containers appliance requires access to the external Internet, the vSphere Infrastructure, and to the network on which developers connect Docker clients. VCHs connect to multiple different networks, as shown in the image below.

![VCH Networking](graphics/vic_networking.png)

**IMPORTANT**: If you configure a VCH to use separate networks for the public, management, and client networks, these networks must all be accessible by the vSphere Integrated Containers appliance.

## Ports and Protocols <a id="ports"></a>

The image below shows detailed information how different entities that are part of a vSphere Integrated Containers environment communicate with each other. 

 ![Networking Ports and Protocols](graphics/Network-protocols.png)

## Understanding Docker and VCH Networking <a id="understanding"></a>

To understand how you can configure networks on VCHs, you first must understand how networking works in Docker.

For an overview of Docker networking in general, and an overview of networking with vSphere Integrated Containers in particular, watch the Docker Networking Options and vSphere Integrated Containers Networking Overview videos on the [VMware Cloud-Native YouTube Channel](https://www.youtube.com/channel/UCdkGV51Nu0unDNT58bHt9bg):

<table>
				<tbody>
					<tr>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=Yr6-2ddhLVo' | noembed }}<!--EndFragment--></td>
						<td><!--StartFragment-->{{ 'https://www.youtube.com/watch?v=QLi9KasWLCM' | noembed }}<!--EndFragment--></td>
					</tr>
				</tbody>
			</table>


See also [Docker container networking](https://docs.docker.com/engine/userguide/networking/) in the Docker documentation.

## Networking Requirements for VCH Deployment <a id="vchnetworkreqs"></a>

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