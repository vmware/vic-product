# Container VM Configuration #

The `vic-machine create` utility provides options customize the settings with which it creates container VMs.

- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Options <a id="options"></a>

You can set a naming convention on container VMs, change the location of the ISO from which container VMs boot, or adjust the base image size for container VMs.



### `--bootstrap-iso` ###

**Short name**: `--bi`

The path to the ISO image from which to boot container VMs. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

**Usage**:

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>



## Example `vic-machine` Commands <a id="examples"></a>

- [Set a Container Name Convention](#convention)
- [Boot Container VMs from an ISO in a Non-Default Location](#bootstrap-iso)



### Boot Container VMs from an ISO in a Non-Default Location <a id="bootstrap-iso"></a>

If you moved the `bootstrap.iso` file to a location that is not the folder that contains the `vic-machine` binary, you must point `vic-machine` to the ISO file.

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates `datastore1` as the image store. 
- Specifies `--bootstrap-iso` to direct `vic-machine` to the location in which you stored the `appliance.iso` file.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--bootstrap-iso <i>path_to_iso</i>/bootstrap.iso
</pre>