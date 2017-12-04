# Specify the Image Store #

The image store for a virtual container host (VCH) is the vSphere datastore in which to store container image files, container VM files, and the files for the VCH itself. 

Specifying an image store is **mandatory** if there is more than one datastore in your vSphere environment. If there is only one datastore in your vSphere environment, `vic-machine` uses it automatically and you do not need to specify the datastore.

When container developers create and run containers, vSphere Integrated Containers Engine stores the files for container VMs at the top level of the image store, in folders that have the same names as the container VMs.

- [`vic-machine `Option](#option)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Option <a id="option"></a>

You specify an image store by using the `vic-machine create --image-store` option.

### `--image-store` <a id="image"></a>

**Short name**: `-i`

If you are deploying the VCH to a vCenter Server cluster, the datastore that you designate as the image store must be shared by at least two ESXi hosts in the cluster. Using non-shared datastores is possible, but limits the use of vSphere features such as vSphere vMotion&reg; and VMware vSphere Distributed Resource Scheduler&trade; (DRS).

If you do not specify the `--image-store` option and multiple possible datastores exist, or if you specify an invalid datastore name, `vic-machine create` fails and suggests valid datastores in the failure message. 

**Usage**:

To specify a whole datastore as the image store, specify the datastore name in the `--image-store` option:

<pre>--image-store <i>datastore_name</i></pre>

If you designate a whole datastore as the image store, `vic-machine` creates the following set of folders in the target datastore: 

-  <code><i>datastore_name</i>/VIC/<i>vch_uuid</i>/images</code>, in which to store all of the container images that you pull into the VCH.
- <code><i>datastore_name</i>/<i>vch_name</i></code>, that contains the VM files for the VCH.
- <code><i>datastore_name</i>/<i>vch_name</i>/kvstores</code>, a key-value store folder for the VCH.

You can specify a datastore folder to use as the image store by specifying a path in the `--image-store` option: 

<pre>--image-store <i>datastore_name</i>/<i>path</i>/<i>to</i>/<i>folder</i></pre> 

If the folder that you specify does not already exist, `vic-machine create` creates it.

If you designate a datastore folder as the image store, `vic-machine` creates the following set of folders in the target datastore:

- <code><i>datastore_name</i>/<i>path</i>/VIC/<i>vcu_uuid</i>/images</code>, in which to store all of the container images that you pull into the VCH. 
- <code><i>datastore_name</i>/<i>vch_name</i></code>, that contains the VM files for the VCH. This is the same as if you specified a datastore as the image store.
- <code><i>datastore_name</i>/<i>vch_name</i>/kvstores</code>, a key-value store folder for the VCH. This is the same as if you specified a datastore as the image store.

By specifying the path to a datastore folder in the `--image-store` option, you can designate the same datastore folder as the image store for multiple VCHs. In this way, `vic-machine create` creates only one `VIC` folder in the datastore, at the path that you specify. The `VIC` folder contains one <code><i>vch_uuid</i>/images</code> folder for each VCH that you deploy. By creating one <code><i>vch_uuid</i>/images</code> folder for each VCH, vSphere Integrated Containers Engine limits the potential for conflicts of image use between VCHs, even if you share the same image store folder between multiple hosts.

### `--base-image-size` ###

**Short name**: None

The size of the base image from which to create other images. You should not normally need to use this option. Specify the size in `GB` or `MB`. The default size is 8GB. Images are thin-provisioned, so they do not usually consume 8GB of space. For information about container base images, see [Create a base image](https://docs.docker.com/engine/userguide/eng-image/baseimages/) in the Docker documentation. 

**Usage**:

<pre>--base-image-size 4GB</pre>

## Example `vic-machine` Commmand <a id="example"></a>

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates the folder `vch1_images` in `datastore1` as the image store. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1/vch1_images
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>