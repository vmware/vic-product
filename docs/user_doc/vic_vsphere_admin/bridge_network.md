# Bridge Networks #

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