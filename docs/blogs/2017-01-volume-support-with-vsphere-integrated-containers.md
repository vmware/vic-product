```
Mirrored from: https://blogs.vmware.com/vsphere/2017/01/volume-support-with-vsphere-integrated-containers.html
Author: Matthew Avery
Posted: January 25, 2017
```

# Volume Support with vSphere Integrated Containers

I am excited to discuss volume support with vSphere Integrated Containers and its differences from standard Docker deployments. The important difference to note between VIC and Docker is that VIC leverages the robust vSphere environment in order to interact with pools of managed resources. This means that the VIC volume support is designed to allow you to create volumes from vSphere datastores. This can be done from the Docker command line interface (CLI) without knowledge of the vSphere topologies. There are several major advantages of having access to datastores from the Docker CLI. One is that containers can now have volumes with several different backing types, such as NFS, ISCSI, or SSD. Also, the Docker CLI can now harness a large storage pool by default, independent of the resource constraints of the Docker daemon’s host. Additionally, users get access to technologies like VSAN when using volumes with their containers, which boosts the management capabilities of container volumes.

## Deploying a Virtual Container Host with Volume Stores

Volume support for VIC starts at deployment time when invoking _vic-machine create_. Since VIC is integrated with vSphere, we need a way to distinguish between different vSphere datastores. To allow this, we have created the concept of a _Volume Store_.  Volume stores are defined at the Virtual Container Host (VCH) deployment time. New volume stores cannot be added after deployment at this time, but it is planned in the future. Below is a screenshot detailing how to add volume stores to a VCH deployment using the _-–volume-store_ option in _vic-machine create_.

```
bin/vic-machine-linux create \
--name=VolumesDemo \
--target=10.192.118.11 \
--user=administrator@vsphere.local \
--image-store=vsanDatastore \
--appliance-iso=bin/appliance.iso \
--bootstrap-iso=bin/bootstrap.iso \
--force=true \
--compute-resource=cluster-vsan-1 \
--timeout=20m \
--volume-store=nvs0-1/test:default \
--volume-store=vsanDatastore:VSAN \
--no-tls 2>&1
```

As seen above, multiple volume stores can be expressed. The format of the volume store target is _<datastore name>:<volume store name>_. The volume store name can be anything without spaces. The datastore is validated against the target vCenter Server, and if there is an invalid target datastore, _vic-machine_ will suggest possible alternative datastores to the user. Another thing to note is that the “default” tag for volume stores is a special tag which allows VIC to support anonymous volumes — more on this below. Please note that without a volume store tagged as _default_, anonymous volumes will not be supported for that VCH deployment. There is a planned update in the future to include a _-–default-volume-store_ option to make this distinction more apparent. Another aspect of the volume store option to note is that you can also specify a file path. For example in the above screenshot _nfs0-1/test_ is the target volume store. This means that volumes will be made in a directory called test inside the datastore _nfs0-1_. This can help vSphere admins organize their volume stores.

It is also possible to list the available volume stores of a VCH deployment through the _docker info_ command from the Docker CLI. In the output, there is a field called VolumeStores which is a space list of volume stores that are available for that VCH deployment.

## Creating Specified Volumes

Now that we have successfully deployed a VCH with two volume stores, we can explore volume creation from the Docker CLI. VIC’s default volume behavior is a little bit different from Docker’s. This difference is driven by the above explanation of volume stores. The default volume behavior with VIC comes with two driver arguments. The first is _-–opt VolumeStore=<target volume store>_ which allows the user to target which datastore they would like their volume to be created on. The default for this argument is the “default” volume store. If a default volume store is not tagged at create time this call will fail with an error. The second option is _-–opt Capacity=<value with or without units>_ which defines the size of the volume that the user wishes to create. The default unit is megabytes. Some examples of this argument are 2GB, 20TB, and 4096.  If no capacity is specified the default for now is 1GB; there are plans to make this configurable in the future.

```
% docker -H 10.192.111.159:2375 volume create --name defaultVolume
defaultVolume

% docker -H 10.192.111.159:2375 volume create --name defaultCapacityVolume --opt Capacity=2GB
defaultCapacityVolume

% docker -H 10.192.111.159:2375 volume create --name VsanVolume --opt VolumeStore=VSAN
VsanVolume

% docker -H 10.192.111.159:2375 volume create --name VsanCapacityVolume --opt=VolumeStore=VSAN --opt Capacity=2GB
VsanCapacityVolume
```

Let’s take a look at the different volume create operations in detail. The first volume create operation above is possible since we created a _default_ volume store. Notice we did not specify the volume store or the capacity, so this volume is 1GB and resides on the default store. The second volume has a 2GB capacity and is on the default store. The third and fourth volumes are created on the _VSAN_ volume store with differing capacities. These examples show how you can create a complex set of volumes for your containers to consume.

## Mounting Volumes To Containers

So now we have made some volumes and we want to mount them onto a container. VIC uses the normal syntax for mounting volumes onto containers, that is, _-v <volume name>:<mount path>_. For instance, in the above screenshot I have mounted the volume named _defaultVolume_ above to this busybox container. I then attached to it and saw that the _/myData_ directory was there, and added an empty file. Mount paths are unique, so if you attempt to mount several volumes to the same path in the container only one volume will be mounted.

## VIC and Anonymous Volumes

The screenshot below involves a special case of anonymous volumes. As mentioned earlier, anonymous volumes are not supported unless a default volume store is specified. The main difference between an explicitly made (specified) volume and an anonymous volume is that anonymous volumes are made on the fly with default parameters. The pathway for creating anonymous volumes also does not follow the usual _docker volume create_ target.   Instead, they are made either from image metadata or from a -v option targeting a volume that does not exist at the time of the call. The yellow box indicates an anonymous volume that gets its name from the mount request — other than that it was automatically made on the default store with the default capacity of 1GB. All anonymous volumes are created in the default store with the default capacity. The orange box shows that VIC makes anonymous volumes when a targeted image has volume mounts in the image metadata. In this case, the mongo image requests two volumes in its metadata. We can see from the _volume ls_ output that those volumes did not have an explicit name, so VIC assigned them UUIDs for their names. If you want to specify these volumes rather than having them anonymous, targeting the same mount path with a specified volume will take precedence over an anonymous volume.

![Terminal screenshot showing anonymous volumes](https://blogs.vmware.com/vsphere/files/2017/01/anonymous-volume.png)
