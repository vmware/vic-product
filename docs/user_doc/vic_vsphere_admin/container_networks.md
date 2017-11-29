# Configure Container Networks #

Container networks are vSphere networks that the vSphere administrator makes directly available to container VMs. When you deploy a virtual container host (VCH), you provide a mapping of the vSphere network name to an alias that the VCH endpoint VM uses. You can share one network alias between multiple containers. 

The mapped networks are available for use by the Docker API. 
Running `docker network ls` lists the container networks, and container developers can attach them to containers in the normal way by using commands such as `docker run` or `create` with the `--network=mapped-network-name` option, or `docker network connect`. 

By using container networks, you can connect container VMs to any specific distributed port group or VMware NSX logical switch, which gives the container VMs their own dedicated connection to the network. Container networks allow containerized applications to get their own routable IP address and become first class citizens of your datacenter. Using container networks provides you with the following advantages: 

- **No single point of failure**: Every container VM has its own dedicated network connection, so even if the VCH endpoint VM fails there is no outage for your applications. If containers use port mapping, the containers are accessible over a network via a port on the VCH endpoint VM. If the endpoint VM goes down for any reason, that network connection is no longer available. If you use container networks, containers have their own identity on the container network. Consequently, the network and the container have no dependency on the VCH endpoint VM for execution. 
- **Network bandwidth sharing** Every container VM gets its own network interface and all of the bandwidth it can provide is available to the application. Traffic does not route though the VCH endpoint VM via network address translation (NAT) and containers do not share the public IP of the VCH.
- **No NAT conflicts**: There is no need for port mapping because every container VM gets its own IP address. Container services are directly exposed on the network without NAT, so applications that once could not run on containers can now run by using vSphere Integrated Containers. 
- **No port conflicts**: Since every container VM gets its own IP address, you can have multiple application containers that require an exclusive port running on the same VCH. 

**NOTE**: You can add or reconfigure container networks after you have deployed a VCH by using the `vic-machine configure --container-network` options. For information about adding or reconfiguring container networks, see Configure Container Network Settings in [Configure Running Virtual Container Hosts](configure_vch.md#containernet).

- [Basic `vic-machine` Option](#options)
- [Configure Non-DHCP Container Networks](#adv-container-net)
- [Configure the Firewall on Container Networks](#container-network-firewall)
- [Example `vic-machine` Command](#example)

## Basic `vic-machine` Option <a id="options"></a>

You designate a specific network for use by container VMs by specifying the `vic-machine create --container-network` option when you deploy the VCH.

### `--container-network` <a id="container-network"></a>

**Short name**: `--cn`

A port group for container VMs to use for external communication when container developers  run `docker run` or `docker create` with the `--net` option. 

**IMPORTANT**: For security reasons, whenever possible, use separate port groups for the container network and the management network.

To specify a container network, you provide the name of a port group for the container VMs to use, and an optional descriptive name for the container network for use by Docker.  If you do not specify a descriptive name, Docker uses the vSphere network name. 

- The port group must exist before you run `vic-machine create`. For information about how to create a VMware vSphere Distributed Switch and a port group, see [Create a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-D21B3241-0AC9-437C-80B1-0C8043CC1D7D.html) in the vSphere documentation.
- All hosts in a cluster must be attached to the port groups that you will use for mapped container networks. For information about how to add hosts to a vSphere Distributed Switch, see [Add Hosts to a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-E90C1B0D-82CB-4A3D-BE1B-0FDCD6575725.html) in the vSphere  documentation.
- Isolate the mapped container networks by using a separate VLAN for each network. 

  - For information about how to assign a VLAN ID to a port group, see [VMware KB 1003825](https://kb.vmware.com/kb/1003825). 
  - For information about private VLAN, see [VMware KB 1010691](https://kb.vmware.com/kb/1010691). 
  - For information about VLAN tagging, see [VMware KB 1003806](https://kb.vmware.com/s/article/1003806).
- You cannot use the same port group as you use for the bridge network. 
- You can create the port group on the same vSphere Distributed Switch as the port group that you use for the bridge network.
- If the port group that you specify in the `container-network` option does not support DHCP, see [Configure Non-DHCP Container Networks](#adv-container-net). 
- The descriptive name that you provide appears under `Networks` when you run `docker info` or `docker network ls` on the deployed VCH. The descriptive name cannot include spaces. The descriptive name is optional unless the port group name contains spaces. If the port group name contains spaces, you must specify a descriptive name.
- Container developers use the descriptive name in the `--net` option when they run `docker run` or `docker create`.
- If you use shared NFS share points as volumes stores, it is recommended to make the NFS target accessible from the container network. If you use NFS volume stores and you do not specify a container network, containers use NAT to route traffic to the NFS target through the VCH endpoint VM. This can create potential bottlenecks and a single point of failure. 
- If you intend to use the `--ops-user` option to use different user accounts for deployment and operation of the VCH, you must place any container network port groups in a network folder that has the `Read-Only` role with propagation enabled. For more information about the requirements when using `--ops-user`, see [Configure Operations User](set_up_ops_user.md). 

**Usage**: 
<pre>--container-network <i>port_group_name</i>:<i>docker_display_name</i></pre>

You can specify `--container-network` multiple times to add multiple vSphere networks to Docker.

If you do not specify `--container-network`, or if you deploy containers that do not use a container network, the containers' network services are still be available via port mapping through the VCH, by using NAT through the public interface of the VCH. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

## Configure Non-DHCP Container Networks <a id="adv-container-net"></a>

If the network that you specify in the `--container-network` option does not support DHCP, you must specify the `--container-network-gateway` option. You can optionally specify one or more DNS servers and a range of IP addresses for container VMs on the container network. 

### `--container-network-gateway` ###

**Short name**: `--cng`

The gateway for the subnet of the container network. This option is required if the network that you specify in the `--container-network` option does not support DHCP. Specify the gateway in the format <code><i>container_network</i>:<i>subnet</i></code>. If you specify this option, it is recommended that you also specify the  `--container-network-dns` option.

When you specify the container network gateway, you must use the port group that you specify in the `--container-network` option.

**Usage**: 
<pre>--container-network-gateway <i>port_group_name</i>:<i>gateway_ip_address</i>/<i>subnet_mask</i></pre>

 If you specify `--container-network-gateway` but you do not specify `--container-network`, or if you specify a different port group to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

### `--container-network-dns` ###

**Short name**: `--cnd`

The address of a DNS server for the container network. This option is recommended if the network that you specify in the `--container-network` option does not support DHCP. 

When you specify the container network DNS server, you must use the  port group that you specify in the `--container-network` option. 

**Usage**: 
<pre>--container-network-dns <i>port_group_name</i>:8.8.8.8</pre>

You can specify `--container-network-dns` multiple times, to configure multiple DNS servers. If you specify `--container-network-dns` but you do not specify `--container-network`, or if you specify a different port group to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

### `--container-network-ip-range` <a id="container-network-ip-range"></a>

**Short name**: `--cnr`

The range of IP addresses that container VMs can use if the network that you specify in the `container-network` option does not support DHCP. If you specify `--container-network-ip-range`, VCHs manage the addresses for containers within that range. The range that you specify must not be used by other computers or VMs on the network.  You must also specify `--container-network-ip-range` if container developers need to deploy containers with static IP addresses. If you specify `container-network-gateway` but do not specify `--container-network-ip-range`, the IP range for container VMs is the entire subnet that you specify in `--container-network-gateway`. 

When you specify the container network IP range, you must use the port group that you specify in the `--container-network `option. 

**Usage**: 
<pre>--container-network-ip-range <i>port_group_name</i>:192.168.100.2-192.168.100.254</pre>

You can also specify the IP range as a CIDR.

<pre>--container-network-ip-range <i>port_group_name</i>:192.168.100.0/24</pre>

If you specify `--container-network-ip-range` but you do not specify `--container-network`, or if you specify a different port group to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

## Configure the Firewall on Container Networks <a id="container-network-firewall"></a>

You can configure the trust level of container networks by setting the 
`--container-network-firewall` option. 

### `--container-network-firewall`  
**Short name**: `--cnf`

The `--container-network-firewall` option allows you to set the following levels of trust.

|Trust Level|Description|
|---|---|
|`closed`|No traffic can come in or out of the container interface, even if developers expose ports on containers. |
|`outbound`|Only outbound connections are permitted. Use this setting if the VCH will host applications that consume but do not provide services.|
|`peers`|Only connections to other containers with the same `peers` interface are permitted. To enforce the `peers` trust level, you must set the `--container-network-ip-range` on the container network. The VCH applies a network rule so that container traffic is only allowed over that IP range. If you do not specify an IP range, the container network uses DHCP and there is no way that the VCH can determine whether or not a container at a given IP address is a peer to another container. In this case, the VCH defaults to the `open` setting, and it treats all connections as peer connections. Use the `peers` setting for container VMs that need to communicate with each other but not with the external world.|
|`published`|Only connections to published ports is permitted.|
|`open`|All traffic is permitted and developers can decide which ports to expose.|

**Usage**: 
<pre>--container-network-firewall <i>port_group_name</i>:<i>trust_level</i></pre>

If you do not set `--container-network-firewall`, the default level of trust is `published`. As a consequence, if you do not set `--container-network-firewall`, container developers must explicitly specify `-p 80` in `docker run` and `docker create` commands to publish port 80 on a container. Obliging developers to specify the ports to expose improves security and gives you more awareness of your environment and applications.  

## Example `vic-machine` Command <a id="example"></a>

This example deploys a VCH with the following configuration:

- Specifies the target vCenter Server instance, the vCenter Server user name, password, datacenter and cluster, an image store, a port group for the bridge network, a name for the VCH, and the thumbprint of the vCenter Server certificate.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Uses the default VM Network for the public, management, and client networks.
- Designates a port group named `vic-containers` for use by container VMs that are run with the `--net` option.
- Gives the container network the name `vic-container-network`, for use by Docker. 
- Specifies the gateway, two DNS servers, and a range of IP addresses on the container network for container VMs to use.
- Opens the firewall on the container network for outbound connections.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--container-network vic-containers:vic-container-network
--container-network-gateway vic-containers:<i>gateway_ip_address</i>/24
--container-network-dns vic-containers:<i>dns1_ip_address</i>
--container-network-dns vic-containers:<i>dns2_ip_address</i>
--container-network-ip-range vic-containers:192.168.100.0/24
--container-network-firewall vic-containers:outbound
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>
