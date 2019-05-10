# Configure Container Networks #

Container networks are vSphere networks that the vSphere administrator makes directly available to container VMs. When you deploy a virtual container host (VCH), you provide a mapping of the vSphere network name to an alias that the VCH endpoint VM uses. You can share one network alias between multiple containers. 

The mapped networks are available for use by the Docker API. 
Running `docker network ls` lists the container networks, and container developers can attach them to containers in the normal way by using commands such as `docker run` or `create` with the `--network=mapped-network-name` option, or `docker network connect`. 

**IMPORTANT**: 

- For information about VCH networking requirements, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).
- If you use NSX-T Data Center logical switches, you might need a T1 router, for example to bridge overlay and underlay networks.

## Advantages of Container Networks<a id="advantages"></a>

By using container networks, you can connect container VMs to any specific distributed port group or logical switch, which gives the container VMs their own dedicated connection to the network. Container networks allow containerized applications to get their own routable IP address and become first class citizens of your datacenter. Using container networks provides you with the following advantages: 

- **No single point of failure**: Every container VM has its own dedicated network connection, so even if the VCH endpoint VM fails there is no outage for your applications. If containers use port mapping, the containers are accessible over a network via a port on the VCH endpoint VM. If the endpoint VM goes down for any reason, that network connection is no longer available. If you use container networks, containers have their own identity on the container network. Consequently, the network and the container have no dependency on the VCH endpoint VM for execution. 
- **Network bandwidth sharing**: Every container VM gets its own network interface and all of the bandwidth it can provide is available to the application. Traffic does not route though the VCH endpoint VM via network address translation (NAT) and containers do not share the public IP of the VCH.
- **No NAT conflicts**: There is no need for port mapping because every container VM gets its own IP address. Container services are directly exposed on the network without NAT, so applications that once could not run on containers can now run by using vSphere Integrated Containers. 
- **No port conflicts**: Since every container VM gets its own IP address, you can have multiple application containers that require an exclusive port running on the same VCH. 

**NOTE**: You can add or reconfigure container networks after you have deployed a VCH by using the `vic-machine configure --container-network` options. For information about adding or reconfiguring container networks, see Configure Container Network Settings in [Configure Running Virtual Container Hosts](configure_vch.md#containernet).

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Configure Networks page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Container Network  <a id="container-network"></a>

A port group or logical switch for container VMs to use for external communication when container developers  run `docker run` or `docker create` with the `--net` option. 

**IMPORTANT**: For security reasons, whenever possible, use separate networks for the container network and the management network.

To specify a container network, you provide the name of a port group or logical switch for the container VMs to use, and an optional descriptive name for the container network for use by Docker.  If you do not specify a descriptive name, Docker uses the vSphere network name. 

- The port group or logical switch must exist before you create the VCH. For information about how to create a port group or logical switch, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).
- Isolate the mapped container networks by using a separate VLAN for each network. 
- You cannot use the same network as you use for the bridge network. 
- If the port group or logical switch that you specify does not support DHCP, you must configure an [IP Address Range](#ip-range) for the containers to use.
- The descriptive name that you provide appears under `Networks` when you run `docker info` or `docker network ls` on the deployed VCH. The descriptive name cannot include spaces. The descriptive name is optional unless the network name contains spaces. If the network name contains spaces, you must specify a descriptive name.
- Container developers use the descriptive name in the `--net` option when they run `docker run` or `docker create`.
- If you use shared NFS share points as volumes stores, it is recommended to make the NFS target accessible from the container network. If you use NFS volume stores and you do not specify a container network, containers use NAT to route traffic to the NFS target through the VCH endpoint VM. This can create potential bottlenecks and a single point of failure. 

You can specify multiple container networks to add multiple vSphere networks to Docker.

If you do not specify container networks, or if you deploy containers that do not use a container network, the containers' network services are still be available via port mapping through the VCH, by using NAT through the public network of the VCH.

#### Create VCH Wizard

1. Expand the **Advanced** view.
2. Select an existing port group or logical switch from the **Container network** drop-down menu.
3. In the **Label** text box, enter a descriptive name for use by Docker.

#### vic-machine Option

`--container-network` `--cn`

You use the `vic-machine create --container-network` option to specify an existing port group or logical switch for the container network, and a descriptive name for the network for use by Docker.

<pre>--container-network <i>port_group_or_logical_switch_name</i>:<i>descriptive_name</i></pre>

You can specify `--container-network` times to add multiple vSphere networks to Docker. If you specify an invalid port group or logical switch name, `vic-machine create` fails and suggests valid port groups or logical switches.

### IP Address Range <a id="ip-range"></a>

The range of IP addresses that container VMs can use if the network that you specify as a container network does not support DHCP. If you specify an IP address range, VCHs manage the addresses for containers within that range. 

- The range that you specify must not be used by other computers or VMs on the network. 
- You must specify an IP address range if container developers need to deploy containers with static IP addresses. 
- If you specify a gateway for a container network but do not specify an IP address range, the IP range for container VMs is the entire subnet that you specify in the gateway. 

**NOTE**:

If you use a network container that supports DHCP and the Docker run command to deploy the container, you must specify the DNS server for the container to get an IP address from DHCP server. If you do not specify a DNS server, the command times out with the following error:
 
`docker: Error response from daemon: Server error from portlayer: unable to wait for process launch status`

#### Create VCH Wizard

1. If the container network does not support DHCP, select the **IP Range** radio button.
2. Enter an IP address range or CIDR in the  **IP Range** text box. 

 - Example IP address range: `192.168.100.2-192.168.100.254`
 - Example CIDR: `192.168.100.0/24`

#### vic-machine Option 

`--container-network-ip-range`, `--cnr`

When you specify the container network IP range, you use the network that you specify in the `--container-network` option and specify either an IP address range or a CIDR:

<pre>--container-network-ip-range <i>port_group_or_logical_switch_name</i>:192.168.100.2-192.168.100.254</pre>
<pre>--container-network-ip-range <i>port_group_or_logical_switch_name</i>:192.168.100.0/24</pre>

If you specify `--container-network-ip-range` but you do not specify `--container-network`, or if you specify a different network to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

### Gateway <a id="gateway"></a>

If the network that you specify as a container network does not support DHCP, you must specify a gateway for the subnet of the container network.

#### Create VCH Wizard

Enter an IP address with a network mask in the **Gateway** text box, for example `192.168.100.10/24`.

#### vic-machine Option 

`--container-network-gateway`, `--cng`

Specify the IP address and network mask for the gateway in the `--container-network-gateway` option. When you specify the container network gateway, you must use the network that you specify in the `--container-network` option.

<pre>--container-network-gateway <i>port_group_or_logical_switch_name</i>:192.168.100.1/24</pre>

If you specify `--container-network-gateway` but you do not specify `--container-network`, or if you specify a different network to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

### DNS <a id="dns"></a>

If you specify an IP address range and gateway for a container network, it is recommended that you also specify one or more DNS servers.

#### Create VCH Wizard

Enter a comma-separated list of DNS server addresses in the **DNS server** text box, for example `192.168.100.10,192.168.100.11`. 

#### vic-machine Option 

`--container-network-dns`, `--cnd`

You specify the container network DNS server in the `--container-network-dns` option. You must use the network that you specify in the `--container-network` option. 

<pre>--container-network-dns <i>port_group_or_logical_switch_name</i>:8.8.8.8</pre>

You can specify `--container-network-dns` multiple times, to configure multiple DNS servers. If you specify `--container-network-dns` but you do not specify `--container-network`, or if you specify a different network to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

## Firewall Policy <a id="container-network-firewall"></a>

You can configure the trust level of container networks. The following table describes the levels of trust that you can set.

|Trust Level|Description|
|---|---|
|`closed`|No traffic can come in or out of the container network, even if developers expose ports on containers. |
|`outbound`|Only outbound connections are permitted. Use this setting if the VCH will host applications that consume but do not provide services.|
|`peers`|Only connections to other containers with the same `peers` network are permitted. To enforce the `peers` trust level, you must set the `--container-network-ip-range` on the container network. The VCH applies a network rule so that container traffic is only allowed over that IP range. If you do not specify an IP range, the container network uses DHCP and there is no way that the VCH can determine whether or not a container at a given IP address is a peer to another container. In this case, the VCH defaults to the `open` setting, and it treats all connections as peer connections. Use the `peers` setting for container VMs that need to communicate with each other but not with the external world.|
|`published`|Only connections to published ports is permitted.|
|`open`|All traffic is permitted and developers can decide which ports to expose.|

If you do not set a trust level, the default level of trust is `published`. As a consequence, if you do not set a trust level, container developers must explicitly specify `-p 80` in `docker run` and `docker create` commands to publish port 80 on a container. Obliging developers to specify the ports to expose improves security and gives you more awareness of your environment and applications. 

You can use `vic-machine configure --container-network-firewall` to change the trust level after deployment of the VCH. For information about configuring container network firewalls, see *Configure Container Network Settings* in [Configure Running Virtual Container Hosts](configure_vch.md#containernet).

### Create VCH Wizard

Leave the default policy of **Published**, or use the **Firewall policy** drop-down menu to select **Closed**, **Outbound**, **Peers**, or **Open**.

### vic-machine Option  

`--container-network-firewall`, `--cnf`

You specify the trust level in the `--container-network-firewall` option. You must use the port group that you specify in the `--container-network` option.

<pre>--container-network-firewall <i>port_group_or_logical_switch_name</i>:<i>trust_level</i></pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, the bridge network and the public network are the only networks that it is mandatory to configure.

- Optionally click the **+** button to add more container networks to the VCH, and repeat the procedures for each additional container network.
- To configure further advanced network settings, remain on the Configure Networks page, and see the following topics:
  - [Configure the Client Network](client_network.md)
  - [Configure the Management Network](mgmt_network.md)
  - [Configure VCHs to Use Proxy Servers](vch_proxy.md)
- If you have finished configuring the network settings, click **Next** to configure [VCH Security](vch_security.md) settings.

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH with the following configuration:

- Designates a network and static IP address for the VCH endpoint VM on the public, client, and management networks.
- Designates a network named `vic-containers` for use by container VMs.
- Gives the container network the name `vic-container-network`, for use by Docker. 
- Specifies the gateway, two DNS servers, and a range of IP addresses on the container network for container VMs to use.
- Opens the firewall on the container network for outbound connections.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--public-network-ip 192.168.1.10/24
--public-network-gateway 192.168.1.1
--client-network vic-client
--client-network-ip 192.168.2.10/24
--client-network-gateway 192.168.2.0/24,192.168.128.0/24:192.168.2.1
--management-network vic-management
--management-network-ip 192.168.3.10/24
--management-network-gateway 192.168.3.0/24,192.168.128.0/24:192.168.3.1
--dns-server 192.168.10.10
--dns-server 192.168.10.11
--container-network vic-containers:vic-container-network
--container-network-gateway vic-containers:192.168.100.1/24
--container-network-dns vic-containers:192.168.100.10
--container-network-dns vic-containers:192.168.100.11
--container-network-ip-range vic-containers:192.168.100.0/24
--container-network-firewall vic-containers:outbound
--thumbprint <i>certificate_thumbprint</i>
--name vch1
--asymmetric-routes
</pre>