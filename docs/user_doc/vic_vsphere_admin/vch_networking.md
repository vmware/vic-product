# Virtual Container Host Networks #

You must configure networks on a virtual container host (VCH) that tie your Docker development environment into the vSphere infrastructure. You define which networks are available to a VCH when you deploy the VCH.

- [High-Level View of VCH Networking](#highlevel)
- [VCH Networks](#vchnetworks)
   - [Bridge Networks](#bridge) 
   - [Public Network](#public) 
   - [Client Network](#client) 
   - [Management Network](#mgmt) 
   - [Container Networks](#container) 
- [Host Firewall Configuration](#firewall)

## High-Level View of VCH Networking <a id="highlevel"></a>

The image below shows how VCH networks connect to your vSphere environment, to vSphere Integrated Containers Registry and Management Portal, and to public registries, such as Docker Hub. 
 
 ![VCH Networking](graphics/vic_networking.png)

## VCH Networks <a id="vchnetworks"></a>

You can direct traffic between containers, the VCH, the external Internet, and your vSphere environment to different networks. VCH network interfaces can be either standard vSphere port groups, NSX Data Center for vSphere logical switches, or NSX-T Data Center logical switches. You must create port groups or logical switches in vSphere, NSX Data Center for vSphere, or NSX-T Data Center before you deploy a VCH. 

**IMPORTANT**:  

- If you configure a VCH to use different interfaces for each of the public, management, and client networks, these networks must all be accessible by the vSphere Integrated Containers appliance. 
- All hosts in a cluster should be attached to the port groups or logical switches that you create for the VCH networks and for any mapped container networks.

For general information about VCH networking requirements, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).

You can configure static IP addresses for the VCH on the different networks, and configure VCHs to use proxy servers. For information proxy servers, see [Configure VCHs to Use Proxy Servers](vch_proxy.md).

### Bridge Networks <a id="bridge"></a>

In Docker terminology, the VCH bridge network corresponds to the default bridge network on a Docker host. You can also create additional bridge networks, that correspond to Docker user-defined networks. You must create a dedicated vSphere port group, or an NSX Datacenter for vSphere logical switch, or an NSX-T Data Center logical switch for the bridge network for every VCH. For information about VCH bridge networks, see [Configure Bridge Networks](bridge_network.md).

### Public Network <a id="public"></a>

The network that container VMs and VCHs use to access the Internet. The VCH endpoint VM must be able to obtain an IP address on this interface. You can use the same vSphere port group, or NSX Datacenter for vSphere logical switch, or NSX-T Data Center logical switch as the public network for multiple VCHs. You cannot use the same interface for the public network as you use for the bridge network.
  - If you use the Create Virtual Container Host wizard to create VCHs, it is **mandatory** to use a dedicated interface for the public network.
  - If you use `vic-machine` to deploy VCHs, by default the VCH uses the VM Network, if present, for the public network. If the VM Network is present, it is therefore not mandatory to use a dedicated interface for the public network, but it is strongly recommended. Using the default VM Network for the public network instead of a dedicated port group or logical switch prevents vSphere vMotion from moving the VCH endpoint VM between hosts in a cluster. If the VM Network is not present, you must create a dedicated interface for the public network. 
  
    You can share the public network interface with the client and management networks. For information about VCH public networks, see [Configure the Public Network](public_network.md).

### Client Network <a id="client"></a>

You can isolate traffic between Docker clients and the VCH from traffic on the public network by specifying a dedicated interface for client connections. You can use the same interface as the client network for multiple VCHs. For information about VCH client networks, see [Configure the Client Network](client_network.md).

### Management Network <a id="mgmt"></a>

You can also isolate the traffic between the VCH and vCenter Server and ESXi hosts from traffic on the public network by specifying a dedicated management network interface. You can use the same interface as the management network for multiple VCHs. For information about VCH management networks, see [Configure the Management Network](mgmt_network.md).

### Container Networks <a id="container"></a>

User-defined networks that you can use to connect container VMs directly to a routable network. Container networks allow vSphere administrators to make vSphere networks directly available to containers. Container networks are specific to vSphere Integrated Containers and have no equivalent in regular Docker, and provide distinct advantages over using Docker user-defined networks. For information about container networks, including their advantages over Docker user-defined networks, see [Configure Container Networks](container_networks.md).

## Host Firewall Configuration <a id="firewall"></a>

When you specify different network interfaces for the different types of traffic, `vic-machine create` checks that the firewalls on the ESXi hosts allow connections to port 2377 from those networks. If access to port 2377 on one or more ESXi hosts is subject to IP address restrictions, and if those restrictions block access to the network interfaces that you specify, `vic-machine create` fails with a firewall configuration error:
<pre>Firewall configuration incorrect due to allowed IP restrictions on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

For information about how to open port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).