# Backup and Restore Volumes #

vSphere Integrated Containers 1.2 has support for two types of volumes, each of which has different characteristics.

VMFS virtual disks (VMDK) which are mounted as formatted disks directly to the container VM. These are supported on multiple vSphere datastore types, including NFS, iSCSI and vSAN and are created as thin, lazy zeroed.
NFS shared volumes. This is distinct from a block-level VMDK on an NFS datastore. This is a Linux guest level mount of an NFS file-system share.

Characteristics

VMDK volume disks are locked for exclusive use while the container VM is running and cannot be shared with any other running container. It’s possible for multiple containers to be configured with the same volume disk, but only one can be run at a time. NFS volume support is designed for use-cases where multiple containers need read-write access to the same volume.

Another limitation of VMDK disks is that they cannot be cloned while in use. They can be snapshotted and the snapshot can then be cloned, but vSphere Integrated Containers 1.2 currently does not have built-in support for doing this. As such, cloning of vSphere Integrated Containers volume disks can only currently be done while the container is not running. We expect future versions of vSphere to address this with First Class Disk support which vSphere Integrated Containers can make use of.

Snapshotting or cloning of an NFS volume should be handled by the system providing the NFS server which should have its own backup strategy.

A VMDK volume is comprised of two elements: a .vmdk file which is a formatted virtual disk mounted at a configured location in a container guest file system; and some metadata describing the volume. These volumes are stored directly on a vSphere datastore in a location that can be specified when the VCH is deployed. 

A Deeper Look at Persistent Container State

Let’s look at an example. I’m going to create a VCH with two VMDK volume stores and an NFS volume store. I’m going to use the following options as input to the vic-machine binary: 

--volume-store vsanDatastore/volumes/my-vch-data:backed-up-encrypted 
--volume-store iSCSI-nvme/volumes/my-vch-logs:default
--volume-store nfs://10.118.68.164/mnt/nfs-vol?uid=0&gid=0&proto=tcp:shared

The first volume store is on a vSAN datastore and uses the label “backed-up-encrypted” so that a client can type “docker volume create --opt VolumeStore=backed-up-encrypted myData” to create a volume in that store. The second uses cheaper storage backed by a FreeNAS server mounted using iSCSI and is used for storing log data. Note that it has the label “default”, which means that any volume created without a volume store specified is created here. The third is an NFS export called /mnt/nfs-vol on a server.

Once you’ve installed the VCH, you should notice that there are now two empty folders created on the respective datastores ready for volume data:

vsanDatastore/volumes/my-vch-data/volumes
iSCSI-nvme/volumes/my-vch-logs/volumes
nfs://10.118.68.164/mnt/nfs-vol/volumes

Let’s go ahead and create three volumes using the Docker client. Note the implied use of the default volume store in the second example.

> docker volume create --opt VolumeStore=backed-up-encrypted --opt Capacity=10G mydata
> docker volume create --opt Capacity=5G mylogs
> docker volume create --opt VolumeStore=shared myshared

This will have now created the following files:

vsanDatastore/volumes/my-vch-data/volumes/mydata/mydata.vmdk
vsanDatastore/volumes/my-vch-data/volumes/mydata/ImageMetadata/DockerMetaData
iSCSI-nvme/volumes/my-vch-logs/volumes/mylogs/mylogs.vmdk
iSCSI-nvme/volumes/my-vch-logs/volumes/mylogs/ImageMetadata/DockerMetaData
nfs://10.118.68.164/mnt/nfs-vol/volumes/myshared
nfs://10.118.68.164/mnt/nfs-vol/volumes_metadata/myshared/DockerMetaData

Note that you wouldn’t normally need to know the conventions of where these are and what’s in them, but for the purposes of backup and restore, it becomes more important.

If we examine the DockerMetaData of the mydata volume, we see JSON data adding some context to this particular disk. This is the same data that would be returned by a client issuing “docker volume inspect mydata”.

{"Driver":"local","DriverOpts":{"Capacity":"10G","VolumeStore":"backed-up-encrypted"},"Name":"mydata","Labels":{},"AttachHistory":[""],"Image":""}

Now let’s mount these volumes to a container and add some data to them:

> docker run -it --name test -v mydata:/data -v mylogs:/logs -v shared:/shared ubuntu
> $ echo “some data” > /data/some-data
> $ echo “some logs” > /logs/some-logs
> $ echo “some shared” > /shared/some-shared
> $ exit

This operation created a new container VM with the volumes mounted at the specified locations. The echo command sent some data to the mydata volume, some logs to the mylogs volume and some shared data to the shared volume. The fact that container has exited means that the container VM is now powered off, but the volume disks are still part of its configuration. If the container is restarted, the volumes will be re-mounted. 

If a new container is started with the same volumes configured, it will be able to see the existing data and modify it. However, remember that the logs and data volumes are exclusive to a single running container, whereas the shared volume is not.

If we were to delete the containers using these volumes, the volumes would persist.

> docker volume ls
DRIVER              VOLUME NAME
vsphere             mydata
vsphere             mylogs
vsphere             myshared

How to Backup a Volume

Backing up a VMDK volume means copying the virtual disk to a new location. However, there are a couple of important caveats to this. Most commercial backup solutions focus on cloning or snapshotting a VM and may not have specific support for backing up virtual disks by themselves. They will have file-based backup and restore, but whether or not this is the right approach is dependent on the characteristics of the datastore.

As an example, tar and untar will work with virtual disks on a FreeNAS/ZFS/iSCSI setup, but will not work with vSAN. This is because the virtual disk’s data is a hidden object, so only the metadata can be seen. Utilities such as vmkfstools is one way to ensure that a virtual disk is properly cloned.

Snapshotting vs Cloning

Taking a snapshot of a VM or disk allows its state to be frozen in time on the same datastore and potentially restored at a future date. Snapshots can protect against data corruption, but not datastore hardware failure or accidental deletion unless the snapshot is then cloned and moved.

Cloning a VM or disk performs a deep copy which can be moved to a different datastore and can be brought back in its entirety. This can protect against corruption, hardware failure and deletion.

Container VMs are not designed to be snapshotted and volume disks are mounted as “independent persistent”. This configuration is by design so that they are not deleted when the container is deleted, but they are also not subject to snapshots. As such, currently the only way to backup volume disks is to clone them. In the next sections, we will explore how to do that.

Thin vs Fat

VMDK volumes in vSphere Integrated Containers 1.2 are created as thin, lazy zeroed. This means that they only take up as much room as they need on the datastore, up to the capacity limit that’s been set. 

It’s important to note that some methods of cloning preserve the thin provisioning and some do not. Most file copy approaches will do a byte-for-byte copy which ends up creating a fat clone of a thin disk. The vmkfstools utility discussed below however maintains the thinness of a volume disk when it does a clone. 

As such, it’s worth experimenting with the clone and backup solution you’re using to be aware of the consequences of making thin disks fat, particularly when it comes to the impact of restoring disks from a backup.

2.6 Approaches to Backup

Datastore Approach

Your backup solution may have a capability to snapshot or clone entire datastores. This is a great way to ensure that you have everything backed up, but it also places more emphasis on using different datastores for different types of state. It would potentially be a waste of bandwidth to backup ephemeral state.

File Copy Approach

A file copy approach is the simplest way to backing up volumes, because you can backup an entire volume store by copying the root folder from the datastore. However, as mentioned above, this is not going to work for all datastore types - vSAN being a notable exception; and you will very likely end up with fat versions of your volume disks.

In this example, we will use Veeam to backup the iSCSI volume store.

In the Veeam window, we can create a File Copy Job and add the volume store we care about, namely /vmfs/volumes/iSCSI-nvme/volumes/my-vch-logs. This will copy the disks, the folders and the metadata.

Note that by backing up the root folder, we have kept the path structure intact. This assumes that if you restore the volume store to this VCH or to a new VCH, the configuration of the vic-machine --volume-store argument will match that of the path backed up.

Using vmkfstools

We’ll back up our vSAN volume by cloning the virtual disk to another datastore using vmkfstools and then copying over the metadata. We’re going to clone the data from the vSAN datastore to the iSCSI datastore in an ESXi host shell.

> cd /vmfs/volumes
> mkdir -p iSCSI-nvme/volumes/my-vch-data-backup/volumes/mydata
> vmkfstools -i vsanDatastore/volumes/my-vch-data/volumes/mydata/mydata.vmdk iSCSI-nvme/volumes/my-vch-data-backup/volumes/mydata/mydata.vmdk
> cp -R vsanDatastore/volumes/my-vch-data/volumes/mydata/imageMetadata/ iSCSI-nvme/volumes/my-vch-data-backup/volumes/mydata

Of course in order for this to work, the ESXi host needs to be able to see both datastores. 

While this is a rather manual approach to backup, it’s easily conceivable how a script could be written that lists all the folders in vsanDatastore/volumes/my-vch-data/volumes and uses that as an input to another script based on the above. 

NFS Backup

As mentioned earlier, an NFS server should have its own snapshot or cloning strategy. If the NFS server is running as a VM, then this can make use of the same backup strategy as other stateful VMs.

Modifying the State

Now that we’ve backed up the persistent state, let’s modify the volumes.

> docker run -it --name test2 -v mydata:/data -v mylogs:/logs ubuntu
> $ echo “CORRUPT DATA” >> /data/some-data
> $ echo “overwritten logs” > /logs/some-log
> $ rm /shared/some-shared
> $ exit

As you can see, we added some corrupt data to the data volume, we accidentally deleted log data by overwriting it and we completely deleted the shared data.

2.7 Restoring Volumes

The question of how volumes should be restored is conceptually straightforward, it should be a simple matter of copying the VMDK disks and metadata back to either their original location or a new location, or restoring the state of an NFS server. However, it’s important to understand how vSphere Integrated Containers engine interacts with the volumes to ensure that this succeeds without error.

Restoring into an existing VCH

Restoring a volume into an existing VCH is a question of copying the VMDK disks and metadata back to the expected location on the datastores. See above for a more detailed description of the path conventions involved. 

The important caveat is that you cannot overwrite a volume disk that’s currently attached to a running container. If you must bring back a volume that has the same name as one that’s in use, or even multiple, there are two strategies to solve this: Rename the cloned volume or rename the cloned volume store.

Renaming a Cloned Volume

Renaming a cloned volume requires 3 steps:
The volume folder must be renamed to <newname>
The .vmdk file must be renamed to <newname>.vmdk
The value of the “name” tag in the JSON in the DockerMetadata file must be <newname>

Once the volume has been renamed, it can be copied into the volume store. However, the act of copying it into the volume store does not notify vSphere Integrated Containers engine of its existence. In order for vSphere Integrated Containers engine to see the new volume, you need to reboot the endpoint VM of the VCH. This is nothing unusual or drastic - any reconfiguration of the VCH causes a reboot of the endpoint VM.

Renaming a Volume Store

You can bring back an entire cloned volume store under a different name by simply renaming the root folder of the volume store and copying it onto a datastore that’s visible to the VCH. In order for the VCH to recognize it, you need to then use vic-machine configure --volume-store to add the cloned volume store.

Restoring into a new VCH

Restoring a volume store and then creating a new VCH that can use the volumes is a simple matter of ensuring the the --volume-store argument(s) to vic-machine are correctly configured. vSphere Integrated Containers engine is designed to deploy new VCHs onto existing volume stores. You can check whether the volume store has been picked up by running “docker info” and “docker volume ls”.
