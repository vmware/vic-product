# Backing Up VMDK Volumes #

Backing up a VMDK volume involves copying the virtual disk to a new location. However, there are some important caveats to this. Most commercial backup solutions focus on making clones or snapshots of a VM. They might not allow you to back up virtual disks on their own. Backup solutions have file-based backup and restore, but whether or not this is the correct approach depends on the characteristics of the datastore.

For example, `tar` and `untar` will work with virtual disks on a FreeNAS, ZFS, or iSCSI setup, but will not work with VMware vSAN. This is because in vSAN, virtual disk data is a hidden object, so only the metadata can be seen. Tools such as `vmkfstools` provide one way to ensure that a virtual disk is cloned properly.

### Snapshots vs Clones

Taking a snapshot of a VM or disk allows its state to be frozen in time on the same datastore and potentially restored at a future date. Snapshots can protect against data corruption, but they do not protect against datastore hardware failure or accidental deletion, unless you  clone and move the snapshot.

Cloning a VM or a disk performs a deep copy that you can move to a different datastore and bring back in its entirety. This can protect against corruption, hardware failure, and deletion.

Container VMs are not designed for snapshots to be taken, and volume disks are mounted as independent persistent disks. This is by design, so that disks are not deleted when a container is deleted, but the disks are also not subject to snapshots. As such, currently the only way to back up volume disks is to clone them. For more information about cloning volumes, see [Datastore Approach](#datastore) below.

### Thin vs Fat Disks

vSphere Integrated Containers creates VMDK volumes as thin, lazy zeroed disks. This means that they only take up as much space as they need on the datastore, up to a set capacity limit. 

Note that some methods of cloning preserve thin provisioning and some do not. Most file copy approaches to backup will make a byte-for-byte copy, which results in the creation of a fat clone of a thin disk. For more information about the file copy approach to backup, see [File Copy Approach](#filecopy) below. 

The `vmkfstools` utility maintains the thinness of a volume disk when it makes a clone. For more information about `vmkfstools`, see [Using `vmkfstools`](#vmkfstools) below.

You should experiment with the clone and backup solutions that you use to be aware of the consequences of making thin disks fat, particularly when it comes to the impact of restoring disks from a backup.

## Approaches to Backing Up VMDK Volumes

The following examples show how you can use different approaches to back up the iSCSI and vSAN volume stores used in [Example: Persistent Container State](backup_volumes.md#persistentstate) in the previous topic.

### Datastore Approach <a id="datastore"></a>

Your backup solution might have the ability to create snapshots or clones of entire datastores. This is a good way to ensure that you have  backed up everything, but it also makes it more important to use different datastores for different types of state. For example, it would potentially be a waste of bandwidth to back up ephemeral state or cached immutable image state.

### File Copy Approach <a id="filecopy"></a>

A file copy approach is the simplest way to back up volumes, because you can back up an entire volume store by copying the root folder from the datastore. However, as mentioned above, this does not work for all datastore types, and most probably results in fat versions of volume disks.

For example, you can use Veeam to create a File Copy Job that copies the `/vmfs/volumes/iSCSI-nvme/volumes/my-vch-logs` volume store from the example. This will copy the disks, the folders, and the metadata.

By backing up the root folder, you keep the path structure intact. If you restore the volume store to the current VCH or add it to a new VCH, the configuration of the `vic-machine --volume-store` argument matches that of the path you backed up.

### Using `vmkfstools` <a id="vmkfstools"></a>

This example backs up the `vsanDatastore/volumes/my-vch-data` vSAN volume store from the example by cloning the virtual disk to another datastore by using `vmkfstools` and then copying over the metadata.

1. In an ESXi host shell, navigate to the `volumes` folder.<pre>cd /vmfs/volumes</pre>**NOTE**: The ESXi host must be able to access both the vSAN and iSCSI datastores.
2. Create a folder in the iSCSI datastore in which to copy the backup.<pre>mkdir -p iSCSI-nvme/volumes/my-vch-data-backup/volumes/mydata</pre>
3. Use `vmkfstools` to make a clone of the vSAN volume store disk in the folder that you just created in the iSCSI datastore.<pre>vmkfstools -i vsanDatastore/volumes/my-vch-data/volumes/mydata/mydata.vmdk iSCSI-nvme/volumes/my-vch-data-backup/volumes/mydata/mydata.vmdk</pre>
4. Copy the volume store metadata into the backup folder.<pre>cp -R vsanDatastore/volumes/my-vch-data/volumes/mydata/imageMetadata/ iSCSI-nvme/volumes/my-vch-data-backup/volumes/mydata</pre> 

This is a rather manual approach to backup, but you could write a script that lists all of the folders in `vsanDatastore/volumes/my-vch-data/volumes` and uses that as an input to another script based on the above commands. 
