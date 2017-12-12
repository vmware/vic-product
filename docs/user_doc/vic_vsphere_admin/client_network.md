# Configure the Client Network #

The client network is the network on which the VCH endpoint VM makes the Docker API available to Docker clients. By designating a specific client network, you isolate Docker endpoints from the public network. Virtual container hosts (VCHs) access vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry over the client network. 

- [`vic-machine` Option](#options)
  - [Client Network](#client-network) 
  - [Static IP Address](#static-ip)
  - [Gateway](#gateway)
  - [Routing Destination](#routing)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Command](#example)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Configure Networks page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Client Network <a id="client-network"></a> 

A port group on which the VCH makes the Docker API available to Docker clients. Docker clients use this network to issue Docker API requests to the VCH.

If you do not specify this option, the VCH uses the public network for client traffic.

**Create VCH Wizard**

1. Expand the **Advanced** view.
2. Select an existing port group from the **Client network** drop-down menu.

**vic-machine Option** 

`--client-network`, `--cln`

You designate the client network by specifying the `vic-machine create --client-network` option.  

<pre>--client-network <i>port_group_name</i></pre>

 If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

### Static IP Address <a id="static-ip"></a>

By default, vSphere Integrated Containers Engine uses DHCP to obtain an IP address for the VCH endpoint VM on the client network. You can  optionally configure a static IP address for the VCH endpoint VM on the client network.

- You can only specify one static IP address on a given port group. If the client network shares a port group with the public network, you can only specify a static IP address on the public network. All of the networks that share that port group use the IP address that you specify for the public network.
- If you set a static IP address for the VCH endpoint VM on the public network, you must specify the gateway address for the public network. If the client network is L2 adjacent to its gateway, you do not need to specify the corresponding gateway for the client network.
- If the client network does not use the same port group as the public network, you can specify a static IP address for the endpoint VM on the public network. In this case, you must specify the public network gateway. 
- If the client network shares a port group with the management network, and the public network does not use that port group, you can set a static IP address for the VCH endpoint VM on either or both of the client and management networks.
- If you assign a static IP address to the VCH endpoint VM on the client network, and you do not specify one of the TLS options, vSphere Integated Containers Engine uses this address as the Common Name with which to auto-generate trusted CA certificates. If you do not specify one of the TLS options, two-way TLS authentication with trusted certificates is implemented by default when you deploy the VCH with a static IP address on the client network. If you assign a static IP address to the VCH endpoint VM on the client network, vSphere Integated Containers Engine creates the same certificate and environment variable files as described in the [`--tls-cname` option](tls_auto_certs.md#tls-cname).
 
    **IMPORTANT**: If the client network shares a port group with the public network you cannot set a static IP address for the endpoint VM on the client network. To assign a static IP address to the VCH endpoint VM you must set a static IP address on the public network. In this case, vSphere Integated Containers Engine uses the public network IP address as the Common Name with which to auto-generate trusted CA certificates, in the same way as it would if you had set a static IP on the client network.

You specify the address as an IPv4 address with a network mask.

**Create VCH Wizard**

1. Select the **Static** radio button.
2. Enter an IP address with a network mask in the **IP Address** text box, for example `192.168.3.10/24`.

**vic-machine Option** 

`--client-network-ip`, no short name

You specify addresses as IPv4 addresses with a network mask.

<pre>--client-network-ip 192.168.1.10/24</pre>

You can also specify the address as a resolvable FQDN.

<pre>--client-network-ip=vch27-team-a.internal.domain.com</pre>

### Gateway <a id="gateway"></a>

The gateway to use if you specify a static IP address for the VCH endpoint VM on the client network. 

You specify gateway addresses as IP addresses without a network mask.

**Create VCH Wizard**

Enter the IP address of the gateway, for example `198.51.100.1`.

You must enter a gateway address even if the client network is L2 adjacent to the gateway.

**vic-machine Option** 

Specify a gateway address as an IP address without a network mask in the `--client-network-gateway` option. If the client network is L2 adjacent to its gateway, you do not need to specify the gateway.

<pre>--client-network-gateway 198.51.100.1</pre>

### Routing Destination <a id="routing"></a>

The default route for the VCH endpoint VM is always on the public network. As a consequence, if you specify a static IP address on the client network and that network is not L2 adjacent to its gateway, you must specify the routing destination for that network. 

**Create VCH Wizard**

If you set a static IP address on the client network, optionally enter the routing destination as a comma-separated list of CIDRs. For example, enter `192.0.2.0/24,198.51.100.0/24`.

**vic-machine Option** 

You specify the routing destination or destinations in a comma-separated list in the `--client-network-gateway` option, with the address of the gateway separated from the routing destinations by a colon (`:`).

<pre>--client-network-gateway <i>routing_destination_1</i>,<i>routing_destination_2</i>:<i>gateway_address</i></pre>

For example:<pre>--client-network-gateway 192.0.2.0/24,198.51.100.0/24:198.51.100.1</pre>

## What to Do Next <a id="whatnext"></a>

To configure further advanced network settings, remain on the Configure Networks page, and see the following topics:

- [Configure the Management Network](mgmt_network.md)
- [Configure Container Networks](container_networks.md)
- [Configure VCHs to Use Proxy Servers](vch_proxy.md)

To apply default settings to the other networks, click **Next** to configure [VCH Security](vch_security.md) settings.

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH with the following networking configuration:

- Directs public traffic to `vch1-public` and Docker API traffic to `vch1-client`.
- Sets a DNS server for use by the public, management, and client networks.
- Sets a static IP address for the VCH endpoint VM on each of the public and client networks.
- Specifies the gateway for the public network.
- Does not specify a gateway for the client network. It is not necessary to specify a gateway on either of the client or management networks if those networks are L2 adjacent to their gateways.
- Because this example specifies a static IP address for the VCH endpoint VM on the client network, `vic-machine create` uses this address as the Common Name with which to create auto-generated trusted certificates. Full TLS authentication is implemented by default, so no TLS options are specified. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vch1-public
--public-network-ip 192.168.1.10/24
--public-network-gateway 192.168.1.1
--client-network vch1-client
--client-network-ip 192.168.3.10/24
--dns-server <i>dns_server_address</i>
--thumbprint <i>certificate_thumbprint</i>
--name vch1
</pre>