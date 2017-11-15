# Container VM Configuration #

The `vic-machine create` utility provides options customize the settings with which it creates container VMs.

- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Options <a id="options"></a>

You can set a naming convention on container VMs, change the location of the ISO from which container VMs boot, or adjust the base image size for container VMs.

### `--container-name-convention` <a id="container-name-convention"></a>

**Short name**: `--cnc`

Enforce a naming convention for container VMs, that applies a prefix to the names of all container VMs that run in a VCH. Applying a naming convention to container VMs facilitates organizational requirements such as chargeback. The container naming convention applies to the display name of the container VM that appears in the vSphere Client, not to the container name that Docker uses.

You specify the container naming convention by providing a prefix to apply to container names, and adding `-{name}` or `-{id}` to specify whether to use the container name or the container ID for the second part of the container VM display name. If you specify `-{name}`, the container VM display names use either the name that Docker generates, or a name that the container developer specifies in `docker run --name` when they run the container.

**Usage**:

<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}</pre>
<pre>--container-name-convention <i>cVM_name_prefix</i>-{id}</pre>

### `--bootstrap-iso` ###

**Short name**: `--bi`

The path to the ISO image from which to boot container VMs. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

**Usage**:

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>

### `--base-image-size` ###

**Short name**: None

The size of the base image from which to create other images. You should not normally need to use this option. Specify the size in `GB` or `MB`. The default size is 8GB. Images are thin-provisioned, so they do not usually consume 8GB of space. For information about container base images, see [Create a base image](https://docs.docker.com/engine/userguide/eng-image/baseimages/) in the Docker documentation. 

**Usage**:

<pre>--base-image-size 4GB</pre>

### `--container-store` ###

**Short name**: `--cs`

The `container-store` option is not enabled. Container VM files are stored in the datastore that you designate as the image store. 

## Example `vic-machine` Commands <a id="examples"></a>

- [Set a Container Name Convention](#convention)
- [Boot Container VMs from an ISO in a Non-Default Location](#bootstrap-iso)

### Set a Container Name Convention <a id="convention"></a>

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates `datastore1` as the image store. 
- Specifies `--container-name-convention` so that the vCenter Server  display names of all container VMs that run in this VCH include the prefix `vch1-container` followed by the container name.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--container-name-convention vch1-container-{name}
</pre>

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