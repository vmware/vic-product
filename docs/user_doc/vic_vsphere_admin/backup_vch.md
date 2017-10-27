# Backing Up Virtual Container Host Data #

A virtual container host (VCH) is a pool of virtual resources in which container images are deployed as lightweight VMs. A VCH consists of the VCH endpoint VM, and any number of container VMs. The endpoint VM runs the control plane and container VMs are created, powered on, powered off and deleted in response to container client calls to create, start, stop and delete containers. 

This topic provides information about different types of VCH data, what data you should back up, what data does not require backup, and why.

- [VCH Components and State](#state)
- [High Availability](#highavailabilty)
- [Data Integrity](#dataintegrity)
- [Conclusions](#conclusions)

## VCH Components and State <a id="state"></a>

To understand the requirements when backing up VCH data, you must first understand state for the different components of a VCH.

### Containers

Containers encourage application designers to think about where state belongs and the nature of that state. By design, any part of the container file system that is not a mounted volume is ephemeral by nature and is lost when the container is deleted. 

### Container Volumes

Let's assume that a stateful container has one or more volumes attached and a stateless container does not.

- A stateless container that reads and writes to a remote database can be easily scaled up or down and can be run in multiple failure domains behind a load-balancer. 
- A stateful container is tied to running in a location from which it can access its volume store. A container volume is intentionally persistent by nature and can exist beyond the lifespan of a container or even of a VCH.

You must also consider whether a volume is sharable between containers. If a volume is an NFS share, it is possible for multiple containers in multiple failure domains to share the same persistent data, provided that they have the correct locking semantics. If a volume is not sharable, the ability for compute resources to move between ESXi hosts is constrained by the use of a shared datastore or by physically copying the data. vSphere makes it possible to live-migrate workloads between hosts in a cluster while keeping persistent data on a shared datastore. For this reason, vSphere Integrated Containers is well-suited to running stateful workloads.

### Anonymous Volumes

An anonymous volume is created in the `default` volume store every time a container is run from an image that uses a Dockerfile with a `VOLUME` command. Anonymous volumes are not desirable for production, because you cannot specify the volume size, name, or class of storage. This has implications for your backup strategy, because it might not be clear what anonymous volumes are being used for.

### Container Images

Container images are immutable and should persist in a container registry. This is one of the reasons why vSphere Integrated Containers includes vSphere Integrated Containers Registry. When a developer pulls an image, either explicitly or as part of a container execution, the VCH caches the image locally. You can consider the VCH image cache to be ephemeral, even though the containers depend on the images being present in the cache when they run.

### Configuration State

When you deploy a VCH, you provide a significant amount of configuration to `vic-machine`, including networks, datastores, credentials, and so on. All of this configuration data is stored in the VMX file for the VCH endpoint VM. Running containers also have a configuration state, which is stored in the VMX file of each container VM. 

Containers and the VCH endpoint VM are designed to be stateless with respect to guest configuration. Nothing is persisted in the guest OS. When a container VM starts up, it discovers its state from its VMX file. When a VCH endpoint VM starts up, it discovers both its own state and also the state of the image cache and the existing containers. The stateless nature of the VCH endpoint VM simplifies upgrades. Upgrade is just a case of powering down the VCH endpoint VM, swapping out the ISO from which it boots, and powering it back up again.

## High Availability <a id="highavailabilty"></a>

The VCH is designed so that containers can run independently of the availability of the VCH endpoint VM. However, it is important to note that this is dependent on how the containers are deployed. 

The most important consideration is how the networking for the container is configured. If containers use port mapping, the containers are accessible over a network via a port on the VCH endpoint VM. If the endpoint VM goes down for any reason, that network connection is no longer available. This is why vSphere Integrated Containers offers the ability to connect containers directly to a vSphere network by using the `--container-network` option. If you use container networks, containers have their own identity on the container network. Consequently, the network and the container have no dependency on the VCH endpoint VM for execution. 

You can configure vSphere High Availability to restore the VCH endpoint VM in the case of an ESXi host failure. If a host goes down and a VCH endpoint VM is lost, the only impact should be a temporary loss of the control plane, namely the ability to manage the lifecycle of containers, networks, and volumes. 

## Data Integrity <a id="dataintegrity"></a>

Data integrity for persistent data is extremely important, but a backup strategy is not the only way to ensure data integrity.

### Data Replication

vSphere Integrated Containers supports different classes of storage, of which VMware vSAN is an example. vSAN offers built-in redundancy by replicating data to multiple physical drives and can tolerate hardware failure or nodes becoming unavailable. This is particularly useful for persistent volumes.

You can also replicate container image data by installing the vSphere Integrated Containers appliance on vSAN storage. vSphere Integrated Containers Registry also offers the ability to replicate image data to other registry instances.

### Data Encryption

Encryption of persistent data is typically provided by the class of data storage that you use. For example, vSAN provides built-in encryption capabilities. 

vSphere Integrated Containers makes it easy to specify different classes of datastore for different classes of data, by using the `vic-machine create --image-store` and `--volume-store` options. You specify a single image store in which to store immutable image and ephemeral container state for a VCH. You can then specify any number of volume stores which map to different vSphere datastores, which container developers can specify by their label when they provision a container.

### Making Backups

Replication and Encryption are good solutions for protecting data integrity within a given isolation domain. However, if an entire isolation domain is lost or if data becomes corrupted, keeping backups is essential.

The fact that vSphere Integrated Containers volumes are first-class citizens on vSphere datastores means that you can back up container volumes by using any solution that knows how to backup virtual disks. 

## Conclusions <a id="conclusions"></a>

The best approach to backing up VCH data is to make a clear distinction between persistent state and ephemeral state, and to build well-defined strategies for application deployment, configuration, and backup. 

### Data that Does Not Require Back Up

Configuration state of container VMs and of the VCH endpoint VM is not a good candidate for backup. This is because configuration state is highly dependent on a tight coupling between itself and the current state of the vSphere environment. As such, there is a strong possibility that a container VM or VCH endpoint VM that you bring back from a backup will not have a configuration state that is consistent with the environment to which you are restoring it. This is not the case with volumes or container images, which can exist independently of any vSphere environment and which can be copied or moved without problems.

Images cached in the VCH Image Store are not good candidates for backup because they are copies of immutable state already stored and backed up in a container registry.

It is important to remember that if the VCH endpoint VM becomes unavailable, this only impacts the ability to manage the lifecycle of the containers running in that VCH. If you have used container networks, the containers themselves continue to run unimpeded. If you cannot resolve the issues affecting the VCH endpoint VM or vSphere environment, you should be able to create a new VCH in a different vSphere environment, deploy new instances of the same container workloads, and switch to those new instances. This depends on having the appropriate load-balancing and data migration in place however, which is typically provided by a higher-level scheduler.

### Data that Requires Back Up

In this release of vSphere Integrated Containers, the only VCH data that you should consider for backup is the following: 

- Persistent state that is stored in container volumes. 

For information about how to backup and restore container volumes, see [Backing Up and Restoring Container Volumes](backup_volumes.md).
