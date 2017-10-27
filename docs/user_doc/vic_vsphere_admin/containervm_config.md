# Container VM Configuration #

### `--base-image-size` ###

Short name: None

The size of the base image from which to create other images. You should not normally need to use this option. Specify the size in `GB` or `MB`. The default size is 8GB. Images are thin-provisioned, so they do not usually consume 8GB of space.  

<pre>--base-image-size 4GB</pre>

### `--container-store` ###

Short name: `--cs`

The `container-store` option is not enabled. Container VM files are stored in the datastore that you designate as the image store. 

### `--bootstrap-iso` ###

Short name: `--bi`

The path to the ISO image from which to boot container VMs. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>


### `--container-name-convention` <a id="container-name-convention"></a>

Short name: `--cnc`

Enforce a naming convention for container VMs, that applies a prefix to the names of all container VMs that run in a VCH. Applying a naming convention to container VMs facilitates organizational requirements such as chargeback. The container naming convention applies to the display name of the container VM that appears in the vSphere Client, not to the container name that Docker uses.

You specify the container naming convention by providing a prefix to apply to container names, and adding `-{name}` or `-{id}` to specify whether to use the container name or the container ID for the second part of the container VM display name. If you specify `-{name}`, the container VM display names use either the name that Docker generates, or a name that the container developer specifies in `docker run --name` when they run the container.

<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}</pre>
<pre>--container-name-convention <i>cVM_name_prefix</i>-{id}</pre>