# Container Networks #

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
