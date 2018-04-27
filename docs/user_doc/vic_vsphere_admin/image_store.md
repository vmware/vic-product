# Specify the Image Datastore #

When you deploy a virtual container host (VCH), you must specify a datastore or datastore folder for use as the image store. The image store is the vSphere datastore in which to store container image files, container VM files, and the files for the VCH itself, including a creation log file. 

You can also optionally change the base image size for container images. 

- [Options](#options)
  - [Datastore](#imagestore)
  - [Base Image Size](#baseimagesize)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Command](#example)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Image Datastore section of the Storage Capacity page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Datastore <a id="imagestore"></a>

If you are deploying the VCH to a vCenter Server cluster, the datastore that you designate as the image store must be shared by at least two, but preferably all, ESXi hosts in the cluster. Using non-shared datastores is possible, but limits the use of vSphere features such as vSphere vMotion&reg; and VMware vSphere Distributed Resource Scheduler&trade; (DRS). Using non-shared datastores might lead to situations in which all container VMs and image files are stored on a single host.

You can specify a datastore folder to use as the image store. If the folder that you specify does not already exist, `vic-machine create` creates it. 

When you deploy a VCH `vic-machine` creates the following set of folders in the image datastore: 

- A folder that contains the VM files of the VCH:<pre><i>datastore_name</i>/<i>vch_name</i></pre>This folder also includes a VCH creation log file named <code>vic-machine_timestamp_create_id.log</code>. 
- A key-value store folder for the VCH:<pre><i>datastore_name</i>/<i>vch_name</i>/kvstores</pre>
- A folder in which to store all of the container images that you pull into the VCH.

    - If you designate the whole datastore as the image store, images are stored in the following location:<pre><i>datastore_name</i>/VIC/<i>vch_uuid</i>/images</pre>
    - If you designate a datastore folder as the image store, images are stored in the following location:<pre><i>datastore_name</i>/<i>path_to_folder</i>/VIC/<i>vcu_uuid</i>/images</pre>

By specifying a datastore folder, you can designate the same datastore folder as the image store for multiple VCHs. Only one `VIC` folder is created in the datastore, but it contains one <code><i>vch_uuid</i>/images</code> folder for each VCH that you deploy. By creating one <code><i>vch_uuid</i>/images</code> folder for each VCH, vSphere Integrated Containers Engine limits the potential for conflicts of image use between VCHs, even if you share the same image store folder between multiple hosts.

When container developers create and run containers, vSphere Integrated Containers Engine stores the files for container VMs at the top level of the image store, in folders that have the same names as the container VMs.

#### Create VCH Wizard

Specifying an image store is **mandatory**.

1. Select a datastore from the **Datastore** drop-down menu.

    Select a datastore that is shared by at least two, but preferably all, hosts in a cluster.
2. In the **File folder** text box, optionally enter the path to a folder in the specified datastore, to use to store image files. 

#### vic-machine Option

`--image-store`, `-i`

Specifying an image store is **mandatory** if there is more than one datastore in your vSphere environment. If there is only one datastore in your vSphere environment, `vic-machine` uses it automatically and you do not need to specify the datastore. If you do not specify the `--image-store` option and multiple possible datastores exist, or if you specify an invalid datastore name, `vic-machine create` fails and suggests valid datastores in the failure message. 

To specify a whole datastore as the image store, specify the datastore name in the `--image-store` option:

<pre>--image-store <i>datastore_name</i></pre>

To specify a datastore folder to use as the image store, include the path to the folder in the `--image-store` option: 

<pre>--image-store <i>datastore_name</i>/<i>path</i>/<i>to</i>/<i>folder</i></pre> 

### Base Image Size <a id="baseimagesize"></a>

The size of the base image from which to create other container images. You should not normally need to use this option. Specify the size in `GB` or `MB`. The default size is 8GB. Images are thin-provisioned, so they do not usually consume 8GB of space. For information about container base images, see [Create a base image](https://docs.docker.com/engine/userguide/eng-image/baseimages/) in the Docker documentation. 

#### Create VCH Wizard

1. In the **Max Container VM image size** text box, leave the default value of 8, or enter a different value.
2. Select **GB** or **MB**.

#### vic-machine Option 

`--base-image-size`, no short name

Specify a value in GB or MB. If not specified, `vic-machine create` sets the image size to 8 GB.

<pre>--base-image-size 4GB</pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, scroll down the page to specify [Volume Datastores](volume_stores.md).

## Example `vic-machine` Commmand <a id="example"></a>

This example `vic-machine create` command deploys a VCH that uses the folder `vch1_images` in `datastore1` as the image store. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1/vch1_images
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>