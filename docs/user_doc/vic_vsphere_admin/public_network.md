# Configure the Public Network #

The public network is the network that container VMs and the virtual container host (VCH) use to connect to the Internet. VCHs use the public network to pull container images from public registries, for example from Docker Hub. Container VMs that use port mapping expose network services on the public network. In Docker terminology, the public network corresponds to the `eth0` interface.

- [Options](#options)
  - [Public Network](#public-network) 
  - [Static IP Address](#static-ip)
  - [Gateway](#gateway)
  - [DNS Server](#dns-server)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Command](#example)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Configure Networks page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Public Network <a id="public-network"></a>

You designate a specific port group for traffic from container VMs and the VCH to the Internet by specifying a public network when you deploy the VCH.

**IMPORTANT**: 

- By default, VCHs that you deploy by using `vic-machine` use the standard VM Network for the public network. For deployments to vCenter Server clusters, it is strongly recommended that you create and use a dedicated port group for the public network. The VCH endpoint VM must be able to obtain an IP address on this port group. Using the VM Network instead of a port group prevents vSphere vMotion from moving the VCH endpoint VM between hosts in the cluster.
- The Create Virtual Container Host wizard only allows you to select port groups. You cannot select whole networks, for example the standard VM Network. Consequently, if you use the Create Virtual Container Host wizard, you must create a port group for the public network before you deploy the VCH. You cannot use `vic-machine configure` to change the public network setting after you deploy the VCH.

If you do not configure the client and management networks to use specific port groups, those networks use the settings that you specify for the public network. 

**Create VCH Wizard**

Select an existing port group from the **Public network** drop-down menu.

**NOTE**: If you use the Create Virtual Container Host wizard, specifying a public network is **mandatory**. 

**vic-machine Option** 

`--public-network`, `--pn`

A port group that container VMs and VCHs use to connect to the Internet. Ports that containers that are connected to the default bridge network expose with `docker create -p` are made available on the public interface of the VCH endpoint VM via network address translation (NAT), so that containers can publish network services.  

**NOTE**: vSphere Integrated Containers adds a new capability to Docker that allows you to directly map containers to a network by using the `--container-network` option. This is the recommended way to deploy container services with vSphere Integrated Containers. For more information, see [Configure Container Networks](container_networks.md).

<pre>--public-network <i>port_group_name</i></pre>

If you do not specify this option, containers use the VM Network for public network traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

### Static IP Address <a id="static-ip"></a>

By default, vSphere Integrated Containers Engine uses DHCP to obtain an IP address for the VCH endpoint VM on the public network. You can  optionally configure a static IP address for the VCH endpoint VM on the public network.

- You can only specify one static IP address on a given port group. If either of the client or management networks shares a port group with the public network, you can only specify a static IP address on the public network. All of the networks that share that port group use the IP address that you specify. 
- If you set a static IP address for the VCH endpoint VM on the public network, you must specify a corresponding gateway address.

**Create VCH Wizard**

1. Select the **Static** radio button.
2. Enter an IP address with a network mask in the **IP Address** text box, for example `192.168.1.10/24`.

**vic-machine Option** 

`--public-network-ip`, no short name

You specify addresses as IPv4 addresses with a network mask.

<pre>--public-network-ip 192.168.1.10/24</pre>

You can also specify addresses as resolvable FQDNs.

<pre>--public-network-ip=vch27-team-a.internal.domain.com</pre>

### Gateway <a id="gateway"></a>

The gateway to use if you specify a static IP address for the VCH endpoint VM on the public network. If you specify a static IP address on the public network, you must specify a gateway for the public network.

You specify gateway addresses as IP addresses without a network mask.

**Create VCH Wizard**

Enter the IP address of the gateway, for example `192.168.1.1`.

**vic-machine Option** 

`--public-network-gateway`, no short name

Specify a gateway address as an IP address without a network mask in the `--public-network-gateway` option.

<pre>--public-network-gateway 192.168.1.1</pre>

### DNS Server <a id="dns-server"></a>

A DNS server for the VCH endpoint VM to use on the public, client, and management networks. 

- If you specify a DNS server, vSphere Integrated Containers Engine uses the same DNS server setting for all three of the public, client, and management networks.
- If you do not specify a DNS server and you specify a static IP address for the VCH endpoint VM on all three of the client, public, and management networks, vSphere Integrated Containers Engine uses the Google public DNS service. 
- If you do not specify a DNS server and you use DHCP for all of the client, public, and management networks, vSphere Integrated Containers Engine uses the DNS servers that DHCP provides.

**Create VCH Wizard**

Enter a comma-separated list of DNS server addresses, for example `172.16.10.10,172.16.10.11`. 

**vic-machine Option** 

`--dns-server`, None

You can specify `--dns-server` multiple times, to configure multiple DNS servers.
<pre>--dns-server 172.16.10.10
--dns-server 172.16.10.11
</pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, the bridge network and the public network are the only networks that it is mandatory to configure. 

To configure advanced network settings, remain on the Configure Networks page, and see the following topics:

- [Configure the Client Network](client_network.md)
- [Configure the Management Network](mgmt_network.md)
- [Configure Container Networks](container_networks.md)
- [Configure VCHs to Use Proxy Servers](vch_proxy.md)

To apply default settings to the other networks, click **Next** to configure [VCH Security](vch_security.md) settings.

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH that directs public network traffic to an existing port group named `vch1-public`. 
This command does not specify either of the `--management-network` or `--client-network` options. Consequently, management and client traffic also routes over `vch1-public` because those networks default to the public network setting if they are not set.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vch1-public
--public-network-ip 192.168.1.10/24
--public-network-gateway 192.168.1.1
--dns-server 172.16.10.10
--dns-server 172.16.10.11
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>