# Backing Up and Restoring Container Volumes #

This topic describes the types of volumes that vSphere Integrated Container supports, and provides an example of how containers persist data in container volumes.

vSphere Integrated Containers supports two types of volumes, each of which has different characteristics.

- VMFS virtual disks (VMDKs), mounted as formatted disks directly on container VMs. These volumes are supported on multiple vSphere datastore types, including NFS, iSCSI and VMware vSAN. They are thin, lazy zeroed disks.
- NFS shared volumes. These volumes are distinct from a block-level VMDK on an NFS datastore. They are Linux guest-level mounts of an NFS file-system share.

### VMDK Volumes

A VMDK volume comprises two elements: 

- A `.vmdk` file which is a formatted virtual disk mounted at a configured location in a container guest file system
- Some metadata that describes the volume. 

These volumes are stored directly on a vSphere datastore in a location that you specify when you deploy a virtual container host (VCH). 

VMDK volume disks are locked for exclusive use while a container VM runs, so other running containers cannot share them. It is possible to configure multiple containers with the same volume disk, but only one  container can run at a time. 

Another limitation of VMDK disks is that you cannot clone them while they are in use. You can take snapshots and then clone the snapshots, but vSphere Integrated Containers  does not currently have built-in support for doing this. Consequently, you can only clone vSphere Integrated Containers volume disks while a container is not running.

For information about backing up and restoring VMDK volumes, see the following topics. 

- [Backing Up VMDK Volumes](backup_vmdk.md)
- [Restoring VMDK Volumes](restore_vmdk.md)

### NFS Shared Volumes

NFS volume support is designed for use-cases where multiple containers need read-write access to the same volume.

Taking snapshots and making clones of NFS volumes is handled by the system that provides the NFS server, which should have its own backup strategy. If the NFS server is running as a VM, you can use the same backup strategy as for other stateful VMs.

## Example: Persistent Container State <a id="persistentstate"></a>

This example uses a VCH with two VMDK volume stores and one NFS volume store to demonstrate how data persists in container volumes. 

**Procedure**

1. Run `vic-machine create` with the following options to deploy a VCH with three volume stores,<pre>--volume-store vsanDatastore/volumes/my-vch-data:replicated-encrypted 
--volume-store iSCSI-nvme/volumes/my-vch-logs:default
--volume-store nfs://10.118.68.164/mnt/nfs-vol?uid=0&gid=0&proto=tcp:shared</pre>

 - The first volume store is on a vSAN datastore and uses the label `replicated-encrypted`. Container developers can create a volume in that volume store by running the following command:<pre>docker volume create --opt VolumeStore=replicated-encrypted myData</pre> 
  - The second volume store uses cheaper storage backed by a FreeNAS server mounted using iSCSI. It is used for storing log data. It has the label `default`, which means that any volume that is created without a specifying a volume store is created here. 
  - The third volume store is an NFS export called `/mnt/nfs-vol` on an NFS server.

2. Browse the three datastores to see the folders that deploying this VCH created.

  - `vsanDatastore/volumes/my-vch-data/volumes`
  - `iSCSI-nvme/volumes/my-vch-logs/volumes`
  - `nfs://10.118.68.164/mnt/nfs-vol/volumes`

2. Run the following commands in the Docker client to create three volumes.<pre>$ docker volume create --opt VolumeStore=replicated-encrypted --opt Capacity=10G mydata</pre><pre>$ docker volume create --opt Capacity=5G mylogs</pre><pre>$ docker volume create --opt VolumeStore=shared myshared</pre>

    Note that the second example does not specify a volume store, which implies the use of the `default` volume store.

2. Browse the three datastores to see the files that these commands created.

  - `vsanDatastore/volumes/my-vch-data/volumes/mydata/mydata.vmdk`
  - `vsanDatastore/volumes/my-vch-data/volumes/mydata/ImageMetadata/DockerMetaData`
  - `iSCSI-nvme/volumes/my-vch-logs/volumes/mylogs/mylogs.vmdk`
  - `iSCSI-nvme/volumes/my-vch-logs/volumes/mylogs/ImageMetadata/DockerMetaData`
  - `nfs://10.118.68.164/mnt/nfs-vol/volumes/myshared`
  - `nfs://10.118.68.164/mnt/nfs-vol/volumes_metadata/myshared/DockerMetaData`

    As a vSphere administrator, you would not normally need to know the conventions and contents of these folders, but it is important for the purposes of demonstrating backup and restore.

2. Examine the `DockerMetaData` file of the `mydata` volume.

    You see JSON data that adds some context to this particular disk. This is the same data that would be returned by running `docker volume inspect mydata` in the Docker client:<pre>{  
   "Driver":"local",
   "DriverOpts":{  
      "Capacity":"10G",
      "VolumeStore":"replicated-encrypted"
   },
   "Name":"mydata",
   "Labels":{  
   },
   "AttachHistory":[  
      ""
   ],
   "Image":""
}</pre>

2. In the Docker client, mount the volumes to a container and add some data to them.<pre>$ docker run -it --name test -v mydata:/data -v mylogs:/logs -v shared:/shared ubuntu
$ echo “some data” > /data/some-data 
$ echo “some logs” > /logs/some-logs
$ echo “some shared” > /shared/some-shared
$ exit</pre>

    This operation creates a new container VM with volumes mounted at the specified locations. The `echo` command sends some data to the `mydata` volume, some logs to the `mylogs` volume, and some shared data to the `shared` volume. The fact that container has exited means that the container VM is now powered off, but the volume disks are still part of its configuration. If you restart the container, the volumes are mounted again. 

    If you start a new container with the same volumes configured on it, the new container will be able to see the existing data and modify it. Remember that the `logs` and `data` volumes are exclusive to a single running container, whereas the `shared` volume is not.

2. Run `docker rm test` to delete the container.
3. Run `docker volume ls` to list the available volumes.

    The volumes and the data that they contain are still available after you have deleted the containers.
    <pre>
DRIVER              VOLUME NAME
vsphere             mydata
vsphere             mylogs
vsphere             myshared
</pre>
2. Browse the three datastores to see that the files that the container created are still present.
