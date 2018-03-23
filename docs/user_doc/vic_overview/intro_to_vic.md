# Introduction to vSphere Integrated Containers

vSphere Integrated Containers enables IT teams to seamlessly run traditional workloads and container workloads side-by-side on existing vSphere infrastructure. 

- [vSphere Integrated Containers Components](#components)
- [Advantages of vSphere Integrated Containers](#advantages)
- [How vSphere Integrated Containers Helps vSphere Administrators](#helps_admins)

## vSphere Integrated Containers Components <a id="components"></a>

vSphere Integrated Containers is delivered as an appliance, that comprises the following major components:

- **vSphere Integrated Containers Engine**, a container runtime for vSphere that allows you to provision containers as virtual machines, offering the same security and functionality of virtual machines in VMware ESXi&trade; hosts or vCenter Server&reg; instances. 
- **vSphere Integrated Containers Plug-In for vSphere Client**, that provides information about your vSphere Integrated Containers setup and allows you to deploy virtual container hosts directly from the vSphere Client.
- **vSphere Integrated Containers Registry**, an enterprise-class container registry server that stores and distributes container images. vSphere Integrated Containers Registry extends the [Docker Distribution](https://github.com/docker/distribution) open source project by adding the functionalities that an enterprise requires, such as security, identity and management.
- **vSphere Integrated Containers Management Portal**, a container management portal that provides a UI for DevOps teams to provision and manage containers, including the ability to obtain statistics and information about container instances. Cloud administrators can manage container hosts and apply governance to their usage, including capacity quotas and approval workflows. Cloud administrators can create projects, and assign users and resources such as registries and virtual container hosts to those projects.

These components currently support the Docker image format. vSphere Integrated Containers is entirely Open Source and free to use. Support for vSphere Integrated Containers is included in the vSphere Enterprise Plus license.

## Advantages of vSphere Integrated Containers <a id="advantages"></a>

vSphere Integrated Containers is designed to solve many of the challenges associated with putting containerized applications into production. It directly uses the clustering, dynamic scheduling, and virtualized infrastructure in vSphere and bypasses the need to maintain discrete Linux VMs as container hosts.

vSphere Integrated Containers allows the vSphere administrator to provide a container management endpoint to a user as a service. At the same time, the vSphere administrator remains in complete control over the infrastructure that the container management endpoint service depends on. The main differences between vSphere Integrated Containers and a classic container environment are the following:

- **vSphere, not Linux, is the container host**
  - Containers are deployed *as* VMs, not *in* VMs.
  - Every container is fully isolated from the host and from the other containers.
  - vSphere provides per-tenant dynamic resource limits within a vCenter Server cluster.
- **vSphere, not Linux, is the infrastructure**
  - You can select vSphere networks that appear in the Docker client as container networks.
  - Images, volumes, and container state are provisioned directly to VMFS.
- **vSphere is the control plane**
  - Use the Docker client to directly control selected elements of vSphere infrastructure.
  - A container endpoint Service-as-a-Service presents as a service abstraction, not as IaaS.

vSphere Integrated Containers is designed to be the fastest and easiest way to provision any Linux-based workload to vSphere, if that workload can be serialized as a Docker image.

## How vSphere Integrated Containers Helps vSphere Administrators <a id="helps_admins"></a>

vSphere Integrated Containers gives the vSphere administrator the tools to easily make the vSphere infrastructure accessible to users so that they can provision container workloads into production.

**Scenario 1: A Classic Container Environment**

In a classic container environment: 

- A user raises a ticket and says, "I need Docker". 
- The vSphere administrator provisions a large Linux VM and sends them the IP address.
- The user installs Docker, patches the OS, configures in-guest network and storage virtualization, secures the guest, isolates the containers, packages the containers efficiently, and manages upgrades and downtime. 
 
In this scenario, what the vSphere administrator has provided is similar to a nested hypervisor, that is opaque and that they have to manage. If they scale that up to one large Linux VM per tenant, they end up creating a large distributed silo for containers.

**Scenario 2: vSphere Integrated Containers**

With vSphere Integrated Containers: 

- A user raises a ticket and says, "I need Docker". 
- The vSphere administrator identifies datastores, networking, and compute resources on a cluster that users can use for their Docker environment. 
- The vSphere administrator uses the vSphere Integrated Containers plug-in for the vSphere Client or a command-line utility called `vic-machine` to install a small appliance, called a virtual container host (VCH). The VCH represents an authorization to use the infrastructure that they have identified, into which users can self-provision container workloads.
- The appliance runs a secure remote Docker API, that is the only access that the user has to the vSphere infrastructure.
- Instead of sending the user a Linux VM, the vSphere administrator sends them the IP address of the appliance, the port of the remote Docker API, and a certificate for secure access.

In this scenario, the vSphere administrator has provided the user with a service portal. This is better for the user because they do not have to worry about isolation, patching, security, backup, and so on. It is better for the vSphere administrator because every container that the user deploys is a container VM. vSphere administrators can perform vMotion and monitor container VMs just like all of their other VMs.

If the user needs more compute capacity, in Scenario 1, the pragmatic choice is to power down the VM and reconfigure it, or give the user a new VM and let them deal with the clustering implications. Both of these solutions are disruptive to users. With vSphere Integrated Containers in Scenario 2, the vSphere administrator can reconfigure the VCH in vSphere, or redeploy it with a new configuration in a way that is completely transparent to the user.

vSphere Integrated Containers allows the vSphere administrator to select and dictate the appropriate infrastructure for the task in hand:

- Networking: Select multiple port groups for different types of network traffic, ensuring that all of the containers that a user provisions get the appropriate interfaces on the right networks.
- Storage: Select different vSphere datastores for different types of state. For example, container state is ephemeral and is unlikely to need to be backed up, but volume state almost certainly should be backed up. vSphere Integrated Containers automatically ensures that state gets written to the appropriate datastore when the user provisions a container.

To summarize, vSphere Integrated Containers gives vSphere administrators a mechanism that allows users to self-provision VMs as containers into the virtual infrastructure.
