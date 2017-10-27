# Virtual Container Host Placement #

The `create` command of the `vic-machine` utility requires you to provide information about where in your vSphere environment to deploy the VCH and the vCenter Server or ESXi user account to use.

You can set environment variables for the `--target`, `--user`, `--password`, and `--thumbprint` options. For information about setting environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

- [`vic-machine `Options](#options)
- [Example `vic-machine` Commands](#example)

## `vic-machine` Options <a id="options"></a>

### `--target` ###

Short name: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you are deploying a VCH. This option is always **mandatory**.

To facilitate IP address changes in your infrastructure, provide an FQDN whenever possible, rather than an IP address. If `vic-machine create` cannot resolve the FQDN, it fails with an error.

- If the target ESXi host is not managed by vCenter Server, provide the address of the ESXi host.<pre>--target <i>esxi_host_address</i></pre>
- If the target ESXi host is managed by vCenter Server, or if you are deploying to a cluster, provide the address of vCenter Server.<pre>--target <i>vcenter_server_address</i></pre>
- You can include the user name and password in the target URL. If you are deploying a VCH on vCenter Server, specify the username for an account that has the Administrator role on that vCenter Server instance. <pre>--target <i>vcenter_or_esxi_username</i>:<i>password</i>@<i>vcenter_or_esxi_address</i></pre>
  
    If you do not include the user name in the target URL, you must specify the `user` option. If you do not specify the `password` option or include the password in the target URL, `vic-machine create` prompts you to enter the password.

- If you are deploying a VCH on a vCenter Server instance that includes more than one datacenter, include the datacenter name in the target URL. If you include an invalid datacenter name, `vic-machine create` fails and suggests the available datacenters that you can specify. 

  <pre>--target <i>vcenter_server_address</i>/<i>datacenter_name</i></pre>

### `--user` ###

Short name: `-u`

The username for the ESXi host or vCenter Server instance on which you are deploying a VCH.

If you are deploying a VCH on vCenter Server, specify a username for an account that has the Administrator role on that vCenter Server instance. 

<pre>--user <i>esxi_or_vcenter_server_username</i></pre>

You can specify the username in the URL that you pass to `vic-machine create` in the `target` option, in which case the `user` option is not required.

You can configure a VCH so that it uses a non-administrator account for post-deployment operations by specifying the `--ops-user` option. If you do not specify `--ops-user`, VCHs use the vSphere administrator account that you specify in `--user` for general post-deployment operations. For information about using a separate account for post-deployment operation, [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).


### `--password` ###

Short name: `-p`

The password for the user account on the vCenter Server on which you  are deploying the VCH, or the password for the ESXi host if you are deploying directly to an ESXi host. If not specified, `vic-machine` prompts you to enter the password during deployment.

<pre>--password <i>esxi_host_or_vcenter_server_password</i></pre>

You can also specify the username and password in the URL that you pass to `vic-machine create` in the `target` option, in which case the `password` option is not required.

### `--compute-resource` ###

Short name: `-r`

The host, cluster, or resource pool in which to deploy the VCH. 

If the vCenter Server instance on which you are deploying a VCH only includes a single instance of a standalone host or cluster, `vic-machine create` automatically detects and uses those resources. In this case, you do not need to specify a compute resource when you run `vic-machine create`. If you are deploying the VCH directly to an ESXi host and you do not use `--compute-resource` to specify a resource pool, `vic-machine create` automatically uses the default resource pool. 

You specify the `--compute-resource` option in the following circumstances:

- A vCenter Server instance includes multiple instances of standalone hosts or clusters, or a mixture of standalone hosts and clusters.
- You want to deploy the VCH to a specific resource pool in your environment. 

If you do not specify the `--compute-resource` option and multiple possible resources exist, or if you specify an invalid resource name, `vic-machine create` fails and suggests valid targets for `--compute-resource` in the failure message. 

* To deploy to a specific resource pool on an ESXi host that is not managed by vCenter Server, specify the name of the resource pool: <pre>--compute-resource  <i>resource_pool_name</i></pre>
* To deploy to a vCenter Server instance that has multiple standalone hosts that are not part of a cluster, specify the IPv4 address or fully qualified domain name (FQDN) of the target host:<pre>--compute-resource <i>host_address</i></pre>
* To deploy to a vCenter Server with multiple clusters, specify the name of the target cluster: <pre>--compute-resource <i>cluster_name</i></pre>
* To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, or to a specific resource pool in a cluster, if the resource pool name is unique across all hosts and clusters, specify the name of the resource pool:<pre>--compute-resource <i>resource_pool_name</i></pre>
* To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, if the resource pool name is not unique across all hosts, specify the IPv4 address or FQDN of the target host and name of the resource pool:<pre>--compute-resource <i>host_name</i>/<i>resource_pool_name</i></pre>
* To deploy to a specific resource pool in a cluster, if the resource pool name is not unique across all clusters, specify the full path to the resource pool:<pre>--compute-resource <i>cluster_name</i>/Resources/<i>resource_pool_name</i></pre>

### `--name` ###

Short name: `-n`

A name for the VCH. If not specified, `vic-machine` sets the name of the VCH to `virtual-container-host`. If a VCH of the same name exists on the ESXi host or in the vCenter Server inventory, or if a folder of the same name exists in the target datastore, `vic-machine create` creates a folder named <code><i>vch_name</i>_1</code>. If the name that you provide contains unsupported characters, `vic-machine create` fails with an error.
 
<pre>--name <i>vch_name</i></pre>

### `--thumbprint` <a id="thumbprint"></a>

Short name: None

If your vSphere environment uses untrusted, self-signed certificates to authenticate connections, you must specify the thumbprint of the vCenter Server or ESXi host certificate in the `--thumbprint` option of all `vic-machine` commands. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

For information about how to obtain the certificate thumbprint for vCenter Server or an ESXi host, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

After you obtain the certificate thumbprint from vCenter Server or an ESXi host, you can set it as an environment variable so that you do not have to specify `--thumbprint` in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

If you run `vic-machine` without the specifying the `--thumbprint` option and the operation fails, the resulting error message includes the certificate thumbprint. Always verify that the thumbprint in the error message is valid before attempting to run the command again.
 
**CAUTION**: Specifying the `--force` option bypasses certificate thumbprint verification. Using `--force` in this way exposes VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` also bypasses other checks, and can result in data loss.

Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

<pre>--thumbprint <i>certificate_thumbprint</i></pre>

### `--use-rp` ###

Short name: none

Deploy the VCH appliance to a resource pool on vCenter Server rather than to a vApp. If you specify this option, `vic-machine create` creates a resource pool with the same name as the VCH.

**NOTE**: If you specify both of the `--ops-user` and  `--use-rp` options when you create a VCH, you must specify an additional permission when you create the roles for the operations user. For information about operations user roles and permissions, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

<pre>--use-rp</pre>


## Example `vic-machine` Commmands <a id="example"></a>


### Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores <a id="cluster"></a>

If vCenter Server has more than one datacenter, you specify the datacenter in the `--target` option.

If vCenter Server manages more than one cluster, you use the `--compute-resource` option to specify the cluster on which to deploy the VCH.

When deploying a VCH to vCenter Server, you must use the `--bridge-network` option to specify an existing port group for container VMs to use to communicate with each other. For information about how to create a distributed virtual switch and port group, see the section on vCenter Server Network Requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md#networkreqs).

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user and password in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses a port group named `vic-bridge` for the bridge network. 
- Designates `datastore1` as the datastore in which to store container images, the files for the VCH appliance, and container VMs. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>


### Deploy to a Specific Standalone Host in vCenter Server <a id="standalone"></a> 

If vCenter Server manages multiple standalone ESXi hosts that are not part of a cluster, you use the `--compute-resource` option to specify the address of the ESXi host to which to deploy the VCH.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, bridge network, and name for the VCH.
- Deploys the VCH on the ESXi host with the FQDN `esxihost1.organization.company.com` in the datacenter `dc1`. You can also specify an IP address.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--image-store datastore1
--bridge-network vch1-bridge
--compute-resource esxihost1.organization.company.com
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>


### Deploy to a Resource Pool on an ESXi Host <a id="rp_host"></a>

To deploy a VCH in a specific resource pool on an ESXi host that is not managed by vCenter Server, you specify the resource pool name in the `--compute-resource` option. 

This example deploys a VCH with the following configuration:

- Specifies the user name and password, image store, and a name for the VCH.
- Designates `rp 1` as the resource pool in which to place the VCH. The resource pool name is wrapped in quotes, because it contains a space.

<pre>vic-machine-<i>operating_system</i> create
--target root:<i>password</i>@<i>esxi_host_address</i>
--compute-resource 'rp 1'
--image-store datastore1
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
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
--no-tls
</pre>

If the name of the resource pool is not unique across all clusters, for example if two clusters each contain a resource pool named `rp 1`, you must specify the full path to the resource pool in the `compute-resource` option, in the format <i>cluster_name</i>/Resources/<i>resource_pool_name</i>.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'cluster 1'/Resources/'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>






