# Virtual Container Host Placement #

The `create` command of the `vic-machine` utility requires you to provide information about where in your vSphere environment to deploy the VCH and the vCenter Server or ESXi user account to use for deployment.

- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Options <a id="options"></a>

The following `vic-machine create` options identify the location in which to deploy the VCH, and the vSphere administrator credentials to use for deployment.

### `--target` <a id="target"></a>

**Short name**: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you are deploying a VCH. This option is always **mandatory**.

You can set an environment variable so that you do not have to specify `--target` in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

To facilitate IP address changes in your infrastructure, provide an FQDN whenever possible, rather than an IP address. If `vic-machine create` cannot resolve the FQDN, it fails with an error.

**Usage**:

If the target ESXi host is not managed by vCenter Server, provide the address of the ESXi host.<pre>--target <i>esxi_host_address</i></pre>

If the target ESXi host is managed by vCenter Server, or if you are deploying to a cluster, provide the address of vCenter Server.<pre>--target <i>vcenter_server_address</i></pre>

You can include the user name and password in the target URL. If you are deploying a VCH on vCenter Server, specify the user name for an account that has the Administrator role on that vCenter Server instance. <pre>--target <i>vcenter_or_esxi_username</i>:<i>password</i>@<i>vcenter_or_esxi_address</i></pre>
  
If you do not include the user name in the target URL, you must specify the `--user` option. If you do not specify the `--password` option or include the password in the target URL, `vic-machine create` prompts you to enter the password.

If you are deploying a VCH on a vCenter Server instance that includes more than one datacenter, include the datacenter name in the target URL. If you include an invalid datacenter name, `vic-machine create` fails and suggests the available datacenters that you can specify.  <pre>--target <i>vcenter_server_address</i>/<i>datacenter_name</i></pre>

### `--user` <a id="user"></a>

**Short name**: `-u`

The user name for the ESXi host or vCenter Server instance on which you are deploying a VCH.

If you are deploying a VCH on vCenter Server, specify a user name for an account that has the Administrator role on that vCenter Server instance. 

You can also specify the user name in the URL that you pass to `vic-machine create` in the `--target` option, in which case the `--user` option is not required.

You can set an environment variable so that you do not have to specify `--user` in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

You can configure a VCH so that it uses a non-administrator account with reduced privileges for post-deployment operations by specifying the `--ops-user` option. If you do not specify `--ops-user`, VCHs use the vSphere administrator account that you specify in `--user` for general post-deployment operations. For information about using a different account for post-deployment operation, [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

**Usage**:

<pre>--user <i>esxi_or_vcenter_server_username</i></pre>

### `--password` <a id="password"></a>

**Short name**: `-p`

The password for the vSphere administrator account on the vCenter Server on which you are deploying the VCH, or the password for the ESXi host if you are deploying directly to an ESXi host. If not specified, `vic-machine` prompts you to enter the password during deployment.

You can also specify the user name and password in the URL that you pass to `vic-machine create` in the `--target` option, in which case the `--password` option is not required.

You can set an environment variable so that you do not have to specify `--password` in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

**Usage**:

<pre>--password <i>esxi_host_or_vcenter_server_password</i></pre>

### `--compute-resource` <a id="compute-resource"></a>

**Short name**: `-r`

The host, cluster, or resource pool in which to deploy the VCH. 

If the vCenter Server instance on which you are deploying a VCH only includes a single instance of a standalone host or cluster, `vic-machine create` automatically detects and uses those resources. In this case, you do not need to specify a compute resource when you run `vic-machine create`. If you are deploying the VCH directly to an ESXi host and you do not use `--compute-resource` to specify a resource pool, `vic-machine create` automatically uses the default resource pool. 

You specify the `--compute-resource` option in the following circumstances:

- A vCenter Server instance includes multiple instances of standalone hosts or clusters, or a mixture of standalone hosts and clusters.
- You want to deploy the VCH to a specific resource pool in your environment. 

**NOTE**: You cannot deploy a VCH to a specific host in a cluster. You deploy the VCH to the cluster, and DRS manages the placement of the VCH on a host.

If you do not specify the `--compute-resource` option and multiple possible resources exist, or if you specify an invalid resource name, `vic-machine create` fails and suggests valid targets for `--compute-resource` in the failure message. 

**Usage**:

To deploy to a specific resource pool on an ESXi host that is not managed by vCenter Server, specify the name of the resource pool: <pre>--compute-resource  <i>resource_pool_name</i></pre>

To deploy to a vCenter Server instance that has multiple standalone hosts that are not part of a cluster, specify the IPv4 address or fully qualified domain name (FQDN) of the target host:<pre>--compute-resource <i>host_address</i></pre>

To deploy to a vCenter Server with multiple clusters, specify the name of the target cluster: <pre>--compute-resource <i>cluster_name</i></pre>

To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, or to a specific resource pool in a cluster, if the resource pool name is unique across all hosts and clusters, specify the name of the resource pool:<pre>--compute-resource <i>resource_pool_name</i></pre>

To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, if the resource pool name is not unique across all hosts, specify the IPv4 address or FQDN of the target host and name of the resource pool:<pre>--compute-resource <i>host_name</i>/<i>resource_pool_name</i></pre>

To deploy to a specific resource pool in a cluster, if the resource pool name is not unique across all clusters, specify the full path to the resource pool:<pre>--compute-resource <i>cluster_name</i>/Resources/<i>resource_pool_name</i></pre>

### `--name` <a id="name"></a>

**Short name**: `-n`

A name for the VCH, that appears the vCenter Server inventory and that you can use in other `vic-machine` commands. If not specified, `vic-machine` sets the name of the VCH to `virtual-container-host`. If a VCH of the same name exists on the ESXi host or in the vCenter Server inventory, or if a folder of the same name exists in the target datastore, `vic-machine create` creates a folder named <code><i>vch_name</i>_1</code>. If the name that you provide contains unsupported characters, `vic-machine create` fails with an error.

**Usage**:
 
<pre>--name <i>vch_name</i></pre>

### `--thumbprint` <a id="thumbprint"></a>

**Short name**: None

If your vSphere environment uses untrusted, self-signed certificates to authenticate connections, you must specify the thumbprint of the vCenter Server or ESXi host certificate in the `--thumbprint` option of all `vic-machine` commands. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

For information about how to obtain the certificate thumbprint for vCenter Server or an ESXi host, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

After you obtain the certificate thumbprint from vCenter Server or an ESXi host, you can set it as an environment variable so that you do not have to specify `--thumbprint` in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

If you run `vic-machine` without the specifying the `--thumbprint` option and the operation fails, the resulting error message includes the certificate thumbprint. Always verify that the thumbprint in the error message is valid before attempting to run the command again.
 
**CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments. 

Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

**Usage**:

<pre>--thumbprint <i>certificate_thumbprint</i></pre>

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