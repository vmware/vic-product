# Backup and Restore Virtual Container Hosts #

A VCH is a pool of virtual resource where images are deployed as containers. A VCH consists of at least one VM, which we’ll call the endpoint VM, since it represents an API endpoint for a tenant. It may also have any number of container VMs, which can themselves be in various runtime states - most simply expressed as either running or not.

2.1 Components and State

Containers

The nature of containers is that they encourage application designers to think about where state belongs and the nature of that state. The container file system (any part that is not a mounted volume) is ephemeral by nature and is lost when the container is deleted. This is by design. A container volume is intentionally persistent by nature and can exist beyond the lifespan of a container or even a VCH.

Container Volumes

Containers themselves can be considered either stateful or stateless. The simplest way to distinguish between the two is whether or not one or more volume(s) are attached. A stateless container that reads and writes to a remote database can be easily scaled up or down and can be run in multiple failure domains behind a load-balancer. A stateful container however is tied to running in a location where its volume store is accessible.

The question of whether or not a volume is sharable is also important. If a volume is an NFS share, it’s feasible to have multiple containers in multiple failure domains share the same persistent data, assuming they have the correct locking semantics. If a volume is not sharable, then the ability for compute to move host is constrained by the use of a shared datastore or physically copying the data. vSphere makes it possible to live-migrate workloads between hosts in a cluster while keeping persistent data on a shared datastore. This is one of the reasons why vSphere Integrated Containers is well-suited to running stateful workloads.

Anonymous Volumes

It’s worth examining the difference between anonymous and named volumes. An anonymous volume is created in the default volume store every time a container is run from an image build using a Dockerfile with VOLUME as a command. Anonymous volumes are not desirable for production, since you cannot specify the size, the name or the class of storage. This inevitably has an implication for a backup strategy - if you backup anonymous volumes, you may have a hard time figuring out what they were being used for.

Container Images

Container images are immutable and should persist in a container registry. This is one of the reasons why a Registry is provided with vSphere Integrated Containers. When an image is pulled, either explicitly or as part of a container execution, it is cached locally in the VCH. The cache should be considered as ephemeral, even though the containers depend on the images being present in the cache in order to run.

Configuration State

There is also configuration state to consider. When a VCH is deployed, there is a significant amount of configuration provided to vic-machine including networks, datastores, credentials and such like. All of this data is stored in the endpoint VM’s VMX file. There is then also the configuration state of each of the running containers. This configuration state is stored in the VMX file of each container VM. 

Containers and the endpoint VM are designed to be stateless with respect to guest configuration - nothing is persisted in the guest. When a container starts up, it discovers its state from its VMX file. When a VCH endpoint VM starts up, it discovers both its own state and also the state of the image cache and the existing containers. The stateless nature of the endpoint VM is designed to simplify upgrades considerably - it’s just a case of powering it down, swapping out the ISO and powering it back up again.

2.2 High Availability

The VCH is designed in such a way that containers should be able to run independent of the availability of the endpoint VM. However it’s important to note that this is dependent on how the containers are deployed. 

The most important consideration is how networking for the container is configured. If port mapping is used, it is expected that the container should be accessible over a network via a port on the endpoint VM. If the endpoint VM goes down for any reason - planned or unplanned - that network connect is no longer available. This is why vSphere Integrated Containers offers the ability to connect directly to a vSphere network as a container-network. The container has its own identity on that network and the network and the container have no dependency on the endpoint VM for execution. 

It is possible to configure vSphere High Availability to restore the endpoint VM in the case of a an ESXi host failure. If a host goes down and an endpoint VM is lost, the only impact should be a temporary loss of the control plane - the ability to manage the lifecycle of containers, networks and volumes. 

2.3 Data Integrity

Data integrity for persistent data is extremely important, but a backup strategy is not the only way to ensure data integrity.

Data Replication

vSphere Integrated Containers supports different classes of storage, of which VMware vSAN is an example. vSAN offers built-in redundancy by replicating data to multiple physical drives and can tolerate hardware failure or nodes becoming unavailable. 

Replication of container image data is possible in the same way by installing the vSphere Integrated Containers appliance onto vSAN storage, but the vSphere Integrated Containers Registry also has the capability to replicate image data with other instances of itself. We will be exploring this capability more in the section on backing up below.

Data Encryption

Encryption of persistent data is typically a capability provided by the class of data storage being used and VMware vSAN provides built-in encryption capabilities. 

vSphere Integrated Containers makes it easy to specify different classes of datastore for different classes of data, via the vic-machine options --image-store and --volume-store. You specify a single image store where immutable image and ephemeral container state are stored. You can then specify any number of volume stores which map to different vSphere datastores and can be specified by label when provisioning a container.

Making Backups

Replication and Encryption are great for protecting known good data within a given isolation domain, but if an entire isolation domain is lost or if data becomes corrupted, keeping backups is essential.

The fact that vSphere Integrated Containers volumes are first-class citizens on vSphere datastores means that they can be backed up by any solution that knows how to backup virtual disks. 

2.4 A Backup Strategy

As can be seen, the question of what to back up, when to back it up and how to restore it isn’t necessarily simple. The best approach is to draw clear lines between persistent and ephemeral state and build those into well-defined strategies for application deployment, configuration and backup. 

For the VIC 1.2 release, the only state which should be considered eligible for backup is persistent state stored in container volumes and immutable state built into container images. This document will explain in detail how to backup and restore this state.

Configuration state (see 2.1 above) - that of the containers and the VIC endpoint itself - is not a good candidate for backup. This is because it’s highly dependent on tight coupling between itself and the current state of the vSphere environment it’s deployed to. As such, there’s a strong possibility that a container or VIC endpoint brought back from a backup may not have configuration state consistent with the environment it’s being restored into. This is not the case with volumes or container images - these can exist independently of any vSphere environment and can be copied or moved without issue.

What’s important is that if the VIC endpoint goes down or becomes unavailable for some reason, only the ability to manage the lifecycle of the containers is impacted. The containers themselves continue to run unimpeded (assuming container networks have been used - see above). If the issues with the VCH or vSphere environment are unrecoverable, it should be possible to create a new VCH in a different vSphere environment, deploy new instances of the same container workloads and switch to those new instances. Of course that depends on having appropriate load-balancing and data migration, but those are elements that should be addressed in the application and system architecture.

