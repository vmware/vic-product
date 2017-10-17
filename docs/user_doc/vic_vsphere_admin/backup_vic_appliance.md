# Backup and Restore the vSphere Integrated Containers Appliance #

vSphere Integrated Containers Appliance (the OVA you download) runs various services such as the management UI and registry. In vSphere Integrated Containers 1.2 it has two virtual disks attached - a system disk and a data disk. The system disk has all of the operating system and application state of the vSphere Integrated Containers appliance and the data disk has all of the important persistent data. 

This separation allows for the OVA to be upgraded with an existing data disk, but it also allows for the data disk to be backed up and restored if necessary.

## Snapshotting and Cloning ##

You can take a conventional approach to backing up the OVA appliance, the same as you would to any other stateful VM. Its disks are not independent of the VM, so if you take a snapshot of the appliance, it will also take snapshots of the data and system disks. 

Bear in mind that if you don’t snapshot the memory of the OVA appliance, it will come back in a powered-off state. This is likely the preferred approach, but it means that the registry will be temporarily unavailable while the appliance boots up.

Once you’ve created a snapshot of the entire VM, you can clone the snapshot of the data disk, even while the appliance is running. You can use a tools like vmkfstools (see below) and copy the data disk to a backup datastore.

## Restoring ##

Restoring the data disk is a case of either reverting to a VM snapshot or copying a cloned VMDK into the datastore and making sure it’s attached to the correct virtual device node on the appliance. In vSphere Integrated Containers 1.2 this is SCSI(0:1) by convention. Unless restoring from a live snapshot, the appliance will need to be shut down before the restore and restarted.

