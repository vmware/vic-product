# Common `vic-machine` Options #

This section describes the options that are common to all `vic-machine` commands. The common options that `vic-machine` requires relate to the vSphere environment in which you deployed the virtual container host (VCH), and to the VCH itself.  

Wrap any option arguments that include spaces or special characters in quotes. For information about option arguments that might require quotes, see [Specifying Option Arguments](using_vicmachine.md#args).

You can set environment variables for the `--target`, `--user`, `--password`, and `--thumbprint` options. For information about setting environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

### `--id` ###

Short name: None

The vSphere Managed Object Reference, or moref, of the VCH, for example `vm-100`.  You obtain the ID of a VCH by running `vic-machine ls`. If you specify the `id` option in `vic-machine` commands, you do not need to specify the `--name` or `--compute-resource` options. This option is not used by `vic-machine create` or `vic-machine version`.

<pre>--id <i>vch_id</i></pre>

### `--target` ###

Short name: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you deployed the VCH. This option is always **mandatory**. You specify this option in the same way as you specify the [`vic-machine create --target`](using_vicmachine.md#target) option.

### `--user` ###

Short name: `-u`

The ESXi host or vCenter Server user account with which to run the `vic-machine` command. The user account that you specify in `--user` must have vSphere administrator privileges. You specify this option in the same way as you specify [`vic-machine create --user`](using_vicmachine.md#user).

### `--password` ###

Short name: `-p`

The password for the user account on the vCenter Server on which you  deployed the VCH, or the password for the ESXi host if you deployed directly to an ESXi host. You specify this option in the same way as you specify [`vic-machine create --password`](using_vicmachine.md#password).

### `--thumbprint` ###

Short name: None

The thumbprint of the vCenter Server or ESXi host certificate. You specify this option in the same way as you specify [`vic-machine create --thumbprint`](using_vicmachine.md#thumbprint).

### `--compute-resource` ###

Short name: `-r`

The relative path to the host, cluster, or resource pool in which you deployed the VCH. You specify this option in the same way as you specify  [`vic-machine create --compute-resource`](vch_compute.md#compute-resource).

**NOTE**: If you specify the `id` option in `vic-machine` commands, you do not need to specify the `compute-resource` option.

### `--name` ###

Short name: `-n`

The name of the VCH. This option is mandatory if the VCH has a name other than the default name, `virtual-container-host`, or if you do not use the `id` option. You specify this option in the same way as you specify [`vic-machine create --name`](vch_using_vicmachine.md#name).

### `--timeout` ###

Short name: none

The timeout period for performing operations on the VCH. Specify a value in the format `XmYs` if the default timeout is insufficient.

<pre>--timeout 5m0s</pre> 
