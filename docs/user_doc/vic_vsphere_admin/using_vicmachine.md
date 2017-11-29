# Using the `vic-machine` CLI Utility #

After you deploy the vSphere Integrated Containers appliance, you download the vSphere Integrated Containers Engine bundle from the appliance to your usual working machine. For information about how to download the bundle, see [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md).

The vSphere Integrated Containers Engine bundle includes the `vic-machine` CLI utility. You use `vic-machine` to deploy and manage virtual container hosts (VCHs) at the command line. 

- [Running `vic-machine` Commands](#runcommands)
- [Specifying Option Arguments](#args)
- [Common `vic-machine` Options](#options)
- [Other `vic-machine` Options](#otheroptions)

## Running `vic-machine` Commands <a id="runcommands"></a>

You run `vic-machine` commands by specifying the appropriate binary for the platform on which you are using `vic-machine`, the `vic-machine` command, and multiple options for that command. 

For example, you use the `vic-machine create` command to deploy VCHs:

<pre>vic-machine-windows create --<i>option</i> <i>argument</i> --<i>option</i> <i>argument</i></pre>
<pre>vic-machine-linux create --<i>option</i> <i>argument</i> --<i>option</i> <i>argument</i></pre>
<pre>vic-machine-darwin create --<i>option</i> <i>argument</i> --<i>option</i> <i>argument</i></pre>

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

## Common `vic-machine` Options <a id="options"></a>

The following `vic-machine` options identify the location for the VCH and the credentials with which `vic-machine` performs operations in vSphere. These options are common to all `vic-machine` commands.

### `--target` <a id="target"></a>

**Short name**: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you are deploying a VCH. This option is always **mandatory** when using `vic-machine`.

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

You can configure a VCH so that it uses a non-administrator account with reduced privileges for post-deployment operations by specifying the `--ops-user` option. If you do not specify `--ops-user`, VCHs use the vSphere administrator account that you specify in `--user` for general post-deployment operations. For information about using a different account for post-deployment operation, [Configure Operations User](set_up_ops_user.md).

**Usage**:

<pre>--user <i>esxi_or_vcenter_server_username</i></pre>

### `--password` <a id="password"></a>

**Short name**: `-p`

The password for the vSphere administrator account on the vCenter Server on which you are deploying the VCH, or the password for the ESXi host if you are deploying directly to an ESXi host. If not specified, `vic-machine` prompts you to enter the password during deployment.

You can also specify the user name and password in the URL that you pass to `vic-machine create` in the `--target` option, in which case the `--password` option is not required.

You can set an environment variable so that you do not have to specify `--password` in every `vic-machine` command. For information about setting `vic-machine` environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

**Usage**:

<pre>--password <i>esxi_host_or_vcenter_server_password</i></pre>

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

## Other `vic-machine create` Options <a id="otheroptions"></a>

The `vic-machine create` command provides many options that allow you to customize the deployment of VCHs to correspond to your vSphere environment and to meet your development requirements.

For information about the other `vic-machine create` options, see the following topics:

- [General Virtual Container Host Settings](vch_general_settings.md)
- [Virtual Container Host Compute Capacity](vch_compute.md)
- [Virtual Container Host Storage Capacity](vch_storage.md)
- [Virtual Container Host Networks](vch_networking.md)
- [Virtual Container Host Security](vch_security.md)
- [Configure Operations User](set_up_ops_user.md)