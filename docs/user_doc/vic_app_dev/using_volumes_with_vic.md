# Using Volumes with vSphere Integrated Containers #

vSphere Integrated Containers supports the use of container volumes. You can create container volumes either in volume stores on vSphere datastores or in NFS share points that you designate as volume stores. The vSphere datastore or NFS share point houses the volume store and containers build volumes in that volume store.

**IMPORTANT**: To use container volume capabilities with vSphere Integrated Containers, the vSphere administrator must configure one or more volume stores on the virtual container host (VCH). When the vSphere administrator creates a VCH, they can specify a vSphere datastore or NFS share point to use to store container volumes. For information about how to create VCHs with volume stores, see [Specify Volume Stores](../vic_vsphere_admin/volume_stores.md). For information about how to add volume stores to existing VCHs, see [Add Volume Stores](../vic_vsphere_admin/configure_vch.md#volumes).

- [Obtain the List of Available Volume Stores](#list_vs) 
- [Obtain the List of Available Volumes](#list_vols)
- [Create a Volume in a Volume Store](#create_vol)
- [Creating Volumes from Images](#image_volumes)
- [Create a Container with a New Anonymous or Named Volume](#create_container)
  - [Create a Container with a New Anonymous Volume](#create_container_anon)
  - [Create a Container with a Named Volume](#create_container_named)
- [Mount Existing vSphere-Backed Volumes on Containers](#mount)
- [Sharing NFS-Backed Volumes Between Containers](#mount_nfs)
- [Obtain Information About a Volume](#inspect_vol) 
- [Delete a Named Volume from a Volume Store](#delete_vol)
- [Delete a Container and the Anonymous Volumes Attached to It](#delete_anon_vol)
- [Run a Container and Delete the Anonymous Volumes Attached to it when it Stops](#delete_vol_stop)

For simplicity, the examples in this topic assume that the VCHs implement TLS authentication with self-signed server certificates, with no client verification.

## Obtain the List of Available Volume Stores <a id="list_vs"></a>

To obtain the list of volume stores that are available on a VCH, run `docker info`.

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls info</pre>

The list of available volume stores for this VCH appears in the `docker info` output under `VolumeStores`.

<pre>[...]
Storage Driver: vSphere Integrated Containers Backend Engine
VolumeStores: <i>volume_store_1</i> <i>volume_store_2</i> ... <i>volume_store_n</i>
vSphere Integrated Containers Backend Engine: RUNNING
[...]</pre>

## Obtain the List of Available Volumes <a id="list_vols"></a>

To obtain a list of volumes that are available on a VCH, run `docker volume ls`.

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls volume ls

DRIVER         VOLUME NAME
vsphere        <i>volume_1</i>
vsphere        <i>volume_2</i>
[...]          [...]
vsphere        <i>volume_n</i></pre>

## Create a Volume in a Volume Store <a id="create_vol"></a>

When you use the `docker volume create` command to create a volume, you can optionally provide a name for the volume by specifying the `--name` option. If you do not specify `--name`, `docker volume create` assigns a random UUID to the volume.

- If the vSphere administrator created the VCH with one or more volume stores, but none of the volume stores are named `default`, you must specify the name of an existing volume store in the `--opt VolumeStore` option. If you do not specify `--opt VolumeStore`, `docker volume create` searches for a volume store named `default`, and returns an error if no such volume store exists. 

    <pre>docker -H <i>virtual_container_host_address</i>:2376 --tls volume create 
  --opt VolumeStore=<i>volume_store_label</i> 
  --name <i>volume_name</i></pre>

- If the vSphere administrator created the VCH with a volume store named `default`, you do not need to specify `--opt VolumeStore` in the `docker volume create` command. If you do not specify a volume store name, the `docker volume create` command automatically uses the `default` volume store if it exists.

    <pre>docker -H <i>virtual_container_host_address</i>:2376 --tls volume create 
  --name <i>volume_name</i></pre>

- You can optionally set the capacity of a volume by specifying the `--opt Capacity` option when you run `docker volume create`. If you do not specify the `--opt Capacity` option, the volume is created with the default capacity of 1024MB. 

    If you do not specify a unit for the capacity, the default unit will be in Megabytes.
    <pre>docker -H <i>virtual_container_host_address</i>:2376 --tls volume create 
  --opt VolumeStore=<i>volume_store_label</i> 
  --opt Capacity=2048
  --name <i>volume_name</i></pre>

- To create a volume with a capacity in megabytes, gigabytes, or terabytes, include `MB`, `GB`, or `TB` in the value that you pass to `--opt Capacity`. The unit is case insensitive.

    <pre>docker -H <i>virtual_container_host_address</i>:2376 --tls volume create 
  --opt VolumeStore=<i>volume_store_label</i> 
  --opt Capacity=10GB
  --name <i>volume_name</i></pre>

- vSphere Integrated Containers Engine currently only supports `ext4` file systems for volumes.

After you create a volume by using `docker volume create`, you can mount that volume in a container by running either of the following commands:

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
create -v <i>volume_name</i>:/<i>folder</i> busybox</pre>
<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
run -v <i>volume_name</i>:/<i>folder</i> busybox</pre>

In the examples above, Docker mounts the volume <code><i>volume_name</i></code> to <code>/<i>folder</i></code> in the container.

**NOTE**: When using a vSphere Integrated Containers Engine VCH as your Docker endpoint, the storage driver is always the vSphere Integrated Containers Engine Backend Engine. If you specify the `docker volume create --driver` option an error stating that a bad driver has been selected will occur.

## Creating Volumes from Images <a id="image_volumes"></a>

Some images, for example, `mongo` or `redis:alpine`, contain volume bind information in their metadata. vSphere Integrated Containers Engine creates such volumes with the default parameters and treats them as anonymous volumes. vSphere Integrated Containers Engine treats all volume mount paths as unique, in the same way that Docker does. This should be kept in mind if you attempt to bind other volumes to the same location as anonymous or image volumes. A specified volume always takes priority over an anonymous volume.

If you require an image volume with a different volume capacity to the default, create a named volume with the required capacity. You can mount that named volume to the location that the image metadata specifies. You can find the location by running `docker inspect image_name` and consulting the `Volumes` section of the output. The resulting container has the required storage capacity and the endpoint.  

## Create a Container with a New Anonymous or Named Volume <a id="create_container"></a>

If you intend to create named or anonymous volumes by using `docker create -v` when creating containers, a volume store named `default` must exist in the VCH. 

**NOTES**: 
- vSphere Integrated Containers Engine does not support mounting  vSphere datastore folders as data volumes. A command such as <code>docker create -v /<i>folder_name</i>:/<i>folder_name</i> busybox</code> is not supported if the volume store is a vSphere datastore.
- If you use `docker create -v` to create containers and mount new volumes on them, vSphere Integrated Containers Engine only supports the `-r` and `-rw` options.

### Create a Container with a New Anonymous Volume <a id="create_container_anon"></a>

To create an anonymous volume, you include the path to the destination at which you want to mount the anonymous volume in the `docker create -v` command. Docker creates the anonymous volume in the `default` volume store, if it exists. The VCH mounts the anonymous volume on the container.

The `docker create -v` example below performs the following actions:

- Creates a busybox container that uses an anonymous volume in the `default` volume store.
- Mounts the volume to `/volumes` in the container.

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
create -v /volumes busybox</pre>

### Create a Container with a Named Volume <a id="create_container_named"></a>

To create a container with a new named volume, you specify a volume name in the `docker create -v` command. When you create containers that with named volumes, the VCH checks whether the volume exists in the volume store, and if it does not, creates it. The VCH mounts the existing or new volume on the container.

The `docker create -v` example below performs the following actions:

- Creates a busybox container
- Creates volume named `volume_1` in the `default` volume store.
- Mounts the volume to the `/volumes` folder in the container.

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
create -v volume_1:/volumes busybox</pre>

## Mount Existing vSphere-Backed Volumes on Containers <a id="mount"></a>
If your volume store is in a vSphere datastore, mounting existing volumes on containers is subject to the following limitations:

- vSphere Integrated Containers currently supports mounting a volume that is backed by vSphere on only one container at a time. 
- Docker does not support unmounting a volume from a container, whether that container is running or not. When you mount a volume on a container by using `docker create -v`,  that volume remains mounted on the container until you remove the container. When you have removed the container you can mount the volume onto a new container.
- If you intend to create and mount a volume on one container, remove that container, and then mount the same volume on another container, use a named volume. It is possible to mount an anonymous volume on one container, remove that container, and then mount the anonymous volume on another container, but it is not recommended to do so.

The `docker create -v` example below performs the following operations:

- Creates a container named `container1` from the `busybox` image.
- Mounts the named volume `volume1` to the `myData` folder on that container, starts the container, and attaches to it.
- After performing operations in `volume1:/myData`, stops and removes `container1`.
- Creates a container named `container2` from the Ubuntu image.
- Mounts `volume1` to the `myData` folder on `container2`.

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
create --name container1 -v volume1:/myData busybox
docker start container1
docker attach container1 

[Perform container operations and detach]

docker stop container1 
docker rm container1
docker create -it --name container2 -v volume1:/myData ubuntu
docker start container2 
docker attach container2 

[Perform container operations with the same volume that was 
previously mounted to container1]</pre>

## Sharing NFS-Backed Volumes Between Containers <a id="mount_nfs"></a>

If your volume store is in an NFS share point, sharing volumes between containers is not subject to any limitations. In vSphere Integrated Containers, the `local` driver is the vSphere Integrated Containers Docker personality. Consequently, the way to create NFS volumes with vSphere Integrated Containers is slightly different to how you do it with regular Docker. All that you need to do to create an NFS volume for a container is provide the name of the appropriate volume store in the `docker volume create` command.

<pre>docker volume create --opt volumestore=<i>nfs_volumestore_name</i></pre>

**NOTE**: vSphere Integrated Containers mounts NFS volumes as `root`. Consequently, if containers are to run as non-root users, the volume  store must be configured with the correct permissions so that the non-root users can access it. For information about how to configure NFS volume stores for non-root users, see [About NFS Volume Stores and Permissions](../vic_vsphere_admin/volume_stores.md#nfs_perms) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.

## Obtain Information About a Volume <a id="inspect_vol"></a>
To get information about a volume, run `docker volume inspect` and specify the name of the volume.
<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
volume inspect <i>volume_name</i></pre>

## Delete a Named Volume from a Volume Store <a id="delete_vol"></a>
To delete a volume, run `docker volume rm` and specify the name of the volume to delete. 

<pre>docker -H <i>virtual_container_host_address</i>:2376 --tls 
volume rm <i>volume_name</i></pre>

## Delete a Container and the Anonymous Volumes Attached to It  <a id="delete_anon_vol"></a>

To remove a container and anonymous volumes joined to that container, run `docker rm -v`. If an anonymous volume is in use by another container, it is not removed.

<pre>$ docker rm -v container1</pre>

## Run a Container and Delete the Anonymous Volumes Attached to it when it Stops <a id="delete_vol_stop"></a>

To run a container that creates anonymous volumes and then removes those volumes at the end of its run, run `docker run --rm`.

<pre>$ docker run --rm container1</pre>

**IMPORTANT**: Do not use `docker run --rm` with vSphere Integrated Containers 1.3.0. Using `docker run --rm` with vSphere Integrated Containers 1.3.0 removes named volumes, resulting in data loss. In vSphere Integrated Containers 1.3.1 only anonymous volumes are removed.