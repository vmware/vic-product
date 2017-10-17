# Backup and Restore vSphere Integrated Containers #

A vSphere Integrated Containers installation is inherently stateful, even if the containers running on it are not. As such, the question of how it should be backed up and restored is an important one for vSphere admins to consider.

The executive summary of this document is:

- Persistent data consists of Container Volumes, Registry and Management UI data
- Everything else in vSphere Integrated Containers should be considered ephemeral state, not suitable for backup
- Registry and Management state can be backed up using VM snapshots and clones
- Container volumes can be backed up using snapshots and clones only when the container is not running
- Restoring container volumes is a matter of copying virtual disks to a known location
- There are different approaches to backup and the relative merits are explored

In exploring the detail of this topic, the best place to start is to examine the types of state stored by a typical vSphere Integrated Containers installation, where it resides, the nature of it and why you might care about it.

A vSphere Integrated Containers installation consists of three main components:

- Registry - which stores immutable image data
- Management UI - which stores user and project metadata
- One or more Virtual Container Hosts (VCH)