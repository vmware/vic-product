# Virtual Container Host Networks #

You must configure networks on a virtual container host (VCH) that tie your Docker development environment into the vSphere infrastructure. You define the networks that are available to a VCH when you deploy the VCH.

- [Bridge Networks](#bridge) 
- [Public Network](#public) 
- [Client Network](#client) 
- [Management Network](#mgmt) 
- [Container Networks](#container) 
- [Host Firewall Configuration](#firewall)

You can direct traffic between containers, the VCH, the external Internet, and your vSphere environment to different networks. VCH network interfaces can be either standard vSphere port groups, NSX Data Center for vSphere logical switches, or NSX-T Data Center logical switches. You can only use NSX Data Center for vSphere and NSX-T Data Center logical switches when deploying VCHs to vCenter Server. You cannot use logical switches when deploying VCHs directly to ESXi hosts. 

**IMPORTANT**: For information about VCH networking requirements, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).

## Bridge Networks <a id="bridge"></a>

In Docker terminology, the VCH bridge network corresponds to the default bridge network on a Docker host. You must create a dedicated vSphere port group, or an NSX Datacenter for vSphere logical switch, or an NSX-T Data Center logical switch for the bridge network for every VCH. For information about VCH bridge networks, see [Configure Bridge Networks](bridge_network.md).

## Public Network <a id="public"></a>

The network that container VMs and VCHs use to access the Internet. The VCH endpoint VM must be able to obtain an IP address on this network. You can use the same vSphere port group, or NSX Datacenter for vSphere logical switch, or NSX-T Data Center logical switch as the public network for multiple VCHs. You cannot use the same network for the public network as you use for the bridge network.

You can share the public network with the client and management networks. For information about VCH public networks, see [Configure the Public Network](public_network.md).

## Client Network <a id="client"></a>

You can isolate traffic between Docker clients and the VCH from traffic on the public network by specifying a dedicated network interface for client connections. You can use the same network as the client network for multiple VCHs. For information about VCH client networks, see [Configure the Client Network](client_network.md).

## Management Network <a id="mgmt"></a>

You can also isolate the traffic between the VCH and vCenter Server and ESXi hosts from traffic on the public network by specifying a dedicated management network interface. You can use the same network as the management network for multiple VCHs. For information about VCH management networks, see [Configure the Management Network](mgmt_network.md).

## Container Networks <a id="container"></a>

User-defined networks that you can use to connect container VMs directly to a routable network. Container networks allow vSphere administrators to make vSphere networks directly available to containers. Container networks are specific to vSphere Integrated Containers and have no equivalent in regular Docker, and provide distinct advantages over using Docker user-defined networks. For information about container networks, including their advantages over Docker user-defined networks, see [Configure Container Networks](container_networks.md).

## Proxy Servers <a id="proxy"></a>

For information about configuring VCHs to use proxy servers, see [Configure VCHs to Use Proxy Servers](vch_proxy.md).

## Host Firewall Configuration <a id="firewall"></a>

When you specify different networks for the different types of traffic, `vic-machine create` checks that the firewalls on the ESXi hosts allow connections to port 2377 from those networks. If access to port 2377 on one or more ESXi hosts is subject to IP address restrictions, and if those restrictions block access to the networks that you specify, `vic-machine create` fails with a firewall configuration error:
<pre>Firewall configuration incorrect due to allowed IP restrictions on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

For information about how to open port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).