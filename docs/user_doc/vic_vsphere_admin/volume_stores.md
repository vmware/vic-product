# Specify Volume Stores #

Volume stores for virtual container hosts (VCHs) are datastores in which to create volumes when container developers use the `docker volume create` command or deploy containers from images that use volumes. You can specify either a datastore that is backed by vSphere or an NFS share point as the volume store.

If you are deploying the VCH to a vCenter Server cluster, the vSphere datastores that you designate as volume stores should be shared by at least two ESXi hosts in the cluster. Using non-shared datastores is possible and `vic-machine create` succeeds, but it issues a warning that this configuration limits the use of vSphere features such as vSphere vMotion and DRS.

If you use NFS volume stores, container developers can share the data in the volumes in the volume stores between containers by attaching the same volume to multiple containers. For example, you can use shared NFS volume stores to share configuration information between containers, or to allow containers to access the data of another container. To use shared NFS volume stores, it is recommended that the NFS share points that you designate as the volume stores be directly accessible by the network that you use as the container network. For information about container networks, see the description of the [`--container-network`](#container-network) option.

**IMPORTANT** If you do not specify a volume store, no volume store is created by default and container developers cannot create or run containers that use volumes. You can add volume stores to a VCH after deployment by running `vic-machine configure --volume-store`. For information about adding volume stores after deployment, see [Add Volume Stores](configure_vch.md#volumes).

For information about how Docker containers use volumes, see [Use volumes](https://docs.docker.com/engine/admin/volumes/volumes/) in the Docker documentation.

- [`vic-machine` Option](#option)
  - [Usage for vSphere Datastores](#vsphereusage)
  - [Usage for NFS Datastores](#nfsusage)
  - [Default Volumes Stores and Anonymous Volumes](#default)
- [Example `vic-machine` Command](#example)

## `vic-machine` Option <a id="options"></a>

You specify a volume store by using the `vic-machine create --volume-store` option.

### `--volume-store` <a id="volume-store"></a>

**Short name**: `--vs`

To specify a datastore for use as a volume store, you provide the datastore name or NFS mount point, an optional path to a specific folder in that datastore, and a volume store label.  

The label that you specify is the volume store name that Docker uses. For example, the volume store label appears in the information for a VCH when container developers run `docker info`. Container developers specify the volume store label in the <code>docker volume create --opt VolumeStore=<i>volume_store_label</i></code> option when they create a volume. The volume store label must be unique.

You can specify the `--volume-store` option multiple times, to create multiple volume stores for a single VCH. If you specify an invalid vSphere datastore name or an invalid NFS share point URL, `vic-machine create` fails and suggests valid datastores. 

**Usage for vSphere Datastores**: <a id="vsphereusage"></a>

To specify a whole vSphere datastore for use as a volume store, you provide the datastore name and a volume store label.

<pre>--volume-store <i>datastore_name</i>:<i>volume_store_label</i></pre>

You can optionally use the `ds://` prefix when specifying a datastore that is backed by vSphere.

<pre>--volume-store ds://<i>datastore_name</i>:<i>volume_store_label</i></pre>

If you specify a vSphere datastore without specifying a path to a specific datastore folder, `vic-machine create` creates a folder named `VIC/volumes` at the top level of the target datastore. Any volumes that container developers create will appear in the `VIC/volumes` folder. 

If you specify a vSphere datastore and a datastore path, `vic-machine create` creates a folder named `volumes` in the location that you specify in the datastore path. If the folders that you specify in the path do not already exist on the datastore, `vic-machine create` creates the appropriate folder structure.  Any volumes that container developers create will appear in the <code><i>path</i>/volumes</code> folder. 

<pre>--volume-store <i>datastore_name</i>/<i>datastore_path</i>:<i>volume_store_label</i></pre>    

The `vic-machine create` command creates the `volumes` folder independently from the folders for VCH files so that you can share volume stores between VCHs. If you delete a VCH, any volumes that the VCH managed will remain available in the volume store unless you manually delete them or you specify the `--force` option when you delete the VCH. You can assign an existing volume store that already contains data to another VCH by either creating a new VCH or by running `vic-machine configure --volume-store` on an existing one. 

**IMPORTANT**: If multiple VCHs will use the same datastore for their volume stores, specify a different datastore folder for each VCH. Do not designate the same datastore folder as the volume store for multiple VCHs.

**Usage for NFS Datastores**: <a id="nfsusage"></a>

To specify an NFS share point as a volume store, use the `nfs://` prefix and the path to a shared mount point.

**IMPORTANT**: When container developers run `docker info` or `docker volume ls` against a VCH, there is currently no indication whether a volume store is backed by vSphere or by an NFS share point. Consequently, you should include an indication that a volume store is an NFS share point in the volume store label. 

<pre>nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:<i>nfs_volume_store_label</i></pre>

You can also specify the URL, UID, GID, and access protocol of a shared NFS mount point when you specify an NFS share point.
<pre>--volume-store nfs://<i>datastore_address</i>/<i>path_to_share_point</i>?uid=1234&gid=5678&proto=tcp:<i>nfs_volume_store_label</i></pre>

If you do not specify a UID and GID, vSphere Integrated Containers Engine uses the `anon` UID and GID when creating and interacting with the volume store. The `anon` UID and GID is 1000.    

You cannot specify the root folder of an NFS server as a volume store.

You can specify the `--volume-store` option multiple times, and add a mixture of vSphere datastores and NFS share points to a VCH.

<pre>--volume-store <i>datastore_name</i>/path:<i>volume_store_label_1</i>
--volume-store <i>datastore_name</i>/<i>path</i>:<i>volume_store_label_2</i>
--volume-store nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:<i>nfs_volume_store_label</i>
</pre> 

**Default Volumes Stores and Anonymous Volumes**: <a id="default"></a>

If you only require one volume store, set the volume store label to `default`. If you set the volume store label to `default`, container developers do not need to specify the <code>--opt VolumeStore=<i>volume_store_label</i></code> option when they run `docker volume create`. Also, some common container images require the presence of a `default` volume store in order to run.

**IMPORTANT**: If container developers intend to create containers that are attached to anonymous or named volumes by using `docker create -v` , you must create a volume store with a label of `default`.

<pre>--volume-store <i>datastore_name</i>:default</pre>
<pre>--volume-store nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:default</pre>

## Example `vic-machine` Commmand <a id="example"></a>

This example `vic-machine create` command deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, cluster, bridge network, and name for the VCH.
- Specifies the `volumes` folder on `datastore 1` as the default volume store. Creating a volume store named `default` allows common container images that use volumes to run, and allows container application developers to create anonymous or named volumes. 
- Specifies a second volume store named `volume_store_2` in the `volumes` folder on `datastore 2`. 
- Specifies a volume store named `shared_volume` in a NFS share point, from which containers can mount shared volumes.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.

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
