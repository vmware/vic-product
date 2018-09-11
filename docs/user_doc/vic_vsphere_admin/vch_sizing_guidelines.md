#Virtual Container Hosts Sizing Guidelines#

Sizing of virtual container hosts (VCHs) depends on the workload that you need to run. While deploying a VCH, consider the sizing guidelines and resources that are consumed by a VCH during boot.

- [Guidelines](#guidelines)
- [Resources Consumed](#resourceconsumption)

##Guidelines <a id="guidelines"></a> ##
Sizing of VCHs can be modifed by configuring resource pool limits. If a VCH requires more resources, or if it consumes too many resources, you can configure CPU and memory allocations on the VCH resource pool by using the different `vic-machine configure --memory` and `--cpu options`.

Remember the following points while configuring the options:

- The image store exists directly on the datastore  and the footprint is directly related to the images that have been downloaded.
-  The read/write layers of the container VM  exist directly on the datastore within the VM folders and are based on redo logs and hence relate directly to the amount of data written.
-  Volumes exist on whichever datastore or NFS server that the volume store is configured for.  These volumes are thin by default and the footprint relates to the amount of data written. 
-  You can modify the resource pool live without stopping container VMs or restarting the endpoint VM via the vSphere UI.
-  Do not use the ESXi host client to edit a running endpointVM directly. Instead, use the the vCenter client or power off the endpointVM before editing. 
    
    For more information, see [VCH Does Not Initialize Correctly](ts_vch_incorrect_initialization.md) 

vCenter maximums will apply for general scale, maximum configurations, and limitations. A single vCenter Server instance can have 25,000 powered-on VMs and 35,000 registered VMs. Make sure that the number of  VMFS virtual disks (VMDKs) files associated with the VMs does not exceed the maximum permitted per datastore. For more information, see [vSphere Configurations Maximums Tool]( https://configmax.vmware.com/).

For information about modifying resource allocations for the VCH by using the options at deployment, see [Virtual Container Host Compute Capacity](vch_compute.md) and for modifying options after deployment, see [Configure Running Virtual Container Hosts](configure_vch.md).

##Resources Consumed <a id="resourceconsumption"></a>##

During boot, the minimum memory of the VCH endpoint VM is around 900 MB  and it actively uses around 450MB for basic operations. 

The **scratch image size**, which is the size of the filesystem that that supports the container filesystem for container VMs, defaults to 8GB. Since it is not possible to extend VMDKs that have parent disks, it is important to have a size that is large enough for the expected images for a specific VCH. For example, when a DB2 image is 50GB.

The endpoint VM CPU and memory can be modified by shutting down the endpointVM and editing the hardware specification. The CPU is primarily utilized for performing checksums of images as they are pulled, `docker diff` and `copy` operations, and NAT traffic forwarding to container VMs. The memory is used as a temporary filesystem for spooling images as they are downloaded and hence the endpointVM memory should be sufficient to hold the largest layers in an image. 

The following list describes the resource consumption of container VMs with default memory 2 GB, 20s after boot. The resource consumption follows normal vSphere patterns of high active initially based on conservative assumptions, trending to actual active over time.

- MemTotal: 2052880 kB
- MemFree: 1932036 kB
- MemAvailable: 1906724 kB
- Buffers: 200 kB
- Cached: 71768 kB
- SwapCached: 0 kB
- Active: 11108 kB
- Inactive: 69260 kB
- Active(anon): 10652 kB
- Inactive(anon): 68320 kB

**NOTE**: When you a run a VCH in debug mode, it increases overhead as there is significantly more string-copying occurring.

