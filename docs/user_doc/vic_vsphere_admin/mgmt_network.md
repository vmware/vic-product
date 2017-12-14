# Configure the Management Network #

The management network is the network on which the VCH endpoint VM connects to vCenter Server and ESXi hosts. By designating a specific management network, you isolate connections to vSphere resources from the public network. The VCH uses this network to provide the `attach` function of the Docker API. 

- [Options](#options)
  - [Management Network](#management-network) 
  - [Static IP Address](#static-ip)
  - [Gateway](#gateway)
  - [Routing Destination](#routing)
  - [Asymmetric Routes](#asymmetric-routes)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Command](#example)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Configure Networks page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

###  Management Network <a id="management-network"></a>

A port group that the VCH uses to communicate with vCenter Server and ESXi hosts. Container VMs use this network to communicate with the VCH.

**IMPORTANT**: 

- The port group must exist before you create the VCH. For information about how to create a VMware vSphere Distributed Switch and a port group, see [Create a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-D21B3241-0AC9-437C-80B1-0C8043CC1D7D.html) in the vSphere documentation.
- All hosts in a cluster must be attached to the port group. For information about how to add hosts to a vSphere Distributed Switch, see [Add Hosts to a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-E90C1B0D-82CB-4A3D-BE1B-0FDCD6575725.html) in the vSphere  documentation.
- Because the management network provides access to your vSphere environment, and because container VMs use this network to communicate with the VCH, always use a secure network for the management network.
- Container VMs communicate with the VCH endpoint VM over the management network when an interactive shell is required. While the communication is encrypted, the public keys are not validated, which leaves scope for man-in-the-middle attacks. This connection is only used when the interactive console is enabled (`stdin`/`out`/`err`), and not for any other purpose. 
- Ideally, use separate networks for the management network and container networks. 
- The most secure setup is to make sure that VCHs can access vCenter Server and ESXi hosts directly over the management network, and that the management network has route entries for the subnets that contain both the target vCenter Server and the corresponding ESXi hosts. If the management network does not have route entries for the vCenter Server and ESXi host subnets, you must configure asymmetric routing. For more information about asymmetric routing, see [Asymmetric Routes](#asymmetric-routes). 

When you create a VCH, `vic-machine create` checks that the firewall on ESXi hosts allows connections to port 2377 from the management network of the VCH. If access to port 2377 on ESXi hosts is subject to IP address restrictions, and if those restrictions block access to the management network interface, `vic-machine create` fails with a firewall configuration error:
<pre>Firewall configuration incorrect due to allowed IP restrictions on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

For information about how to open port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

**NOTE**: If the management network uses DHCP, `vic-machine` checks the firewall status of the management network before the VCH receives an IP address. It is therefore not possible to fully assess whether the firewall permits the IP address of the VCH. In this case, `vic-machine create` issues a warning. 

<pre>Unable to fully verify firewall configuration due to DHCP use on management network 
VCH management interface IP assigned by DHCP must be permitted by allowed IP settings 
Firewall allowed IP configuration may prevent required connection on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

If you do not specify a management network, the VCH uses the public network for management traffic.

#### Create VCH Wizard

1. Expand the **Advanced** view.
2. Select an existing port group from the **Management network** drop-down menu.

#### vic-machine Option 

`--management-network`, `--mn`

You designate a specific network for traffic between the VCH and vSphere resources by specifying the `vic-machine create --management-network` option when you deploy the VCH. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

<pre>--management-network <i>port_group_name</i></pre>

### Static IP Address <a id="static-ip"></a>

By default, vSphere Integrated Containers Engine uses DHCP to obtain an IP address for the VCH endpoint VM on the management network. You can  optionally configure a static IP address for the VCH endpoint VM on the management network.

- You can only specify one static IP address on a given port group. If the management network shares a port group with the public network, you can only specify a static IP address on the public network. All of the networks that share that port group use the IP address that you specify for the public network. 
- If you set a static IP address for the VCH endpoint VM on the public network, you must specify the gateway address for the public network. If the management network is L2 adjacent to its gateway, you do not need to specify the corresponding gateway for the management network.
- If the management network shares a port group with the client network, and the public network does not use that port group, you can set a static IP address for the VCH endpoint VM on either of the client or management networks. 
- If the client and management networks both use the same port group, and the public network does not use that port group, you can set a static IP address for the endpoint VM on either or both of the client and management networks.

You specify the address as an IPv4 address with a network mask. 

#### Create VCH Wizard

1. Select the **Static** radio button.
2. Enter an IP address with a network mask in the **IP Address** text box, for example `192.168.3.10/24`.

The Create Virtual Container Host wizard only accepts an IP address for the management network. You cannot specify an FQDN.

#### vic-machine Option 

`--management-network-ip`, no short name

You can specify addresses as IPv4 addresses with a network mask.

<pre>--management-network-ip 192.168.3.10/24</pre>

You can also specify addresses as resolvable FQDNs.

<pre>--management-network-ip=vch27-team-b.internal.domain.com</pre>

### Gateway <a id="gateway"></a>

The gateway to use if you specify a static IP address for the VCH endpoint VM on the management network.

You specify gateway addresses as IP addresses without a network mask.

#### Create VCH Wizard

Enter the IP address of the gateway in the **Gateway** text box, for example `192.168.3.1`.

You must enter a gateway address even if the client network is L2 adjacent to the gateway.

#### vic-machine Option 

`--management-network-gateway`, no short name

Specify a gateway address as an IP address without a network mask. If the client network is L2 adjacent to its gateway, you do not need to specify the gateway.

<pre>--management-network-gateway 192.168.3.1</pre>

### Routing Destination <a id="routing"></a>

The default route for the VCH endpoint VM is always on the public network. As a consequence, if you specify a static IP address on the management network and that network is not L2 adjacent to its gateway, you must specify the routing destination for that network. You specify a routing destination as a comma-separated list of CIDRs.  

For example, setting a routing destination of `192.168.3.0/24,192.168.128.0/24` informs the VCH that it can reach all of the vSphere management endoints that are in the ranges 192.168.3.0-255 and 192.168.128.0-192.168.128.255 by sending packets to the specified gateway.

Ensure that the address ranges that you specify include all of the systems that will connect to this VCH instance. 

#### Create VCH Wizard

If you set a static IP address and gateway on the management network, optionally enter a comma-separated list of CIDRs in the **Routing destination** text box. 

For example, enter `192.168.3.0/24,192.168.128.0/24`.

#### vic-machine Option

You specify the routing destination or destinations in a comma-separated list in the `--management-network-gateway` option, with the address of the gateway separated from the routing destinations by a colon (`:`).

<pre>--management-network-gateway <i>routing_destination_1</i>,
<i>routing_destination_2</i>:<i>gateway_address</i></pre>

This example informs the VCH that it can reach all of the vSphere management endoints that are in the ranges 192.168.3.0-255 and 192.168.128.0-192.168.128.255 by sending packets to the gateway at 192.168.3.1.

<pre>--management-network-gateway 192.168.3.0/24,192.168.128.0/24:192.168.3.1</pre>

### Asymmetric Routes <a id="asymmetric-routes"></a>

You can route incoming connections from ESXi hosts to VCHs over the public network rather than over the management network by configuring asymmetric routes. 

This option allows containers on bridge networks to indirectly access assets on the management or client networks via the public interface, if those assets are routable from the public network. If the management network does not have route entries for the vCenter Server and ESXi host subnets, and you do not set `--asymmetric-routes`, containers that run without specifying `-d` remain in the starting state.

In this scenario, use the `--asymmetric-routes` option to allow management traffic from ESXi hosts to the VCH to pass over the public network. By setting the `--asymmetric-routes` option, you set reverse path forwarding in the VCH endpoint VM to loose mode rather than the default strict mode. For information about reverse path forwarding and loose mode, see https://en.wikipedia.org/wiki/Reverse_path_forwarding.

#### Create VCH Wizard

You cannot configure asymmetric routes in the Create Virtual Container Host wizard.

#### vic-machine Option 

`--asymmetric-routes`, `--ar`

The `--asymmetric-routes` option takes no arguments. If you do not set `--asymmetric-routes`, all management traffic is routed over the management network.

<pre>--asymmetric-routes</pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, the bridge network and the public network are the only networks that it is mandatory to configure.

- To configure further advanced network settings, remain on the Configure Networks page, and see the following topics:
  - [Configure the Client Network](client_network.md)
  - [Configure VCHs to Use Proxy Servers](vch_proxy.md)
  - [Configure Container Networks](container_networks.md)
- If you have finished configuring the network settings, click **Next** to configure [VCH Security](vch_security.md) settings.

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH with the following configuration:

- Directs public, client, and management traffic to networks `vch1-public`, `vch1-client`, and `vch1-management` respectively.
- Sets two DNS servers for use by the public, management, and client networks.
- Sets a static IP address and subnet mask for the VCH endpoint VM on the public, client, and management networks. 
- Specifies the gateway for the public network.
- Specifies a gateway and routing destinations for the client and management networks.
- Because this example specifies a static IP address for the VCH endpoint VM on the client network, `vic-machine create` uses this address as the Common Name with which to create auto-generated trusted certificates. Full TLS authentication is implemented by default, so no TLS options are specified. 
- Specifies `--asymmetric-routes` to allow incoming connections from ESXi hosts to VCHs over the public network rather than over the management network.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vch1-public
--public-network-ip 192.168.1.10/24
--public-network-gateway 192.168.1.1
--client-network vch1-client
--client-network-ip 192.168.2.10/24
--client-network-gateway 192.168.2.0/24,192.168.128.0/24:192.168.2.1
--management-network vch1-mgmt
--management-network-ip 192.168.3.10/24
--management-network-gateway 192.168.3.0/24,192.168.128.0/24:192.168.3.1
--dns-server 192.168.10.10
--dns-server 192.168.10.11
--thumbprint <i>certificate_thumbprint</i>
--name vch1
--asymmetric-routes
</pre>