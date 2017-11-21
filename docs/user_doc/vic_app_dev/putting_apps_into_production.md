# Putting Applications into Production with vSphere Integrated Containers Engine #

vSphere Integrated Containers engine is designed to be a docker API compatible production endpoint for containerized workloads. As such, the design focus is on provisioning containerized applications with optimal isolation, security, data persistence, throughput performance and to take advantage of vSphere capabilities.

vSphere Integrated Containers engine is designed to make existing features of vSphere easy to consume and exploit by providing compatibilty with the Docker image format and Docker client. Inevitably that means that there are some differences between a regular Docker host and a Virtual Container Host (VCH), and between a Linux container and a container VM. Some of those differences are intentional design constraints, such as there being no such thing as a "privileged" container in VIC. Some are because of a lack of functional completeness, while others are outside of the existing scope of the product, such as native support for `docker build`.

There are other sections that discuss these topics in more depth, but this section is intented to help you to understand how to maximize business value by understanding how the capabilities of the product map to production requirements.

**Building Images for production**

While official images on sites like Docker Hub are useful for showing how an application might be containerized, these images are rarely suitable to put into production as is. Exploring how to customize images is outside of the scope of this document, but important considerations include:

- Anonymous volumes

You can specify a volume in a container image using the VOLUME keyword. However, this does not allow you to specify any characteristics about the volumes. A VCH can have mutliple volume stores and a volume is a disk, so being able to specify an appropriate volume store and the size of the disk is an important consideration.

Note also that a volume in vSphere Integrated Containers will have a `/lost+found` folder in it due to the ext4 filesystem and if your application needs an empty folder, you should specify a sub directory in the volume. Eg.

`docker run -v mydisk:/mountpoint -e DATA_DIR=/mountpoint/data myimage`

- Exposing network ports

You can expose network ports in a Dockerfile using EXPOSE and leave it up to the container engine to define port mappings using `docker run -P`. There are a few considerations with this. 

If you want to expose your container to other containers on a bridge network, you don't need to use EXPOSE. Your container will be resolvable by name. 

If you want your container to be externally accessible, VIC engine gives you the option to use an external container network rather than port mapping. This is more robust and more performant because it doesn't depend on the container engine being available for a network connection and it doesn't rely on NAT networking. Your container gets its own IP address on that container network. Exposing your container on a container network cannot be specified in a Dockerfile.

If you want to use a port mapping on the VCH endpoint VM, it's rarely the case that you want the container engine to pick a random port and again, that's not something that can be specified in the Dockerfile. Better to use `docker run -p <external>:<internal>` at deployment.

- Environment variables

Environment variables are a very useful way of setting both static and dynamic configuration. Use of Environment variables in a Dockerfile should be considered static configuration as they will be the same on every deployment. Setting them on the command-line allows for dynamic configuration and over-riding of static settings.

**Ephemeral and Persistent State**

The question of where a container stores its state is an important one. A container has an ephemeral filesystem and multiple optional persistent volume mounts. Any writes to any part of the filesystem that is not a mounted volume is stored only until the container is deleted. 

When a regular Linux container is deployed into a VM, there are typically two types of filesystem in the guest OS. An overlay filesystem manages the image data and stores ephemeral state. A volume will typically be another part of the guest filesystem mounted into the container. As such it is also possible for Linux containers to have shared read/write access to the same filesystem on the container host. This is useful in development, but potentially problematic in production as it forces containers to be tied to each other and to a specific container host. That may well be by design in the case where multiple containers form a single service and a single unit of scale. What's important however is to consider the scope, persistence and isolation of data when deploying containerized applications.

Take a database container as an example. Its data almost certainly needs to be backed up, live beyond the lifecycle of the container and not be mixed up with any other kind of data. The problem of peristing such state onto a container host filesystem is that it's mixed in with other state and cannot easily be backed up, unless the host itself has a disk mounted specifically for that purpose. There are volume drivers that can be used with Docker engine for this purpose. Eg. [VMware Docker Volume Service](https://vmware.github.io/docker-volume-vsphere)

When you deploy a container to a VCH, ephemeral state is written to a delta disk (an ephemeral layer on top of the image layers) and volumes are independently mounted disks which can only be mounted to one container at a time. When creating a volume, you can specify the size of the disk and the volume store it gets deployed to. If you select a volume store backed by a shared datastore, that volume will be available to any container anywhere in the vSphere cluster. This is particularly useful when it comes to the live migration of stateful containers. The vSphere administrator will be responsible for backup policy associated with the datastore.

As such, VIC makes it easy to store persistent data to disks that are independent of VMs, can be written to shared datastores and can participate in the same backup and security policies as regular VMs. 

Note that an anonymous volume declared in a Dockerfile will manifest as a mounted disk of a default size (1GB) to a default datastore. This is almost always going to be the wrong option in production for the reasons stated above.

You can use NFS to mount shared read-write volumes to container VMs.

**Container Isolation**

A container deployed to a VCH is strongly isolated by design. Strongly isolated means:

- The container gets its own Linux kernel which is not used for any other purpose
- The container gets its own filesystem and buffer cache which is not used for any other purpose
- The container cannot get access to the container control plane or get information about any other containers
- Privilege escalation or container breakouts in the conventional sense are not possible
- The container operates independent of its control plane (assuming port mapping is not being used)
- The container can take advantage of vSphere High Availability and vMotion

Network isolation is handled in a similar way to Docker, except that containers can be connected directly to vSphere port groups (see container networks). Storage isolation is discussed above.

This kind of strong isolation is best suited to a container workload that is a long-running service. If the service fails, it should have no impact on any other services. Examples of a long-running service are a database, web server, key-value store etc.

Containers are very flexible abstractions however and not every container is designed to be a single service. In fact, some containers are designed to be combined to form a single service and a single unit of scale. This notion is sometimes described as a Pod. In such a circumstance, it may be beneficial to run these as Linux containers in a single VM. VIC engine provides built-in support for this model of provisioning Linux container hosts as VIC containers since 1.2.

What's important is to consider the policy needs of your application in terms of isolation. Strong isolation is a very important consideration in deploying robust applications into production and VIC makes it easy to turn that policy into plumbing.






