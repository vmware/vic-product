# Overview of vSphere Integrated Containers For Container Application Developers  #

vSphere Integrated Containers is designed to integrate of all the packaging and runtime benefits of containers with the enterprise capabilities of a vSphere environment.  As a container developer, you can deploy, test, and run container processes in the same way as you would normally perform container operations. 

The information in this topic is intended for container developers. For an extended version of this information, see [Overview of vSphere Integrated Containers for vSphere Administrators](../vic_vsphere_admin/introduction.md) in *vSphere Integrated Containers for vSphere Administrators*. 

- [Differences Between vSphere Integrated Containers and a Classic Container Environment](#differences)
- [What Does vSphere Integrated Containers Do?](#whatisvic)
- [What Is vSphere Integrated Containers Engine?](#engine)
- [What Is vSphere Integrated Containers Registry?](#whats_registry)
- [What Is vSphere Integrated Containers Management Portal?](#whats_portal)

## Differences Between vSphere Integrated Containers and a Classic Container Environment {#differences}

The main differences between vSphere Integrated Containers and a classic container environment are the following:

- vSphere, not Linux, is the container host:
  - Containers are spun up *as* VMs, not *in* VMs.
  - Every container is fully isolated from the host and from the other containers.
  - vSphere provides per-tenant dynamic resource limits within a vCenter Server cluster
- vSphere, not Linux, is the infrastructure:
  - You can select vSphere networks that appear in the Docker client as container networks.
  - Images, volumes, and container state are provisioned directly to VMFS.
- vSphere is the control plane:
  - Use the Docker client to directly control selected elements of vSphere infrastructure.
  - A container endpoint Service-as-a-Service presents as a service abstraction, not as IaaS

## What Does vSphere Integrated Containers Do? {#whatisvic}

vSphere Integrated Containers allows the vSphere administrator to easily make the vSphere infrastructure accessible to you, the container application developer, so that you can provision container workloads into production.

**Scenario 1: A Classic Container Environment**

In a classic container environment: 

- You raise a ticket and say, "I need Docker". 
- The vSphere administrator provisions a large Linux VM and sends you the IP address.
- You install Docker, patch the OS, configure in-guest network and storage virtualization, secure the guest, isolate the containers, package the containers efficiently, and manage upgrades and downtime. 
 
In this scenario, what the vSphere administrator has given you is similar to a nested hypervisor that you have to manage and which is opaque to them.

**Scenario 2: vSphere Integrated Containers**

With vSphere Integrated Containers: 

- You raise a ticket and say, "I need Docker". 
- The vSphere administrator identifies datastores, networking, and compute on a cluster that you can use in your Docker environment. 
- The vSphere administrator uses a utility called `vic-machine` to install a small appliance. The appliance represents an authorization for you to use the infrastructure that the vSphere administrator has identified, into which you can self-provision container workloads.
- The appliance runs a secure remote Docker API, that is the only access that you have to the vSphere infrastructure.
- Instead of sending you a Linux VM, the vSphere administrator sends you the IP address of the appliance, the port of the remote Docker API, and a certificate for secure access.

In this scenario, the vSphere administrator has provided you with a service portal. This is better for you because you do not have to worry about isolation, patching, security, backup, and so on. It is better for the vSphere administrator because every container that you deploy is a container VM, that they can manage just like all of their other VMs.

If you discover that you need more compute capacity, in Scenario 1, the vSphere administrator has to power down the VM and reconfigure it, or give you a new VM and let you deal with the clustering implications. Both of these solutions are disruptive to you. With vSphere Integrated Containers  in Scenario 2, the vSphere administrator can reconfigure the VCH in vSphere, or redeploy it with a new configuration in a way that is completely transparent to you.

## What Is vSphere Integrated Containers Engine? {#engine}

The objective of vSphere Integrated Containers Engine is to take as much of vSphere as possible and layer whatever Docker capabilities are missing on top, reusing as much of Docker’s own code as possible. The  result should not sacrifice the portability of the Docker image format and should be completely transparent to a Docker client. The following sections describe key concepts and components that make this possible.

### Container VMs {#containervm}

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

### Virtual Container Hosts {#vch}

A virtual container host (VCH) is the functional equivalent of a Linux VM that runs Docker, but with some significant benefits. A VCH represents the following elements:
- A clustered pool of resource into which to provision container VMs.
- A single-tenant container namespace.
- A secure API endpoint. 
- Authorization to use and configure pre-approved virtual infrastructure.

A VCH is functionally distinct from a traditional container host in the following ways:

- It naturally encapsulates clustering and dynamic scheduling by provisioning to vSphere targets.
- The resource constraints are dynamically configurable with no impact on the containers.
- Containers do not share a kernel.
- There is no local image cache. This is kept on a datastore in the cluster that the vSphere administrator specified when they deployed a VCH.
- There is no read-write shared storage

## What Is vSphere Integrated Containers Registry? {#whats_registry}

vSphere Integrated Containers Registry is an enterprise-class registry server that you can use to store and distribute container images. vSphere Integrated Containers Registry allows DevOps administrators to organize image repositories in projects, and to set up role-based access control to those projects to define which users can access which repositories. vSphere Integrated Containers Registry also provides rule-based replication of images between registries, implements Docker Content Trust, and provides detailed logging for project and user auditing.

For a more detailed overview of vSphere Integrated Containers Registry, see [Managing Images, Projects, and Users with vSphere Integrated Containers Registry](../vic_dev_ops/using_registry.html) in *vSphere Integrated Containers for DevOps Administrators*.

## What Is vSphere Integrated Containers Management Portal? {#whats_portal}

vSphere Integrated Containers Management Portal is a highly scalable and very lightweight container management platform for deploying and managing container based applications. It is designed to have a small footprint and boot extremely quickly. vSphere Integrated Containers Management Portal is intended to provide DevOps administrators with automated deployment and lifecycle management of containers.

- Rule-based resource management, allowing DevOps administrators to set deployment preferences which let vSphere Integrated Containers Management Portal manage container placement.
- Live state updates that provide a live view of the container system.
- Multi-container template management, that enables logical multi-container application deployments.

For a more information about vSphere Integrated Containers Management Portal, see [View and Manage VCHs, Add Registries, and Provision Containers Through the Management Portal](../vic_dev_ops/vchs_and_mgmt_portal.html) in *vSphere Integrated Containers for DevOps Administrators*.