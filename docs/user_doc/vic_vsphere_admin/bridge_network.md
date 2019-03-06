# Configure Bridge Networks #

Bridge networks are the network or networks that container VMs use to communicate with each other. Every virtual container host (VCH) must have a dedicated bridge network. 

In Docker terminology, the bridge network on a VCH corresponds to the default bridge network, or `docker0` interface, on a Docker host. Container application developers can use `docker network create` to create additional, user-defined bridge networks when they run containers. For information about default bridge networks and user-defined networks, see [Docker container networking](https://docs.docker.com/engine/userguide/networking/) in the Docker documentation.

**IMPORTANT**: 

- For information about VCH networking requirements, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).
- If you use NSX-T Data Center logical switches, it is not mandatory for T1 or T0 routers to be present. The bridge network does not use layer 3, so does not require T1 and T0 routers.

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Configure Networks page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Bridge Network <a id="bridge"></a>

A network interface that container VMs use to communicate with each other. 

Before you deploy a VCH, you must create a VMware vSphere Distributed Switch and a port group, an NSX Data Center for vSphere logical switch, or an NSX-T Data Center logical switch for the bridge network. For information about how to create a port group or logical switch, see [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).

**IMPORTANT** 

- You must create a dedicated vSphere port group, or an NSX Datacenter for vSphere logical switch, or an NSX-T Data Center logical switch for the bridge network for every VCH. Do not specify the same port group or logical switch as the bridge network for multiple VCHs. Sharing a bridge network between VCHs might result in multiple container VMs being assigned the same IP address. 
- Do not use the bridge network for any of the other VCH networking options.
- Do not use the bridge network for any other VM workloads.

#### Create VCH Wizard

Select an existing port group or logical switch from the **Bridge network** drop-down menu. It is **mandatory** to specify a bridge network.

#### vic-machine Option 

`--bridge-network`, `-b`

You designate the bridge network by specifying an existing port group or logical switch in the `vic-machine create --bridge-network` option.  

The `--bridge-network` option is **mandatory** if you are deploying a VCH to vCenter Server. 

The `--bridge-network` option is **optional** if you are deploying a VCH to an ESXi host that is not managed by vCenter Server. In this case, if you do not specify `--bridge-network`, `vic-machine` creates a vSphere Distributed Switch and a port group that each have the same name as the VCH. You can optionally specify this option to assign an existing port group or logical switch for use as the bridge network for container VMs. You can also optionally specify this option to create a new port group that has a different name to the VCH.

<pre>--bridge-network <i>port_group_or_logical_switch_name</i></pre>

If you do not specify `--bridge-network` or if you specify an invalid port group or logical switch name, `vic-machine create` fails and suggests valid port groups or logical switches. 

### Bridge Network Range <a id="bridge-range"></a>

A range of IP addresses that additional bridge networks can use when container application developers use `docker network create` to create new user-defined networks. VCHs create these additional user-defined bridge networks by using IP address segregation within a set address range, so user-defined bridge networks do not require you to assign dedicated port groups. By default, all VCHs use the standard Docker range of 172.16.0.0/12 for additional user-defined networks. You can override the default range if that range is already in use in your network. You can reuse the same network address range across all VCHs.  

When you specify a bridge network IP range, you specify the IP range as a CIDR. The smallest subnet that you can specify is /16.

#### Create VCH Wizard

If the default range of 172.16.0.0.0/12 is in use in your network, enter a new range as a CIDR. For example, enter `192.168.100.0/16`.

#### vic-machine Option

`--bridge-network-range`, `--bnr`

If the default range of 172.16.0.0.0/12 is in use in your network, specify a new range in the `--bridge-network-range` option.
 
<pre>--bridge-network-range <i>network_address</i>/<i>subnet</i></pre>

If you specify an invalid value for `--bridge-network-range`, `vic-machine create` fails with an error.

### Bridge Network Width <a id="bridge-width"></a>

If you need to create bridge networks with netmasks that are smaller than the default of 16, you can set a new default value.

#### Create VCH Wizard

Enter a value in the **Bridge network width** text box.

#### vic-machine Option

`--bridge-network-width`, `--bnw`
 
<pre>--bridge-network-width 24</pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, stay on the Configure Networks page and [Configure the Public Network](public_network.md) settings.

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH that designates an existing network named `vch1-bridge` as the bridge network. It specifies IP addresses in the range 192.168.100.0/16 for use by user-defined bridge networks.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--bridge-network-range 192.168.100.0/16
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>
