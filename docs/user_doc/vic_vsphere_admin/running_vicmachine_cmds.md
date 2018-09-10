# Running `vic-machine` Commands 

You run `vic-machine` commands by specifying the appropriate binary for the platform on which you are using `vic-machine`, the `vic-machine` command to run, and multiple options for that command. 

You use the `vic-machine create` command to deploy VCHs:

<pre>vic-machine-windows create --<i>option</i> <i>argument</i> --<i>option</i> <i>argument</i></pre>
<pre>vic-machine-linux create --<i>option</i> <i>argument</i> --<i>option</i> <i>argument</i></pre>
<pre>vic-machine-darwin create --<i>option</i> <i>argument</i> --<i>option</i> <i>argument</i></pre>

- [Specifying Option Arguments](#args)
- [Basic `vic-machine` Options](#options)
- [Other `vic-machine` Options](#otheroptions)

## Specifying Option Arguments <a id="args"></a>

Wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system. 

Option arguments that might require quotation marks include the following:

- User names and passwords in `--target`, or in `--user` and `--password`.
- Datacenter names in `--target`.
- VCH names in `--name`.
- Datastore names and paths in `--image-store` and `--volume-store`.
- Network and port group names in all networking options.
- Cluster and resource pool names in `--compute-resource`.
- Folder names in the paths for `--tls-cert-path`, `--tls-server-cert`, `--tls-server-key`, `--appliance-iso`, and `--bootstrap-iso`.

For example, to deploy a VCH into a cluster named `cluster 1` in a vCenter Server instance that requires the  vSphere administrator account `Administrator@vsphere.local`, you must wrap the corresponding option arguments in quotes:

<pre>vic-machine-linux 
--target <i>vcenter_server_address</i>
--user 'Administrator@vsphere.local'
--compute-resource 'cluster 1'
[...]
</pre>
<pre>vic-machine-windows 
--target <i>vcenter_server_address</i>
--user "Administrator@vsphere.local"
--compute-resource "cluster 1"
[...]
</pre>

## Basic `vic-machine create` Options <a id="options"></a>

The `vic-machine` options in this section are common to all `vic-machine` commands.

You can set environment variables so that you do not have to specify the `--target`, `--user`, `--password`, and `--thumbprint` options in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Common `vic-machine` Options](vic_env_variables.md).

If you use the Create Virtual Container Host wizard, it deploys VCHs to the vCenter Server instance with which the vSphere Integrated Containers appliance is registered, and uses the vSphere credentials with which you are logged in to the vSphere Client. Consequently, when using the Create Virtual Container Host wizard, you do not need to provide any information about the deployment target, vSphere  administrator credentials, or vSphere certificate thumbprints.

### `--target` <a id="target"></a>

**Short name**: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you are deploying a VCH. This option is always **mandatory** when using `vic-machine`.

To facilitate IP address changes in your infrastructure, provide an FQDN whenever possible, rather than an IP address. If `vic-machine create` cannot resolve the FQDN, it fails with an error.

**Usage**:

If the target ESXi host is not managed by vCenter Server, provide the address of the ESXi host.<pre>--target <i>esxi_host_address</i></pre>

If the target ESXi host is managed by vCenter Server, or if you are deploying to a cluster, provide the address of vCenter Server.<pre>--target <i>vcenter_server_address</i></pre>

You can include the user name and password in the target URL. If you are deploying a VCH on vCenter Server, specify the user name for an account that has the Administrator role on that vCenter Server instance. <pre>--target <i>vcenter_or_esxi_username</i>:<i>password</i>@<i>vcenter_or_esxi_address</i></pre>
  
If you do not include the user name in the target URL, you must specify the `--user` option. If you do not specify the `--password` option or include the password in the target URL, `vic-machine` prompts you to enter the password.

If you are deploying a VCH on a vCenter Server instance that includes more than one datacenter, include the datacenter name in the target URL. If you include an invalid datacenter name, `vic-machine create` fails and suggests the available datacenters that you can specify.  <pre>--target <i>vcenter_server_address</i>/<i>datacenter_name</i></pre>

### `--user` <a id="user"></a>

**Short name**: `-u`

The user name for the ESXi host or vCenter Server instance on which you are deploying a VCH.

If you are deploying a VCH on vCenter Server, specify a user name for an account that has the Administrator role on that vCenter Server instance. 

You can also specify the user name in the URL that you pass to `vic-machine create` in the `--target` option, in which case the `--user` option is not required.

You can configure a VCH so that it uses a non-administrator account with reduced privileges for post-deployment operations by specifying the `--ops-user` option. If you do not specify `--ops-user`, VCHs use the vSphere administrator account that you specify in `--user` for general post-deployment operations. For information about using a different account for post-deployment operation, see [Configure the Operations User](set_up_ops_user.md).

**Usage**:

<pre>--user <i>esxi_or_vcenter_server_username</i></pre>

### `--password` <a id="password"></a>

**Short name**: `-p`

The password for the vSphere administrator account on the vCenter Server on which you are deploying the VCH, or the password for the ESXi host if you are deploying directly to an ESXi host. If not specified, `vic-machine` prompts you to enter the password during deployment.

You can also specify the user name and password in the URL that you pass to `vic-machine create` in the `--target` option, in which case the `--password` option is not required.

**Usage**:

<pre>--password <i>esxi_host_or_vcenter_server_password</i></pre>

### `--thumbprint` <a id="thumbprint"></a>

**Short name**: None

If your vSphere environment uses untrusted, self-signed certificates to authenticate connections, you must specify the thumbprint of the vCenter Server or ESXi host certificate in the `--thumbprint` option of all `vic-machine` commands. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

For information about how to obtain the certificate thumbprint for vCenter Server or an ESXi host, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

If you run `vic-machine` without the specifying the `--thumbprint` option and the operation fails, the resulting error message includes the certificate thumbprint. Always verify that the thumbprint in the error message is valid before attempting to run the command again.
 
**CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments. 

Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

**Usage**:

<pre>--thumbprint <i>certificate_thumbprint</i></pre>

### `--force` <a id="force"></a>

Short name: `-f`

Forces `vic-machine create` to ignore warnings and non-fatal errors and continue with the deployment of a VCH. Errors such as an incorrect compute resource still cause the deployment to fail.

**CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments. 

**Usage**:

<pre>--force</pre>

### `--timeout` <a id="timeout"></a>

**Short name**: none

The timeout period for uploading the vSphere Integrated Containers Engine files and ISOs to the ESXi host, and for powering on the VCH. Specify a value in the format `XmYs` if the default timeout of 3m0s is insufficient. 

**Usage**:

<pre>--timeout 5m0s</pre> 

## Other `vic-machine create` Options <a id="otheroptions"></a>

The `vic-machine create` command provides many more options that allow you to customize the deployment of VCHs to correspond to your vSphere environment and to meet your development requirements.

For information about the other VCH deployment options, see the following topics:

- [General Virtual Container Host Settings](vch_general_settings.md)
- [Virtual Container Host Compute Capacity](vch_compute.md)
- [Virtual Container Host Storage Capacity](vch_storage.md)
- [Virtual Container Host Networks](vch_networking.md)
- [Virtual Container Host Security](vch_security.md)
- [Configure Registry Access](vch_registry.md)
- [Configure the Operations User](set_up_ops_user.md)
- [Virtual Container Host Compute Capacity](vch_compute.md)
- [Virtual Container Host Boot Options](vch_boot_options.md)

The options that these topics describe apply to both the `vic-machine` CLI utility and to the Create Virtual Container Host wizard in the vSphere Client. 

For the full list of `vic-machine create` options, with links to the relevant sections of the documentation, see [`vic-machine` Options Reference](vicmachine_options_ref.md).