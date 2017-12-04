# Virtual Container Host Appliance Configuration #

The `vic-machine create` utility provides options that customize the settings with which it deploys the virtual container host (VCH) appliance. These options allow you to tailor the VCH to your vSphere environment and to the loads under which it will run.

You can increase or decrease the memory and CPU shares and reservations on the VCH.  You can also provide an alternate path to the ISO from which the VCH boots up.

- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Options <a id="options"></a>

The following `vic-machine create` options modify the configuration of the VCH appliance itself. 



### `--appliance-iso` ###

**Short name**: `--ai`

The path to the ISO image from which the VCH appliance boots. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.

**Usage**:

<pre>--appliance-iso <i>path_to_ISO_file</i>/appliance.iso</pre>

## Example `vic-machine` Commands <a id="examples"></a>

- [Boot the VCH from an ISO in a Non-Default Location](#appliance-iso)



### Boot the VCH from an ISO in a Non-Default Location <a id="appliance-iso"></a>

If you moved the `appliance.iso` file to a location that is not the folder that contains the `vic-machine` binary, you must point `vic-machine` to the ISO file.

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates `datastore1` as the image store. 
- Specifies `--appliance-iso` to direct `vic-machine` to the location in which you stored the `appliance.iso` file.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--appliance-iso <i>path_to_iso</i>/appliance.iso
</pre>