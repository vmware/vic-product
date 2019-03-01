# Virtual Container Host Boot Options #

The `vic-machine create` utility provides options that change the location of the ISO files from which virtual container hosts (VCHs) and container VMs boot. Optionally use the boot options if you have a centralized store of ISO files.

You can also replace the standard Photon OS 2.0 kernel that runs in container VMs by uploading a custom `bootstrap.iso` file to a VCH. For example, you can upload a custom RedHat Linux ISO file so that container VMs run on RedHat rather than on Photon OS.

## `vic-machine` Options <a id="options"></a>

The options in this topic are only available with the `vic-machine create` command. They are not available in the Create Virtual Container Host wizard in the vSphere Client.

### `--appliance-iso` <a id="appliance-iso"></a>

**Short name**: `--ai`

The path to the ISO image from which the VCH appliance boots. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. 

**NOTES**: 

- Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.
- You cannot use the `--appliance-iso` option to replace the standard Photon OS kernel that runs the appliance with an alternative, custom kernel.

**Usage**:

Include the name of the ISO file in the path.

<pre>--appliance-iso <i>path_to_ISO_file</i>/appliance.iso</pre>

### `--bootstrap-iso` <a id="bootstrap-iso"></a>

**Short name**: `--bi`

The path to the ISO image from which to boot container VMs. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Alternatively, use this option if you want container VMs to run  a custom Linux kernel rather than the standard Photon OS kernel. For information about how to create a custom `bootstrap.iso` file to use instead of the standard Photon OS `bootstrap.iso` file, see the [VIC Engine Appliance and Container VM ISOs](https://github.com/vmware/vic/tree/master/isos/base/repos) document in the vSphere Integrated Containers Engine GitHub repository.

**NOTE**: If you use the standard Photon OS `bootstrap.iso` file, do not use the `--bootstrap-iso` option to point `vic-machine` to a `bootstrap.iso` file that is of a different version to the version of `vic-machine` that you are running.

**Usage**:

Include the name of the ISO file in the path.

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>

## Example `vic-machine` Commands <a id="examples"></a>

If you moved the `appliance.iso` or `bootstrap.iso` file to a location that is not the folder that contains the `vic-machine` binary, or if you want to boot container VMs from an alternative ISO file, you must point `vic-machine` to those ISO files.

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

This example `vic-machine create` command deploys a VCH that specifies `--bootstrap-iso` to direct `vic-machine` to the location in which you stored the `bootstrap.iso` file. This might be because you moved the standard `bootstrap.iso` file to a different location, or because you are using a custom `bootstrap.iso` file.

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