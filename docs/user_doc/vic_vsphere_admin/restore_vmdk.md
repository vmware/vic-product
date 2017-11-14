# Restoring VMDK Volumes #

How to restore volumes is conceptually straightforward. It should be a  case of copying the VMDK disks and metadata back to either their original location or to a new location, or restoring the state of an NFS server. However, it is important to understand how vSphere Integrated Containers interacts with the volumes to ensure that this succeeds without error.

- [Restoring Volumes into an Existing VCH](#existingvch)
- [Restoring Volumes into a new VCH](#newvch)


## Restoring Volumes into an Existing VCH <a id="existingvch"></a>

Restoring a volume into an existing VCH is a question of copying the VMDK disks and metadata back to the expected location on the datastores. 

An important caveat is that you cannot overwrite a volume disk that is  attached to a currently running container. If you must bring back a volume that has the same name as one that is in use, there are two solutions: 

- Rename the cloned volume
- Rename the cloned volume store.

### Renaming a Cloned Volume 

Renaming a cloned volume requires 3 steps:

1. Rename the volume folder to `newname`.
2. Rename the `.vmdk` file to `newname.vmdk`
3. Set the value of the `name` tag in the `DockerMetadata` file JSON to `newname`.
4. Copy the volume into the volume store. 
5. For vSphere Integrated Containers engine to see the new volume, reboot the VCH endpoint VM. 

    You need to reboot because the act of copying the volume into the volume store does not notify vSphere Integrated Containers of its existence. Rebooting the VCH endpoint VM us not unusual or drastic. Any reconfiguration of the VCH causes a reboot of the VCH endpoint VM.

### Renaming a Cloned Volume Store

You can bring back an entire cloned volume store under a different name.

1. Rename the root folder of the cloned volume store.
2. Copy it onto a datastore that is visible to the VCH.
3. Run `vic-machine configure --volume-store` to add the cloned volume store to the VCH.

## Restoring Volumes into a new VCH  <a id="newvch"></a>

Restoring a volume store and then creating a new VCH that can use the volumes is a matter of ensuring that the `vic-machine create --volume-store` argument is correctly configured to point to the volume store. vSphere Integrated Containers is designed to deploy new VCHs onto existing volume stores. You can check whether the volume store has been picked up by running `docker info` and `docker volume ls`.
