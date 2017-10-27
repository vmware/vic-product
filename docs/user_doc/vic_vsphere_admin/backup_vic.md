# Back Up and Restore vSphere Integrated Containers #

A vSphere Integrated Containers installation is inherently stateful, even if the containers running on it are not. As such, the question of how to back up and restore vSphere Integrated Containers is an important one.

The main components of vSphere Integrated Containers store the following persistent data:
 
- vSphere Integrated Containers Registry stores immutable image data. You can back up vSphere Integrated Containers Registry state by using VM snapshots and clones.
- vSphere Integrated Containers Management Portal stores user and project metadata. You can back up vSphere Integrated Containers Management Portal state by using VM snapshots and clones.
- Container volumes store persistent data that container VMs use and share. You can back up container volumes by using snapshots and clones only if the container is not running. You restore container volumes by copying virtual disks to a known location.

You can consider all other data in vSphere Integrated Containers to be ephemeral state, that is not suitable for backup.

The following topics describe the types of state that a typical vSphere Integrated Containers installation stores, where it resides, the nature of the data, why you might want to back it up and some alternatives to a backup strategy. The topics describe different approaches to backup and their relative merits.

* [Backup and Restore the vSphere Integrated Containers Appliance](backup_vic_appliance.md)
* [Backing Up Virtual Container Host Data](backup_vch.md)
* [Backing Up and Restoring Container Volumes](backup_volumes.md)
