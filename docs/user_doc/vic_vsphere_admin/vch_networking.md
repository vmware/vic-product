# Virtual Container Host Networking #

You can configure networks on a virtual container host (VCH) that tie your Docker development environment into the vSphere infrastructure. You define which networks are available to a VCH when you use `vic-machine create` to deploy the VCH.

- [High-Level View of VCH Networking](#highlevel)
- [Understanding Docker and VCH Networking](#understanding)
- [VCH Networks](#vchnetworks)
- [Networking Limitations](#limitations)
- [Host Firewall Configuration](#firewall)

## High-Level View of VCH Networking <a id="highlevel"></a>

The image below shows how VCH networks connect to your vSphere environment, to vSphere Integrated Containers Registry and Management Portal, and to public registries, such as Docker Hub. 
 
 ![VCH Networking](graphics/vic_networking.png)

## Understanding Docker and VCH Networking <a id="understanding"></a>

To understand how you can configure networks on VCHs, you first must understand how networking works in Docker.

For an overview of Docker networking in general, and an overview of networking with vSphere Integrated Containers in particular, watch the Docker Networking Options and vSphere Integrated Containers Networking Overview videos on the [VMware Cloud-Native YouTube Channel](https://www.youtube.com/channel/UCdkGV51Nu0unDNT58bHt9bg):

[![Docker Networking Options video](graphics/docker_networking_small.jpg)](https://www.youtube.com/watch?v=Yr6-2ddhLVo)  [![vSphere Integrated Containers Networking Overview video](graphics/vic_networking_video_small.jpg)](https://www.youtube.com/watch?v=QLi9KasWLCM)

See also [Docker container networking](https://docs.docker.com/engine/userguide/networking/) in the Docker documentation.

## VCH Networks <a id="vchnetworks"></a>

You can direct traffic between containers, the VCH, the external Internet, and your vSphere environment to different networks. Each network that a VCH uses is a distributed port group or an NSX logical switch on either a vCenter Server instance or an ESXi host. You must create the port groups or logical switches in vSphere before you deploy a VCH. For information about how to create a distributed virtual switch and port group, see the section on Networking Requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md#networkreqs).

- **Public Network:** The network that container VMs and VCHs use to access the Internet. For information about VCH public networks, see [Configure the Public Network](public_network.md).
- **Bridge Networks**: In Docker terminology, the VCH bridge network corresponds to the default bridge network on a Docker host. You can also create additional bridge networks, that correspond to Docker user-defined networks. For information about VCH bridge networks, see [Configure Bridge Networks](bridge_network.md).
- **Client Network**: You can isolate traffic between Docker clients and the VCH from traffic on the public network by specifying a dedicated network for client connections. For information about VCH client networks, see  [Configure the Client Network](client_network.md).
- **Management Network**: You can also isolate the traffic between the VCH and vCenter Server and ESXi hosts from traffic on the public network by specifying a dedicated management network. For information about VCH management networks, see  [Configure the Management Network](mgmt_network.md).
- **Container Networks**: User-defined networks that you can use to connect container VMs directly to a routable network. Container networks allow vSphere administrators to make vSphere networks directly available to containers. Container networks are specific to vSphere Integrated Containers and have no equivalent in regular Docker. For information about container networks, see [Configure Container Networks](container_networks.md).

You can configure static IP addresses for the VCH on the different networks, and configure VCHs to use proxy servers. For more information about static IP addresses and proxy servers, see [Specify a Static IP Address for the VCH Endpoint VM](vch_static_ip.md) and [Configure VCHs to Use Proxy Servers](vch_proxy.md).

## Networking Limitations <a id="limitations"></a>

A VCH supports a maximum of 3 distinct network interfaces. The bridge network requires its own port group, so at least two of the public, client, and management networks must share a network interface and therefore a port group. Container networks do not go through the VCH, so they are not subject to this limitation. This limitation will be removed in a future release

## Host Firewall Configuration <a id="firewall"></a>

When you specify different network interfaces for the different types of traffic, `vic-machine create` checks that the firewalls on the ESXi hosts allow connections to port 2377 from those networks. If access to port 2377 on one or more ESXi hosts is subject to IP address restrictions, and if those restrictions block access to the network interfaces that you specify, `vic-machine create` fails with a firewall configuration error:
<pre>Firewall configuration incorrect due to allowed IP restrictions on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

For information about how to open port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).