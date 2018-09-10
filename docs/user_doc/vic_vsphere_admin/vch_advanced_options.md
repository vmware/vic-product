# Advanced Virtual Container Host Deployment Options #

The option in this section are only available if you deploy virtual container hosts (VCHs) by using the `vic-machine create` command. It is not available in the Create Virtual Container Host wizard in the vSphere Client.

* [Virtual Container Host Boot Options](#boot-options)

## Virtual Container Host Boot Options <a id="boot-options"></a>##

The `vic-machine create` utility provides options that change the location of the ISO files from which virtual container hosts (VCHs) and container VMs boot.

### `vic-machine` Options <a id="options"></a>

The options in this topic are only available with the `vic-machine create` command. They are not available in the Create Virtual Container Host wizard in the vSphere Client.

### `--appliance-iso` <a id="appliance-iso"></a>

**Short name**: `--ai`

The path to the ISO image from which the VCH appliance boots. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.

**Usage**:

<pre>--appliance-iso <i>path_to_ISO_file</i>/appliance.iso</pre>

### `--bootstrap-iso` <a id="bootstrap-iso"></a>

**Short name**: `--bi`

The path to the ISO image from which to boot container VMs. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

**Usage**:

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>

## Example `vic-machine` Commands <a id="examples"></a>

If you moved the `appliance.iso` or `bootstrap.iso` file to a location that is not the folder that contains the `vic-machine` binary, you must point `vic-machine` to those ISO files.

This example `vic-machine create` command deploys a VCH that specifies `--appliance-iso` to direct `vic-machine` to the location in which you stored the `appliance.iso` file.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--appliance-iso <i>path_to_iso</i>/appliance.iso
</pre>

This example `vic-machine create` command deploys a VCH that specifies `--bootstrap-iso` to direct `vic-machine` to the location in which you stored the `appliance.iso` file.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--bootstrap-iso <i>path_to_iso</i>/bootstrap.iso
</pre>