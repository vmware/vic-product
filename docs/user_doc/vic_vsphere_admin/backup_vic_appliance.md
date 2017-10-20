# Back Up and Restore the vSphere Integrated Containers Appliance #

The vSphere Integrated Containers appliance runs various services, such as vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry. In this version of vSphere Integrated Containers, the appliance has two virtual disks attached to it:

- A system disk, that contains the operating system and application state of the vSphere Integrated Containers appliance.
- A data disk, that contains all important persistent data. 

The separation of different types of data between disks allows you to upgrade the appliance with an existing data disk from a previous installation. It also allows you to back up and restore the data disk, if necessary.

## Snapshots and Clones ##

You can take a conventional approach to backing up the appliance, in the same way as for any other stateful VM. The appliance disks are not independent of the appliance VM, so if you take a snapshot of the appliance VM, it also takes snapshots of the data and system disks. 

**NOTE**: If you do not take a snapshot the of the memory of the appliance, it comes back up in a powered-off state. This is probably the preferred approach, but it means that the registry is temporarily unavailable while the appliance boots up.

Once you have created a snapshot of the appliance VM, you can clone the snapshot of the data disk, even while the appliance is running. You can use tools like `vmkfstools` to copy the data disk to a backup datastore.

## Restoring the Data Disk ##

You have two choices to restore the data disk:

- Revert the appliance to a VM snapshot.
- Copy a cloned VMDK into the appliance datastore and attach it to the `SCSI(0:1)` virtual device node on the appliance VM. 

If you are not restoring the data disk from a live snapshot, you must shut down the appliance before the you restore the disk.

