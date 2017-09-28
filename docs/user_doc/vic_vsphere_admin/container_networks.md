# Container Networks #

Container networks allow the vSphere administrator to make vSphere networks directly available to containers. This is done during deployment of a VCH by providing a mapping of the vSphere network name to an alias that is used inside the VCH endpoint VM. The mapped networks are then listed as available by the Docker API. Running `docker network ls` shows these networks, and container developers can attach them to containers in the normal way by using commands such as `docker run` or `create`, with the `--network=_mapped-network-name_` or `docker network connect`. The containers connected to container networks are connected directly to these networks, and traffic does not route though the VCH endpoint VM using NAT.

You can share one network alias between multiple containers.

### `--container-network` <a id="container-network"></a>

Short name: `--cn`

A port group for container VMs to use for external communication when container developers  run `docker run` or `docker create` with the `--net` option. 

You can optionally specify one or more container networks. Container networks allow containers to directly attach to a network without having to route through the VCH via network address translation (NAT). Container networks that you add by using the `--container-network` option appear when you run the `docker network ls` command. These networks are available for use by containers. Containers that use these networks are directly attached to the container network, and do not go through the VCH or share the public IP of the VCH. 

If you use shared NFS share points as volumes stores, it is recommended to make the NFS target accessible by the container network. If you use NFS volume stores and you do not specify a container network, containers use NAT to route traffic to the NFS target through the VCH endpoint VM. This can create potential bottlenecks and a single point of failure. 

**IMPORTANT**: For security reasons, whenever possible, use separate port groups for the container network and the management network.

To specify a container network, you provide the name of a port group for the container VMs to use, and an optional descriptive name for the container network for use by Docker.  If you do not specify a descriptive name, Docker uses the vSphere network name. 

**IMPORTANT**:  The descriptive name is optional unless the port group name contains spaces. If the port group name contains spaces, you must specify a descriptive name.  The descriptive name cannot contain spaces.

If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

- You can specify a vSphere network as the container network.
- The port group must exist before you run `vic-machine create`. 
- You cannot use the same port group as you use for the bridge network. 
- You can create the port group on the same distributed virtual switch as the port group that you use for the bridge network.
- If the port group that you specify in the `container-network` option does not support DHCP, see [Configure Container Networks](#adv-container-net) in Advanced Options. 
- The descriptive name appears under `Networks` when you run `docker info` or `docker network ls` on the deployed VCH. The descriptive name cannot include spaces.
- Container developers use the descriptive name in the `--net` option when they run `docker run` or `docker create`.

You can specify `--container-network` multiple times to add multiple vSphere networks to Docker.

If you do not specify `--container-network`, or if you deploy containers that do not use a container network, the containers' network services are still be available via port mapping through the VCH, by using NAT through the public interface of the VCH.

<pre>--container-network <i>port_group_name</i>:<i>container_port _group_name</i></pre>

If you intend to use the [`--ops-user`](#ops-user) option to use different user accounts for deployment and operation of the VCH, you must place any container network port groups in a network folder that has the `Read-Only` role with propagation enabled. For more information about the requirements when using `--ops-user`, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md). 

## Configure Container Networks <a id="adv-container-net"></a>

If the network that you specify in the `container-network` option does not support DHCP, you must specify the `container-network-gateway` option. You can optionally specify one or more DNS servers and a range of IP addresses for container VMs on the container network. 

For information about the container network, see the section on the [`container-network` option](#container-network).

### `--container-network-gateway` ###

Short name: `--cng`

The gateway for the subnet of the container network. This option is required if the network that you specify in the `--container-network` option does not support DHCP. Specify the gateway in the format <code><i>container_network</i>:<i>subnet</i></code>. If you specify this option, it is recommended that you also specify the  `--container-network-dns` option.

When you specify the container network gateway, you must use the port group that you specify in the `--container-network` option. If you specify `--container-network-gateway` but you do not specify `--container-network`, or if you specify a different port group to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

<pre>--container-network-gateway <i>port_group_name</i>:<i>gateway_ip_address</i>/<i>subnet_mask</i></pre>

### `--container-network-dns` ###

Short name: `--cnd`

The address of the DNS server for the container network. This option is recommended if the network that you specify in the `--container-network` option does not support DHCP. 

When you specify the container network DNS server, you must use the  port group that you specify in the `--container-network` option. You can specify `--container-network-dns` multiple times, to configure multiple DNS servers. If you specify `--container-network-dns` but you do not specify `--container-network`, or if you specify a different port group to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

<pre>--container-network-dns <i>port_group_name</i>:8.8.8.8</pre>

### `--container-network-ip-range` <a id="container-network-ip-range"></a>

Short name: `--cnr`

The range of IP addresses that container VMs can use if the network that you specify in the `container-network` option does not support DHCP. If you specify `--container-network-ip-range`, VCHs manage the addresses for containers within that range. The range that you specify must not be used by other computers or VMs on the network.  You must also specify `--container-network-ip-range` if container developers need to deploy containers with static IP addresses. If you specify `container-network-gateway` but do not specify `--container-network-ip-range`, the IP range for container VMs is the entire subnet that you specify in `--container-network-gateway`. 

When you specify the container network IP range, you must use the port group that you specify in the `--container-network `option. If you specify `--container-network-ip-range` but you do not specify `--container-network`, or if you specify a different port group to the one that you specify in `--container-network`, `vic-machine create` fails with an error.

<pre>--container-network-ip-range <i>port_group_name</i>:192.168.100.2-192.168.100.254</pre>

You can also specify the IP range as a CIDR.

<pre>--container-network-ip-range <i>port_group_name</i>:192.168.100.0/24</pre>

### `--container-network-firewall`  <a id="container-network-firewall"></a>

Short name: `--cnf`

You can configure the trust level of container networks by setting the 
`--container-network-firewall` option. 

The `--container-network-firewall` option allows you to set the following levels of trust.

|Trust Level|Description|
|---|---|
|`closed`|No traffic can come in or out of the container interface.|
|`outbound`|Only outbound connections permitted.|
|`peers`|Only connections to other containers with the same `peers` interface are permitted. To enforce the `peers` trust level, you must set the `--container-network-ip-range` on the container network. The VCH applies a network rule so that container traffic is only allowed over that IP range. If you do not specify an IP range, the container network uses DHCP and there is no way that the VCH can determine whether or not a container at a given IP address is a peer to another container. In this case, the VCH defaults to the `open` setting, and it treats all connections as peer connections.|
|`published`|Only connections to published ports permitted.|
|`open`|All traffic permitted.|

<pre>--container-network-firewall <i>port_group_name</i>:<i>trust_level</i></pre>

If you do not set `--container-network-firewall`, the default level of trust is `published`. As a consequence, if you do not set `--container-network-firewall`, container developers must specify `-p 80` in `docker run` and `docker create` commands to publish port 80 on a container. In regular Docker, they do not need to specify `-p` to publish port 80.

### Example

You can designate a specific network for container VMs to use by specifying the `--container-network` option. Containers use this network if the container developer runs `docker run` or `docker create` specifying the `--net` option with one of the specified container networks when they run or create a container. This option requires a port group that must exist before you run `vic-machine create`. You cannot use the same port group that you use for the bridge network. You can provide a descriptive name for the network, for use by Docker. If you do not specify a descriptive name, Docker uses the vSphere network name. For example, the descriptive name appears as an available network in the output of `docker info` and `docker network ls`. 

If the network that you designate as the container network in the `--container-network` option does not support DHCP, you can configure the gateway, DNS server, and a range of IP addresses for container VMs to use.  You must specify `--container-network-ip-range` if container developers need to deploy containers with static IP addresses. 

This example deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, cluster, image store, bridge network, and name for the VCH.
- Uses the VM Network for the public, management, and client networks.
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
--no-tls
</pre>
