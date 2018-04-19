# Introduction to vSphere Integrated Containers Engine

vSphere Integrated Containers Engine currently offers a subset of the Docker API. It is designed to specifically address the provisioning of containers into production, solving many of the problems highlighted in [How vSphere Integrated Containers Helps vSphere Administrators](intro_to_vic.md#helps_admins).

vSphere Integrated Containers Engine exploits the portability of the Docker image format to present itself as an enterprise deployment target. Developers build containers on one system and push them to a registry. Containers are tested by another system and are approved for production. vSphere Integrated Containers Engine can then pull the containers out of the registry and deploy them to vSphere.

If you consider a Venn diagram with "What vSphere Does" in one circle and "What Docker Does" in another, the overlap is significant. The objective of vSphere Integrated Containers Engine is to take as much of vSphere as possible and layer whatever Docker capabilities are missing on top, reusing as much of Docker's own code as possible. The  result does not sacrifice the portability of the Docker image format and should be completely transparent to a Docker client. The following sections describe key concepts and components that make this possible.

- [Container VMs](#containervm) 
- [Virtual Container Hosts](#vch) 
- [The VCH Endpoint VM](#endpoint) 
- [The vic-machine Utility](#vic-machine) 

## Container VMs <a id="containervm"></a>

The container VMs that vSphere Integrated Containers Engine creates have all of the characteristics of software containers:

- An ephemeral storage layer with optionally attached persistent volumes.
- A custom Linux guest OS that is designed to be "just a kernel" and that needs images to be functional.
- A mechanism for persisting and attaching read-only binary image layers.
- A PID 1 guest agent *tether* extends the control plane into the container VM.
- Various well-defined methods of configuration and state ingress and egress
- Automatically configured to various network topologies.

The provisioned container VM does not contain any OS container abstraction. 

- The container VM boots from an ISO that contains the Photon Linux kernel. Note that container VMs do not run the full Photon OS.
- The container VM is configured with a container image that is mounted as a disk. 
- Container image layers are represented as a read-only VMDK snapshot hierarchy on a vSphere datastore. At the top of this hierarchy is a read-write snapshot that stores ephemeral state. 
- Container volumes are formatted VMDKs that are attached as disks and indexed on a datastore. 
- Networks are distributed port groups that are attached as vNICs.

## Virtual Container Hosts <a id="vch"></a>

A virtual container host (VCH) is the functional equivalent of a Linux VM that runs Docker, but with some significant benefits. A VCH represents the following elements:
- A clustered pool of resource into which to provision container VMs.
- A single-tenant container namespace.
- An isolated Docker API endpoint. 
- Authorization to use and configure pre-approved virtual infrastructure.
- A private network that containers are attached to by default.

If you deploy a VCH in a vCenter Server cluster, it spans all of the hosts in the cluster, providing the same flexibility and dynamic use of host resources as is the norm.

A VCH is functionally distinct from a traditional container host in the following ways:

- It naturally encapsulates clustering and dynamic scheduling by provisioning to vSphere targets.
- The resource constraints are dynamically configurable with no impact on the containers.
- Containers do not share a kernel.
- There is no local image cache. This is kept on a datastore in the cluster that you specify when you deploy a VCH. 
- There is no read-write shared storage

A VCH is a multi-functional appliance that you can deploy to the following targets:
 
- A vCenter Server cluster
- A standalone ESXi host that is managed by vCenter Server
- An ESXi host that is not managed by vCenter Server

VCHs are deployed as resource pools. The resource pool provides a useful visual parent-child relationship in the vSphere Client so that you can easily identify the container VMs that are provisioned into a VCH. You can also specify resource limits on the resource pool. You can provision multiple VCHs onto a single ESXi host, into a resource pool, or into a vCenter Server cluster.

**NOTE**: Clusters that do not implement VMware vSphere Distributed Resource Scheduler (DRS) do not support resource pools. If you deploy a VCH to a cluster on which DRS is disabled, the VCH is created in a VM folder, rather than in a resource pool. This restricts your ability to configure resource usage limits on the VCH. It is strongly recommended that DRS is enabled on clusters to which you deploy VCHs.

## The VCH Endpoint VM <a id="endpoint"></a>

The VCH endoint VM is the VM that runs inside the VCH resource pool or folder. There is a 1:1 relationship between a VCH and a VCH endpoint VM. The VCH endpoint VM provides the following functions:

- Runs the services that a VCH requires.
- Provides a secure remote API to a client.
- Receives Docker commands and translates those commands into vSphere API calls and vSphere infrastructure constructs.
- Provides network forwarding so that ports to containers can be opened on the VCH endoint VM and the containers can access a public network.
- Manages the lifecycle of the containers, the image store, the volume store, and the container state
- Provides logging and monitoring of its own services and of its containers.

The lifecycle of the VCH endpoint VM is managed by a utility called `vic-machine`. 


## The `vic-machine` Utility <a id="vic-machine"></a>

The `vic-machine` utility is a binary for Windows, Linux, and OSX that manages the lifecycle of VCHs. `vic-machine` has been designed for use by vSphere administrators. It takes pre-existing compute, network, storage and a vSphere user as input and creates a VCH as output. It has the following additional functions:

- Creates certificates for Docker client TLS authentication.
- Checks that the prerequisites for VCH deployment are met on the cluster or host, namely that the firewall, licenses, and so on are configured correctly.
- Configures existing VCHs for debugging.
- Lists, inspects, upgrades, configures, and deletes VCHs.

The `vic-machine` utility also runs as a service in the vSphere Integrate Containers appliance. This service powers the Create Virtual Container Host wizard in the HTML5 vSphere Client plug-in, to allow you to deploy VCHs interactively from the vSphere Client.

**Next topic**: [Introduction to vSphere Integrated Containers Management Portal](intro_to_vic_mp.md)