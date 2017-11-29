# Virtual Container Host Placement #



- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#examples)


## Example `vic-machine` Commmands <a id="examples"></a>

The following sections provide examples of `vic-machine create` commands that deploy VCHs in different vSphere setups. For simplicity, the examples all use the `--no-tlsverify` option to automatically generate server certificates but disable client authentication. In all of the examples, the thumbprint of the vCenter Server or ESXi host is specified in the `--thumbprint` option.

- [Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores](#cluster)
- [Deploy to a Specific Standalone Host in vCenter Server](#standalone)
- [Deploy to a Resource Pool on an ESXi Host](#rp_host)
- [Deploy to a Resource Pool in a vCenter Server Cluster](#rp_cluster)

### Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores <a id="cluster"></a>

If vCenter Server has more than one datacenter, you specify the datacenter in the `--target` option.

If vCenter Server manages more than one cluster, you use the `--compute-resource` option to specify the cluster on which to deploy the VCH.

When deploying a VCH to vCenter Server, you must use the [`--bridge-network`](bridge_network.md) option to specify an existing port group for container VMs to use to communicate with each other. For information about how to create a distributed virtual switch and port group, see [Networking Requirements for VCH Deployment](vic_installation_prereqs.md#vchnetworkreqs).

If vCenter Server manages more than one datastore, you must specify the [`--image-store`](image_store.md) option to designate a datastore in which to store container images, the files for the VCH appliance, and container VMs.

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates `datastore1` as the image store. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Deploy to a Specific Standalone Host in vCenter Server <a id="standalone"></a> 

If vCenter Server manages multiple standalone ESXi hosts that are not part of a cluster, you use the `--compute-resource` option to specify the address of the ESXi host on which to deploy the VCH.

This example deploys a VCH with the following configuration:

- Specifies the vCenter Server address, datacenter `dc1`, and the vSphere administrator user name and password in the `--target` option.
- Deploys the VCH on the ESXi host with the FQDN `esxihost1.organization.company.com`. You can also specify an IP address.
- Specifies the port group to use for the bridge network, the image store, a name for the VCH.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--bridge-network vch1-bridge
--image-store datastore1
--compute-resource esxihost1.organization.company.com
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>


### Deploy to a Resource Pool on an ESXi Host <a id="rp_host"></a>

To deploy a VCH in a specific resource pool on an ESXi host that is not managed by vCenter Server, you specify the resource pool name in the `--compute-resource` option. 

This example deploys a VCH with the following configuration:

- Specifies the user name and password and a name for the VCH.
- Designates `rp 1` as the resource pool in which to place the VCH. The resource pool name is wrapped in quotes, because it contains a space.
- Does not specify an image store, assuming that the host in this example only has one datastore.

<pre>vic-machine-<i>operating_system</i> create
--target root:<i>password</i>@<i>esxi_host_address</i>
--compute-resource 'rp 1'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>


### Deploy to a Resource Pool in a vCenter Server Cluster <a id="rp_cluster"></a>

To deploy a VCH in a resource pool in a vCenter Server cluster, you specify the resource pool in the `compute-resource` option.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, image store, bridge network, and name for the VCH.
- Designates `rp 1` as the resource pool in which to place the VCH. In this example, the resource pool name `rp 1` is unique across all hosts and clusters, so you only need to specify the resource pool name.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

If the name of the resource pool is not unique across all clusters, for example if two clusters each contain a resource pool named `rp 1`, you must specify the full path to the resource pool in the `compute-resource` option, in the format <i>cluster_name</i>/Resources/<i>resource_pool_name</i>.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'cluster 1'/Resources/'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>