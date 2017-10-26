# Common `vic-machine` Options #

This section describes the options that are common to all `vic-machine` commands. The common options that `vic-machine` requires relate to the vSphere environment in which you deployed the virtual container host (VCH), and to the VCH itself.  

**NOTE**: Wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system. 

Option arguments that might require quotation marks include the following:

- User names and passwords in `--target`, or in `--user` and `--password`.
- Datacenter names in `--target`.
- VCH names in `--name`.
- Datastore names and paths in `--image-store`.
- Cluster and resource pool names in `--compute-resource`.

You can set environment variables for the `--target`, `--user`, `--password`, and `--thumbprint` options. For information about setting environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

### `--target` ###

Short name: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you deployed the VCH. This option is always **mandatory**.

- If the target ESXi host is not managed by vCenter Server, provide the address of the host.<pre>--target <i>esxi_host_address</i></pre>
- If the target ESXi host is managed by vCenter Server, or if you deployed the VCH to a cluster, provide the address of vCenter Server.<pre>--target <i>vcenter_server_address</i></pre>
- You can include the user name and password in the target URL.  The user account that you specify must have vSphere administrator privileges.<pre>--target <i>vcenter_or_esxi_username</i>:<i>password</i>@<i>vcenter_or_esxi_address</i></pre>
  
  If you do not include the user name in the target URL, you must specify the `user` option. If you do not specify the `password` option or include the password in the target URL, `vic-machine` prompts you to enter the password.
- If you deployed the VCH on a vCenter Server instance that includes more than one datacenter, include the datacenter name in the target URL. If you include an invalid datacenter name, `vic-machine` fails and suggests the available datacenters that you can specify.<pre>--target <i>vcenter_server_address</i>/<i>datacenter_name</i></pre>


### `--user` ###

Short name: `-u`

The ESXi host or vCenter Server user account with which to run the `vic-machine` command. This option is mandatory if you do not specify the username in the `target` option. The user account that you specify in `--user` must have vSphere administrator privileges.

<pre>--user <i>esxi_or_vcenter_server_username</i></pre>

### `--password` ###

Short name: `-p`

The password for the user account on the vCenter Server on which you  deployed the VCH, or the password for the ESXi host if you deployed directly to an ESXi host. If not specified, `vic-machine` prompts you to enter the password.

<pre>--password <i>esxi_host_or_vcenter_server_password</i></pre>

### `--thumbprint` ###

Short name: None

The thumbprint of the vCenter Server or ESXi host certificate. Specify this option if your vSphere environment uses untrusted, self-signed certificates. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

If you run `vic-machine` without the specifying the `--thumbprint` option and the operation fails, the resulting error message includes the certificate thumbprint. Always verify that the thumbprint in the error message is valid before attempting to run the command again.  

For information about how to obtain the certificate thumbprint either before running `vic-machine` or to verify a thumbprint from a `vic-machine` error message, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md). 

**CAUTION**: Specifying the `--force` option bypasses certificate thumbprint verification. Using `--force` in this way exposes VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` also bypasses other checks, and can result in data loss.

Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

<pre>--thumbprint <i>certificate_thumbprint</i></pre>

### `--compute-resource` ###

Short name: `-r`

The relative path to the host, cluster, or resource pool in which you deployed the VCH. Specify `--compute-resource` with exactly the same value that you used when you ran `vic-machine create`. You specify the `compute-resource` option in the following circumstances:

- vCenter Server includes multiple instances of standalone hosts or clusters, or a mixture of standalone hosts and clusters.
- You deployed the VCH in a specific resource pool in your environment. 

If you specify the `id` option, you do not need to specify the `compute-resource` option.

If you do not specify the `compute-resource` or `id` options and multiple possible resources exist, `vic-machine` fails and suggests valid targets for `compute-resource` in the failure message. 

* If the VCH is in a specific resource pool on an ESXi host, specify the name of the resource pool: <pre>--compute-resource  <i>resource_pool_name</i></pre>
* If the VCH is on a vCenter Server instance that has more than one standalone host but no clusters, specify the IPv4 address or fully qualified domain name (FQDN) of the target host:<pre>--compute-resource <i>host_address</i></pre>
* If the VCH is on a vCenter Server with more than one cluster, specify the name of the target cluster: <pre>--compute-resource <i>cluster_name</i></pre>
* If the VCH is in a specific resource pool on a standalone host that is managed by vCenter Server, specify the IPv4 address or FQDN of the target host and name of the resource pool:<pre>--compute-resource <i>host_name</i>/<i>resource_pool_name</i></pre>
* If the VCH is in a specific resource pool in a cluster, specify the names of the target cluster and the resource pool:<pre>--compute-resource <i>cluster_name</i>/<i>resource_pool_name</i></pre>

### `--name` ###

Short name: `-n`

The name of the VCH. This option is mandatory if the VCH has a name other than the default name, `virtual-container-host`, or if you do not use the `id` option. Specify `--name` with exactly the same value that you used when you ran `vic-machine create`. This option is not used by `vic-machine ls`.

<pre>--name <i>vch_appliance_name</i></pre>

### `--id` ###

Short name: None

The vSphere Managed Object Reference, or moref, of the VCH, for example `vm-100`.  You obtain the ID of a VCH by running `vic-machine ls`. If you specify the `id` option, you do not need to specify the `--name` or `--compute-resource` options. This option is not used by `vic-machine create` or `vic-machine version`.

<pre>--id <i>vch_id</i></pre>

### `--timeout` ###

Short name: none

The timeout period for performing operations on the VCH. Specify a value in the format `XmYs` if the default timeout is insufficient.

<pre>--timeout 5m0s</pre> 
