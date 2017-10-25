# Specify a Static IP Address for the VCH Endpoint VM #

By default, `vic-machine create` obtains IP addresses for virtual container host (VCH) endpoint VMs by using DHCP. You can specify a static IP address for the VCH endpoint VM on the client, public, and management networks. DHCP is used for the endpoint VM for any network on which you do not specify a static IP address.

- [`vic-machine` Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

You can configure a static IP address for a VCH endpoint VM on the different networks by specifying the `vic-machine create --client-network-ip`, `--public-network-ip`, and `--management-network-ip` options when you deploy the VCH. You can also specify one or more DNS servers and gateway addresses by using the `--dns-server`, `--client-network-gateway`, `--public-network-gateway`, and `--management-network-gateway` options.

### `--dns-server` <a id="dns-server"></a>

**Short name**: None

A DNS server for the VCH endpoint VM to use on the client, public, or management networks. You can specify `dns-server` multiple times, to configure multiple DNS servers.  

- If you specify `dns-server`, `vic-machine create` uses the same `--dns-server` setting for all three of the client, public, and management networks.
- If you do not specify `dns-server` and you specify a static IP address for the VCH endpoint VM on all three of the client, public, and management networks, `vic-machine create` uses the Google public DNS service. 
- If you do not specify `dns-server` and you use DHCP for all of the client, public, and management networks, `vic-machine create` uses the DNS servers that DHCP provides.

**Usage**: 
<pre>--dns-server=172.16.10.10
--dns-server=172.16.10.11
</pre>

### `--client-network-ip`, `--public-network-ip`, `--management-network-ip`

**Short names**: None

A static IP address for the VCH endpoint VM on the public, client, or management network. 

You specify a static IP address for the endpoint VM on the public, client, or management networks by using the `--public-network-ip`, `client-network-ip`, and `management-network-ip` options. 

- You can only specify one static IP address on a given port group. If more than one of the client, public, or management networks share a port group, you can only specify a static IP address on one of those networks. All of the networks that share that port group use the IP address that you specify. 
- If you set a static IP address for the VCH endpoint VM on the public network, you must specify a corresponding gateway address by using the `--public-network-gateway` option. If the management and client networks are L2 adjacent to their gateways, you do not need to specify the corresponding gateways for those networks.
- If either of the client or management networks shares a port group with the public network, you can only specify a static IP address on the public network.
- If either or both of the client or management networks do not use the same port group as the public network, you can specify a static IP address for the endpoint VM on those networks by using `--client-network-ip` or `--management-network-ip`, or both. In this case, you must specify a corresponding gateway address by using `client/management-network-gateway`. 
- If the client and management networks both use the same port group, and the public network does not use that port group, you can set a static IP address for the endpoint VM on either or both of the client and management networks.
- If you assign a static IP address to the VCH endpoint VM on the client network by setting the `--client-network-ip` option, and you do not specify one of the TLS options, `vic-machine create` uses this address as the Common Name with which to auto-generate trusted CA certificates. If you do not specify `--tls-cname`, `--no-tls` or `--no-tlsverify`, two-way TLS authentication with trusted certificates is implemented by default when you deploy the VCH with a static IP address on the client network. If you assign a static IP address to the endpoint VM on the client network, `vic-machine create` creates the same certificate and environment variable files as described in the [`--tls-cname` option](tls_auto_certs.md#tls-cname).
 
  **IMPORTANT**: If the client network shares a port group with the public network you cannot set a static IP address for the endpoint VM on the client network. To assign a static IP address to the endpoint VM you must set a static IP address on the public network by using the `--public-network-ip` option. In this case, `vic-machine create` uses the public network IP address as the Common Name with which to auto-generate trusted CA certificates, in the same way as it would for the client network.

You specify addresses as IPv4 addresses with a network mask.

**Usage**: 
<pre>--public-network-ip 192.168.X.N/24
--management-network-ip 192.168.Y.N/24
--client-network-ip 192.168.Z.N/24
</pre>

You can also specify addresses as resolvable FQDNs.

<pre>--public-network-ip=vch27-team-a.internal.domain.com
--management-network-ip=vch27-team-b.internal.domain.com
--client-network-ip=vch27-team-c.internal.domain.com
</pre>

If you do not specify an IP address for the endpoint VM on a given network, `vic-machine create` uses DHCP to obtain an IP address for the endpoint VM on that network.

### `--client-network-gateway`, `--public-network-gateway`, `--management-network-gateway` 

**Short names**: None

The gateway to use if you use `--public/client/management-network-ip` to specify a static IP address for the VCH endpoint VM on the public, client, or management networks. If you specify a static IP address on the public network, you must specify a gateway by using the `--public-network-gateway` option. If the management and client networks are L2 adjacent to their gateways, you do not need to specify the gateway for those networks.

You specify gateway addresses as IP addresses without a network mask.

**Usage**: 
<pre>--public-network-gateway 192.168.X.1</pre>

The default route for the VCH endpoint VM is always on the public network. As a consequence, if you specify a static IP address on either of the management or client networks and those networks are not L2 adjacent to their gateways, you must specify the routing destination for those networks in the `--management-network-gateway` and `--client-network-gateway` options. You specify the routing destination or destinations in a comma-separated list, with the address of the gateway separated from the routing destinations by a colon (:).

<pre>--management-network-gateway <i>routing_destination_1</i>,
<i>routing_destination_2</i>:<i>gateway_address</i></pre>
<pre>--client-network-gateway <i>routing_destination_1</i>,
<i>routing_destination_2</i>:<i>gateway_address</i></pre>

In the following example, `--management-network-gateway` informs the VCH that it can reach all of the vSphere management endoints that are in the ranges 192.168.3.0-255 and 192.168.128.0-192.168.128.255 by sending packets to the gateway at 192.168.2.1. Ensure that the address ranges that you specify include all of the systems that will connect to this VCH instance. 

<pre>--management-network-gateway 192.168.3.0/24,192.168.128.0/24:192.168.2.1</pre>

## Example `vic-machine` Command <a id="example"></a>

If you specify networks for any or all of the public, management, and client networks, you can deploy the VCH so that the VCH endpoint VM has a static IP address on one or more of those networks.  

This example deploys a VCH with the following configuration:

- Specifies the target vCenter Server instance, the vCenter Server user name, password, datacenter and cluster, an image store, a port group for the bridge network, a name for the VCH, and the thumbprint of the vCenter Server certificate.
- Directs public and management traffic to network 1 and Docker API traffic to network 2.
- Sets a DNS server for use by the public, management, and client networks.
- Sets a static IP address and subnet mask for the VCH endpoint VM on the public and client networks. Because the management network shares a network with the public network, you only need to specify the public network IP address. You cannot specify a management IP address because you are sharing a port group between the management and public network.
- Specifies the gateway for the public network. If you set a static IP address on the public network, you must also specify the gateway address.
- Does not specify a gateway for the client network. It is not necessary to specify a gateway on either of the client or management networks if those networks are L2 adjacent to their gateways.
- Because this example specifies a static IP address for the VCH endpoint VM on the client network, `vic-machine create` uses this address as the Common Name with which to create auto-generated trusted certificates. Full TLS authentication is implemented by default, so no TLS options are specified. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network 'network 1'
--public-network-ip 192.168.1.10/24
--public-network-gateway 192.168.1.1
--management-network 'network 1'
--client-network 'network 2'
--client-network-ip 192.168.3.10/24
--dns-server <i>dns_server_address</i>
--thumbprint <i>certificate_thumbprint</i>
--name vch1
</pre>