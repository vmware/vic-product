# Virtual Container Host Storage Capacity #

Virtual container hosts (VCHs) require a datastore in which to store container image files, container VM files, and the files for the VCH itself. You can also specify one or more datastores in which container developers can create container volumes.

- [Specify the Image Datastore](image_store.md)
- [Specify Volume Datastores](volume_stores.md)

For an overview of vSphere Integrated Containers storage, watch the vSphere Integrated Containers Storage video on the [VMware Cloud-Native YouTube Channel](https://www.youtube.com/channel/UCdkGV51Nu0unDNT58bHt9bg):
{{ 'https://www.youtube.com/watch?v=WrVHbjTZHrs' | noembed }}


## Storage Requirements and Limitations

The storage that you select for use as image and volume stores for VCHs must meet the following requirements.

- vSphere Integrated Containers Engine fully supports VMware vSAN datastores. 
- vSphere Integrated Containers Engine supports all alphanumeric characters, hyphens, and underscores in datastore paths and datastore names, but no other special characters.
- Datastores that you specify as image and volume stores should ideally be accessible to all of the hosts in a cluster. Specifying storage that is not accessible to all of the hosts in a cluster is possible, but might result in all of your container VMs and container volumes being placed on the same host.

    - If you specify different datastores in the different datastore options, and if no single host in a cluster can access all of the datastores, VCH deployment fails with an error.<pre>No single host can access all of the requested datastores. 
  Installation cannot continue.</pre>
    - If you specify different datastores in the different datastore options, and if only one host in a cluster can access all of them, VCH deployment succeeds with a warning.<pre>Only one host can access all of the image/container/volume datastores. This may be a point of contention/performance degradation and HA/DRS may not work as intended.</pre>
  
- VCHs do not support datastore name changes. If a datastore changes name after you have deployed a VCH that uses that datastore, that VCH will no longer function.