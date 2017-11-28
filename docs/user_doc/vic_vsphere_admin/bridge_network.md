# Configure Bridge Networks #

Bridge networks are the network or networks that container VMs use to communicate with each other. Every virtual container host (VCH) must have a unique bridge network. 

In Docker terminology, the bridge network corresponds to the default bridge network, or `docker0` interface, on a Docker host. You can also create additional bridge networks, that correspond to Docker user-defined networks. For information about default bridge networks and user-defined networks, see [Docker container networking](https://docs.docker.com/engine/userguide/networking/) in the Docker documentation.

**IMPORTANT**: Do not use the bridge network for any other VM workloads, or as a bridge for more than one VCH.

Container application developers can use `docker network create` to create additional, user-defined bridge networks when they run containers. VCHs create additional user-defined bridge networks by using IP address segregation within an address range that you can specify, so user-defined bridge networks do not require new port groups. 

- [`vic-machine` Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

You designate the bridge network by specifying the `vic-machine create --bridge-network` option. You can also provide a range of IP addresses for use by additional user-defined bridge networks by specifying the [ `--bridge-network-range` option](#bridge-range). 

### `--bridge-network` <a id="bridge"></a>

**Short name**: `-b`

A port group that container VMs use to communicate with each other. 

The `--bridge-network` option is **mandatory** if you are deploying a VCH to vCenter Server. Before you run `vic-machine create`, you must perform the following tasks in vCenter Server:

- Create a VMware vSphere Distributed Switch and a port group for the bridge network. You can create multiple port groups on the same vSphere Distributed Switch, but each VCH requires a unique port group for the bridge network. The port group must be an isolated L2 broadcast domain. For information about how to create a vSphere Distributed Switch and a port group, see [Create a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-D21B3241-0AC9-437C-80B1-0C8043CC1D7D.html) in the vSphere  documentation. 
- Add the target ESXi host or hosts to the vSphere Distributed Switch. For information about how to add hosts to a vSphere Distributed Switch, see [Add Hosts to a vSphere Distributed Switch](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.networking.doc/GUID-E90C1B0D-82CB-4A3D-BE1B-0FDCD6575725.html) in the vSphere  documentation.
- Assign a VLAN ID to the port group, to ensure that the bridge network is isolated. The bridge network has its own DHCP service that must be on an isolated VLAN that is trunked between the ESXi hosts in the cluster to which you are deploying the VCH. Use Virtual Switch Tagging for the VLAN ID. You require a separate VLAN ID and vSphere Distributed Switch port group for each VCH. 

  - For information about how to assign a VLAN ID to a port group, see [VMware KB 1003825](https://kb.vmware.com/kb/1003825). 
  - For information about private VLAN, see [VMware KB 1010691](https://kb.vmware.com/kb/1010691). 
  - For information about VLAN tagging, see [VMware KB 1003806](https://kb.vmware.com/s/article/1003806).

By design, containers that are connected to the bridge network are not accessible on the public network. This behavior reflects Docker behavior. To make containers available on the network, container developers must use either `-p` to map network ports, or use an external network.

The `--bridge-network` option is **optional** if you are deploying a VCH to an ESXi host that is not managed by vCenter Server. In this case, if you do not specify `--bridge-network`, `vic-machine` creates a  virtual switch and a port group that each have the same name as the VCH. You can optionally specify this option to assign an existing port group for use as the bridge network for container VMs. You can also optionally specify this option to create a new virtual switch and port group that have a different name to the VCH.

**IMPORTANT** 

- Do not specify the same port group as the bridge network for multiple VCHs. Sharing a port group between VCHs might result in multiple container VMs being assigned the same IP address. 
- Do not use the bridge network port group as the target for any of the other `vic-machine create` networking options.
- If you intend to use the `--ops-user` option to use different user accounts for deployment and operation of the VCH, you must place the bridge network port group in a network folder that has the `Read-Only` role with propagation enabled. For more information about the requirements when using `--ops-user`, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

**Usage**: 
<pre>--bridge-network <i>port_group_name</i></pre>

If you do not specify `--bridge-network` or if you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups. 

### `--bridge-network-range` <a id="bridge-range"></a>

**Short name**: `--bnr`

A range of IP addresses that additional bridge networks can use when container application developers use `docker network create` to create new user-defined networks. By default, all VCHs use the Docker default range of 172.16.0.0.0/12 for additional user-defined networks. You can override the default range by using the `--bridge-network-range` option if that range is already in use in your network. You can reuse the same network address range across all VCHs. 

**Usage**: 

When you specify a bridge network IP range, you specify the IP range as a CIDR. The smallest subnet that you can specify is /16.  If you do not specify `--bridge-network-range`, the default range is 172.16.0.0.0/12.
 
<pre>--bridge-network-range <i>network_address</i>/<i>subnet</i></pre>

If you specify an invalid value for `--bridge-network-range`, `vic-machine create` fails with an error.

## Example `vic-machine` Command <a id="example"></a>

This example deploys a VCH with the following configuration:

- Specifies the target vCenter Server instance, the vCenter Server user name, password, datacenter and cluster, an image store, a name for the VCH, and the thumbprint of the vCenter Server certificate.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Designates an existing port group named `vch1-bridge` as the bridge network.
- Designates IP addresses in the range 192.168.100.0/16 for use by user-defined bridge networks.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--bridge-network-range 192.168.100.0/16
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>
