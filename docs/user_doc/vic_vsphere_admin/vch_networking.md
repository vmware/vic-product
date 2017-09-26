# Virtual Container Host Networking #

You can configure networks on a virtual container host (VCH) that are tied into the vSphere infrastructure. You define which networks are available to a VCH when you deploy the VCH.

Each network that a VCH uses is a port group on either a vCenter Server instance or ESXi host. You can deploy VCHs on NSX networks.

This topic provides an overview of the different network types that virtual container hosts use.

- [High-Level View of VCH Networking](#highlevel)
- [Management Network](#management)
- [Public Network](#public)
- [Client Network](#client)
- [Bridge Network](#bridge)
- [Container Networks](#container)

## High-Level View of VCH Networking <a id="highlevel"></a>

The image below shows a high-level view of the networks that a VCH uses and how they connect to your vSphere environment, to vSphere Integrated Containers Registry and Management Portal, and to the Docker environment. 
 
 ![VCH Networking](graphics/vic_networking.png)

The following sections describe each of the VCH network types.

**IMPORTANT**: A VCH supports a maximum of 3 distinct network interfaces. The bridge network requires its own port group, at least two of the public, client, and management networks must share a network interface and therefore a port group. Container networks do not go through the VCH, so they are not subject to this limitation. This limitation will be removed in a future release.

## Networking Options <a id="networking"></a>

The `vic-machine create` utility allows you to specify different networks for the different types of traffic between containers, the VCH, the external internet, and your vSphere environment.

**IMPORTANT**: A VCH supports a maximum of 3 distinct network interfaces. Because the bridge network requires its own port group, at least two of the public, client, and management networks must share a network interface and therefore a port group. Container networks do not go through the VCH, so they are not subject to this limitation. This limitation will be removed in a future release.

By default, `vic-machine create` obtains IP addresses for VCH endpoint VMs by using DHCP. For information about how to specify a static IP address for the VCH endpoint VM on the client, public, and management networks, see [Specify a Static IP Address for the VCH Endpoint VM](#static-ip) in Advanced Options.

If your network access is controlled by a proxy server, see [Configure VCHs to Use Proxy Servers](#proxy) in Advanced Options. 

When you specify different network interfaces for the different types of traffic, `vic-machine create` checks that the firewalls on the ESXi hosts allow connections to port 2377 from those networks. If access to port 2377 on one or more ESXi hosts is subject to IP address restrictions, and if those restrictions block access to the network interfaces that you specify, `vic-machine create` fails with a firewall configuration error:
<pre>Firewall configuration incorrect due to allowed IP restrictions on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

For information about how to open port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).


## Management Network <a id="management"></a>

The network for communication between the VCH, vCenter Server, and ESXi hosts. The VCH uses this network to provide the `attach` function of the Docker API. 

**IMPORTANT**: Because the management network provides access to your vSphere environment, and because container VMs use this network to communicate with the VCH, always use a secure network for the management network. Ideally, use separate networks for the management network and the container networks. The most secure setup is to make sure that VCHs can access vCenter Server and ESXi hosts directly over the management network, and that the management network has route entries for the subnets that contain both the target vCenter Server and the corresponding ESXi hosts.

You define the management network by setting the `--management-network` option when you run `vic-machine create`. For more detailed information about management networks, see the section on the `--management-network` option in [VCH Deployment Options](vch_installer_options.md#management-network).

### `--management-network` <a id="management-network"></a>

Short name: `--mn`

A port group that the VCH uses to communicate with vCenter Server and ESXi hosts. Container VMs use this network to communicate with the VCH. 

**IMPORTANT**: Because the management network provides access to your vSphere environment, and because container VMs use this network to communicate with the VCH, always use a secure network for the management network. Ideally, use separate networks for the management network and the container networks. The most secure setup is to make sure that VCHs can access vCenter Server and ESXi hosts directly over the management network, and that the management network has route entries for the subnets that contain both the target vCenter Server and the corresponding ESXi hosts. If the management network does not have route entries for the vCenter Server and ESXi host subnets, you must configure asymmetric routing. For more information about asymmetric routing, see the section on the [`--asymmetric-routes` option](#asymmetric-routes). 

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

If not specified, the VCH uses the public network for management traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

<pre>--management-network <i>port_group_name</i></pre>

### `--asymmetric-routes` <a id="asymmetric-routes"></a>

Short name: `--ar`

Allows incoming connections from ESXi hosts to VCHs over the public network rather than over the management network. This option allows containers on bridge networks to indirectly access assets on the management or client networks via the public interface, if those assets are routable from the public network. If the management network does not have route entries for the vCenter Server and ESXi host subnets,  and you do not set `--asymmetric-routes`, containers that run without specifying `-d` remain in the starting state.

In this scenario, use the `--asymmetric-routes` option to allow management traffic from ESXi hosts to the VCH to pass over the public network. By setting the `--asymmetric-routes` option, you set reverse path forwarding in the VCH endpoint VM to loose mode rather than the default strict mode. For information about reverse path forwarding and loose mode, see https://en.wikipedia.org/wiki/Reverse_path_forwarding.

The `--asymmetric-routes` option takes no arguments. If you do not set `--asymmetric-routes`, all management traffic is routed over the management network.

<pre>--asymmetric-routes</pre>


## Public Network  <a id="public"></a>
The network that container VMs use to connect to the internet. Ports that containers expose with `docker create -p` when connected to the default bridge network are made available on the public interface of the VCH endpoint VM via network address translation (NAT), so that containers can publish network services. 

You define the public network by setting the `--public-network` option when you run `vic-machine create`. For  more detailed information about management networks, see the section on the `--public-network` option in [VCH Deployment Options](vch_installer_options.md#public-network).

### `--public-network` <a id="public-network"></a>

Short name: `--pn`

A port group for containers to use to connect to the Internet. VCHs use the public network to pull container images, for example from https://hub.docker.com/. Containers that use use port mapping expose network services on the public interface. 

**NOTE**: vSphere Integrated Containers Engine adds a new capability to Docker that allows you to directly map containers to a network by using the `--container-network` option. This is the recommended way to deploy container services.

If not specified, containers use the VM Network for public network traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

<pre>--public-network <i>port_group</i></pre>

## Client Network <a id="client"></a>

The network on which the VCH endpoint VM makes the Docker API available to Docker clients. The client network isolates the Docker endpoints from the public network. VCHs can access vSphere Integrated Containers Registry over the client network, but it is recommended to connect to registries either over the public network or over the management network. vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry require a connection to the client network. 

You define the Docker management endpoint network by setting the `--client-network` option when you run `vic-machine create`. For  more detailed information about Docker management endpoint networks, see the section on the `--client-network` option in [VCH Deployment Options](vch_installer_options.md#client-network).

### `--client-network` <a id="client-network"></a>

Short name: `--cln`

A port group on which the VCH will make the Docker API available to Docker clients. Docker clients use this network to issue Docker API requests to the VCH.

If not specified, the VCH uses the public network for client traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

<pre>--client-network <i>port_group_name</i></pre>


## Bridge Network <a id="bridge"></a>
The network or networks that container VMs use to communicate with each other. Each VCH requires a unique bridge network. The bridge network is a port group on a distributed virtual switch.

**IMPORTANT**: Do not use the bridge network for any other VM workloads, or as a bridge for more than one VCH.

You define the bridge networks by setting the `--bridge-network` option when you run `vic-machine create`.  For  more detailed information about bridge networks, see the section on the `--bridge-network` option in [VCH Deployment Options](vch_installer_options.md#bridge).

Container application developers can also use `docker network create` to create additional bridge networks. These networks are represented by the User-Created Bridge Network in the image above. Additional bridge networks are created by IP address segregation and are not new port groups. You can define a range of IP addresses that additional bridge networks can use by defining the `bridge-network-range` option when you run `vic-machine create`. For  more detailed information about  how to set bridge network ranges, see the section on the `--bridge-network-range` option in [VCH Deployment Options](vch_installer_options.md#bridge-range). 

### `--bridge-network` <a id="bridge"></a>

Short name: `-b`

A port group that container VMs use to communicate with each other. 

The `bridge-network` option is **mandatory** if you are deploying a VCH to vCenter Server.

In a vCenter Server environment, before you run `vic-machine create`, you must create a distributed virtual switch and a port group. You must add the target ESXi host or hosts to the distributed virtual switch, and assign a VLAN ID to the port group, to ensure that the bridge network is isolated. For information about how to create a distributed virtual switch and port group, see the section on vCenter Server Network Requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md#networkreqs).

You pass the name of the port group to the `bridge-network` option. Each VCH requires its own port group. 

**IMPORTANT** 
- Do not assign the same `bridge-network` port group to multiple VCHs. Sharing a port group between VCHs might result in multiple container VMs being assigned the same IP address. 
- Do not use the `bridge-network` port group as the target for any of the other `vic-machine create` networking options.

If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

The `bridge-network` option is **optional** when you are deploying a VCH to an ESXi host with no vCenter Server. In this case, if you do not specify `bridge-network`, `vic-machine` creates a  virtual switch and a port group that each have the same name as the VCH. You can optionally specify this option to assign an existing port group for use as the bridge network for container VMs. You can also optionally specify this option to create a new virtual switch and port group that have a different name to the VCH.

<pre>--bridge-network <i>port_group_name</i></pre>

If you intend to use the [`--ops-user`](#ops-user) option to use different user accounts for deployment and operation of the VCH, you must place the bridge network port group in a network folder that has the `Read-Only` role with propagation enabled. For more information about the requirements when using `--ops-user`, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md). 

For information about how to specify a range of IP addresses for additional bridge networks, see [`bridge-network-range`](#bridge-range) in Advanced Networking Options.


## Container Networks <a id="container"></a>

Container networks allow the vSphere administrator to make vSphere networks directly available to containers. This is done during deployment of a VCH by providing a mapping of the vSphere network name to an alias that is used inside the VCH endpoint VM. The mapped networks are then listed as available by the Docker API. Running `docker network ls` shows these networks, and container developers can attach them to containers in the normal way by using commands such as `docker run` or `create`, with the `--network=_mapped-network-name_` or `docker network connect`. The containers connected to container networks are connected directly to these networks, and traffic does not route though the VCH endpoint VM using NAT.

You can share one network alias between multiple containers. For  more detailed information about setting up container networks, see the sections on the `container-network-xxx` options in [Virtual Container Host Deployment Options](vch_installer_options.md#container-network).

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

## Specify Public, Management, and Client Networks <a id="networks"></a>

In addition to the mandatory bridge network, if your vCenter Server environment includes multiple networks, you can direct different types of traffic to different networks. 

- You can direct the traffic between the VCH and the Internet to a specific network by specifying the `--public-network` option. Any container VM traffic that routes through the VCH also uses the public network. If you do not specify the `--public-network` option, the VCH uses the VM Network for public network traffic.
- You can direct traffic between ESXi hosts, vCenter Server, and the VCH to a specific network by specifying the `--management-network` option. If you do not specify the `--management-network` option, the VCH uses the public network for management traffic.
- You can designate a specific network for use by the Docker API by specifying the `--client-network` option. If you do not specify the `--client-network` option, the Docker API uses the public network.

**IMPORTANT**: A VCH supports a maximum of 3 distinct network interfaces. Because the bridge network requires its own port group, at least two of the public, client, and management networks must share a network interface and therefore a port group. Container networks do not go through the VCH, so they are not subject to this limitation. This limitation will be removed in a future release.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, cluster, image store, bridge network, and name for the VCH.
- Directs public and management traffic to network 1 and Docker API traffic to network 2.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network 'network 1'
--management-network 'network 1'
--client-network 'network 2'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>