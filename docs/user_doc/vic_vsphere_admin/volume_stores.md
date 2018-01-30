# Specify Volume Datastores #

Volume stores for virtual container hosts (VCHs) are datastores in which to create volumes when container developers use the `docker volume create` command or deploy containers that use volumes. You can specify volume stores that are either backed by vSphere datastores or by NFSv3 mounts.

- [About Volume Stores](#about)
  - [vSphere Datastores](#vsphereusage)
  - [NFS Volume Stores](#nfsusage)
  - [Anonymous Volumes](#default)
- [Add Volume Datastores](#volume-store)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Command](#example)

## About Volume Stores <a id="about"></a>

For information about how Docker containers use volumes, see [Use volumes](https://docs.docker.com/engine/admin/volumes/volumes/) in the Docker documentation.

To specify a volume store, you provide the datastore name or NFS mount point, an optional path to a specific folder in that datastore, and a volume store label.  

The label that you specify is the volume store name that Docker uses. For example, the volume store label appears in the information for a VCH when container developers run `docker info`. Container developers specify the volume store label in the <code>docker volume create --opt VolumeStore=<i>volume_store_label</i></code> option when they create a volume. The volume store label must be unique.

You can create multiple volume stores for a single VCH. 

**IMPORTANT**: If you do not specify a volume store when you create a VCH, no volume store is created by default and container developers cannot create or run containers that use volumes. You can add volume stores to a VCH after deployment by running `vic-machine configure --volume-store`. For information about adding volume stores after deployment, see [Add Volume Stores](configure_vch.md#volumes).

If you delete a VCH, by default any volumes that the VCH manages remain available in the volume store. There are different ways to delete volumes that are no longer required:

- Delete the volumes manually in the vSphere Client.
- Run `docker rm -v`.
- Run `vic-machine delete` with the `--force` option.
- Select **Delete persistent and anonymous volumes** when you delete the VCH in the vSphere Client.

### vSphere Datastores <a id="vsphere"></a>

If you are deploying the VCH to a vCenter Server cluster, the vSphere datastores that you designate as volume stores should be shared by at least two, but preferably all, ESXi hosts in the cluster. Using non-shared datastores is possible and deployment succeeds, but results in a warning that this configuration limits the use of vSphere features such as vSphere vMotion and DRS.

If you specify a vSphere datastore without specifying a datastore folder, vSphere Integrated Containers Engine creates a folder named `VIC/volumes` at the top level of the target datastore. Any volumes that container developers create will appear in the `VIC/volumes` folder. 

If you specify a vSphere datastore and a datastore folder, vSphere Integrated Containers Engine creates a folder named `volumes` in the location that you specify. If the folders that you specify do not already exist on the datastore, vSphere Integrated Containers Engine creates the appropriate folder structure. Any volumes that container developers create will appear in the <code><i>path</i>/volumes</code> folder. 

vSphere Integrated Containers Engine creates the `volumes` folder independently from the folders for VCH files so that you can attach  existing volume stores to different VCHs. You can assign an existing volume store that already contains data to a VCH by either creating a new VCH or by running `vic-machine configure --volume-store` on an existing one. You can only assign a volume store to a single VCH at a time.

**IMPORTANT**: If multiple VCHs use the same datastore for their volume stores, specify a different datastore folder for each VCH. Do not designate the same datastore folder as the volume store for multiple VCHs.

### NFS Volume Stores <a id="nfsusage"></a>

If you use NFS volume stores, container developers can share the data in the volumes in the volume stores between running containers by attaching the same volume to multiple containers. For example, you can use shared NFS volume stores to share configuration information between running containers, or to allow running containers to access the data of another container. To use shared NFS volume stores, it is recommended that the NFS share points that you designate as the volume stores be directly accessible by the network that you use as the container network. For information about container networks, see the description of the [`--container-network`](#container-network) option.

**IMPORTANT**: When container developers run `docker info` or `docker volume ls` against a VCH, there is currently no indication whether a volume store is backed by vSphere or by an NFS share point. Consequently, you should include an indication that a volume store is an NFS share point in the volume store label. 

You cannot specify the root folder of an NFS server as a volume store.

#### Testing and Debugging NFS Volume Store Configuration

After you deploy a VCH, you can test that an NFS share point is configured correctly so that containers can access it by mounting the NFS share point directly in the VCH endpoint VM. For information about how to perform this test, see [Install Packages in the Virtual Container Host Endpoint VM](vch_install_packages.md) and [Mount an NFS Share Point in the VCH Endpoint VM](vch_mount_nfsshare.md).

Another option is to start a container that has an NFS client and attempt to mount the NFS share point in that container. This is a good option for VCH users that do not have access to `vic-machine` and cannot log in to the VCH by using SSH.

### Anonymous Volumes <a id="default"></a>

If you only require one volume store, set the volume store label to `default`. If you set the volume store label to `default`, container developers do not need to specify the <code>--opt VolumeStore=<i>volume_store_label</i></code> option when they run `docker volume create`. Also, some common container images require the presence of a `default` volume store in order to run.

**IMPORTANT**: If container developers intend to create containers that are attached to anonymous or named volumes by using `docker create -v` , you must create a volume store with a label of `default`.

## Add Volume Datastores <a id="volume-store"></a> 

This section describes the Volume Datastores section of the Storage Capacity page of the Create Virtual Container Host wizard, and the  corresponding `vic-machine create` option.

#### Create VCH Wizard

1. Optionally enable anonymous volumes by setting the **Enable anonymous volumes** switch to the green ON position. 

    Enabling anonymous volumes automatically adds the label `default` to the first volume datastore.
2. Select a datastore for the first volume store from the **Datastore** drop-down menu.
2. In the **Folder** text box, optionally enter the path to a folder in the specified datastore.

    If the folders that you specify in the path do not already exist on the selected datastore, vSphere Integrated Containers Engine creates the appropriate folder structure.
3. If you did not enable anonymous volumes, or if this is an additional volume store, provide a label for the volume store in the **Volume store name** text box.
4. Optionally click the **+** button to add more volume datastores to the VCH, and repeat the proceeding steps for each additional volume datastore.

**NOTE**: It is not currently possible to specify an NFS share point as a volume store in the Create Virtual Container Host wizard. If you use the wizard to create VCHs, after deployment, run `vic-machine configure` with the `--volume-store` option to add NFS share points to the VCH. For information about adding volume stores after deployment, see [Add Volume Stores](configure_vch.md#volumes).

#### vic-machine Option

`--volume-store`, `--vs`

To specify a whole vSphere datastore for use as a volume store, provide the datastore name and a volume store label:

<pre>--volume-store <i>datastore_name</i>:<i>volume_store_label</i></pre>

Optionally use the `ds://` prefix to specify a datastore that is backed by vSphere:

<pre>--volume-store ds://<i>datastore_name</i>:<i>volume_store_label</i></pre>

To specify a volume store in a datastore folder, add the path to the appropriate folder:

<pre>--volume-store <i>datastore_name</i>/<i>datastore_path</i>:<i>volume_store_label</i></pre>   

To specify an NFS share point as a volume store, use the `nfs://` prefix and the path to a shared mount point:

<pre>nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:<i>nfs_volume_store_label</i></pre>

You can also specify the URL, UID, GID, and access protocol of a shared NFS mount point when you specify an NFS share point. If you do not specify a UID and GID, vSphere Integrated Containers Engine uses the `anon` UID and GID when creating and interacting with the volume store. The `anon` UID and GID is 1000:1000.
<pre>--volume-store nfs://<i>datastore_address</i>/<i>path_to_share_point</i>?uid=1234&gid=5678&proto=tcp:<i>nfs_volume_store_label</i></pre> 

Use the label `default` to allow container developers to create anonymous volumes:

<pre>--volume-store ds://<i>datastore_name</i>:default</pre>
<pre>--volume-store nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:default</pre>    

You can specify the `--volume-store` option multiple times, and add a mixture of vSphere datastores and NFS share points to a VCH:

<pre>--volume-store <i>datastore_name</i>/path:<i>volume_store_label_1</i>
--volume-store <i>datastore_name</i>/<i>path</i>:<i>volume_store_label_2</i>
--volume-store nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:<i>nfs_volume_store_label</i>
</pre> 

If you specify an invalid vSphere datastore name or an invalid NFS share point URL, `vic-machine create` fails and suggests valid datastores. 


## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to go to the [VCH Networks](vch_networking.md) settings.

## Example `vic-machine` Commmand <a id="example"></a>

This example `vic-machine create` command deploys a VCH with 3 volume stores: 

- A `default` volume store in the `volumes` folder on `datastore 1`. 
- A second volume store named `volume_store_2` in the `volumes` folder on `datastore 2`. 
- A volume store named `shared_volume` in a NFS share point, from which containers can mount shared volumes.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--bridge-network vch1-bridge
--image-store 'datastore 1'
--volume-store 'datastore 1'/volumes:default
--volume-store 'datastore 2'/volumes:volume_store_2
--volume-store nfs://nfs_store/path/to/share/point:shared_volume
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre> 
