# Back Up and Restore the vSphere Integrated Containers Appliance #

The vSphere Integrated Containers appliance runs various services, such as vSphere Integrated Containers Management Portal, vSphere Integrated Containers Registry, and the `vic_machine_server` service. In this version of vSphere Integrated Containers, the appliance has four virtual disks attached to it:

- `/` : The root disk, that contains the operating system and application state of the vSphere Integrated Containers appliance.
- `/storage/data/`: A data disk that contains, among other things, the vSphere Integrated Containers Registry instance that is running in the appliance.
- `/storage/log/`: A logging disk that contains the logs for the different vSphere Integrated Containers components.
- `/storage/db/`: A database disk that contains the MYSQL, Clair, and Notary databases for vSphere Integrated Containers Registry.

The separation of different types of data between disks allows you to upgrade the appliance with an existing data disk from a previous installation. It also allows you to back up and restore the different disks, if necessary.

## Snapshots and Clones ##

You can take a conventional approach to backing up the appliance, in the same way as for any other stateful VM. The appliance disks are not independent of the appliance VM, so if you take a snapshot of the appliance VM, it also takes snapshots of all of the disks. 

**NOTE**: If you do not take a snapshot the of the memory of the appliance, it comes back up in a powered-off state. This is probably the preferred approach, but it means that the registry is temporarily unavailable while the appliance boots up.

Once you have created a snapshot of the appliance VM, you can clone the snapshots of the disks, even while the appliance is running. You can use tools like `vmkfstools` to copy the disks to a backup datastore.

## Restoring the Disks ##

You have two choices to restore the different disks:

- Revert the appliance to a VM snapshot.
- Copy a cloned VMDK into the appliance datastore and attach it to the appropriate virtual device node on the appliance VM. 

If you are not restoring the disks from a live snapshot, you must shut down the appliance before the you restore the disks.