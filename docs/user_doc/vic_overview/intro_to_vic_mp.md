# Introduction to vSphere Integrated Containers Management Portal

vSphere Integrated Containers Management Portal is a highly scalable and very lightweight container management platform for deploying and managing container based applications. The management portal runs as a container in the vSphere Integrated Containers virtual appliance. It is designed to have a small footprint and boot extremely quickly. vSphere Integrated Containers Management Portal is intended to provide DevOps administrators with automated deployment and lifecycle management of containers.

- Resource management, allowing DevOps administrators to set deployment preferences that let vSphere Integrated Containers Management Portal manage container placement.
- Live state updates that provide a live view of the container system.
- Multi-container template management, that enables logical multi-container application deployments.

For more information about vSphere Integrated Containers Management Portal, see [vSphere Integrated Containers Management Portal Administration](../vic_cloud_admin/).

- [Projects and Role-Based Access Control](#projects)
- [User Authentication](#authentication)

## Projects and Role-Based Access Control <a id="projects"></a>

In vSphere Integrated Containers Management Portal, you organize repositories in projects. "Repository" is Docker terminology for a collection of container images that have the same name but that have different tags. You assign users, registries, and VCHs to the projects and you assign roles with different permissions to the users in each project. There are two types of project in vSphere Integrated Containers:  

  - **Public projects**: All users can pull images from the project. Users must be members of a project and have the appropriate privileges to push images to the project.
  - **Private projects**: Only members of the project can pull images from private private projects. Members must have the appropriate privileges to be able to push images to the project.

When you first deploy vSphere Integrated Containers, a default public project named `default-project` is created, that includes the default vSphere Integrated Containers Registry instance. You can toggle projects from public to private, or the reverse, at any moment.


## User Authentication <a id="authentication"></a>

vSphere Integrated Containers is fully integrated with VMware Platform Services Controller. The Platform Services Controller provides common infrastructure services to the vSphere environment. Services include licensing, certificate management, and authentication with vCenter Single Sign-On. With vCenter Single Sign-On you can use local users created in the Platform Services Controller or configure external identity sources. 

For more information about deploying, configuring, and working with Platform Services Controller, see the [Platform Services Controller Administration Guide](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.psc.doc/GUID-9451A5B4-5747-42C1-8A82-83AFCC1F2861.html) in the VMware vSphere documentation.

You can pull users from the Platform Services Controller and assign them roles through the vSphere Integrated Containers Management Portal. For more information about roles, see [vSphere Integrated Containers Roles and Personas](roles_and_personas.md).

You can deploy multiple vSphere Integrated Containers appliances to the same vCenter Server instance. Also, if a Platform Services Controller manages multiple vCenter Server instances, you can deploy multiple appliances to different vCenter Server instances that share that Platform Services Controller. In either of these setups, the appliances all register with the same Platform Services Controller, and can pull users from that Platform Services Controller. These setups allow the same user to have different roles in different vSphere Integrated Containers instances.

**Next topic**: [Introduction to vSphere Integrated Containers Registry](intro_to_vic_registry.md)