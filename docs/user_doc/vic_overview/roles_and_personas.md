# vSphere Integrated Containers Roles and Personas

vSphere Integrated Containers requires a vSphere administrator role for deployment and provides four additional roles for user access. The viewer role has the lowest level of access with the global cloud administrator having the highest.

The following image shows how the different roles manage and use the different components of vSphere Integrated Containers.

![vSphere Integrated Containers Conceptual Overview](graphics/conceptual-overview.png)

Permissions per role are described in the following sections in reversed order, as every next role listed inherits the permissions of the previous role and has additional ones.

- [V. Viewer](#viewer)
- [IV. Developer](#developer)
- [III. DevOps Administrator](#devopsadmin)
- [II. Cloud Administrator](#cloudadmin)
- [I. Virtual Infrastructure Administrator](#viadmin)

## V. Viewer <a id="viewer"></a>

Role assigned per project. This role only has view access to the repositories for a project in vSphere Integrated Containers Management Portal.

## IV. Developer <a id="developer"></a>

Role assigned per project. In addition to the view access, for their assigned projects developers can also:
- Provision containers
- Push images into registries
- Create and import templates

## III. DevOps Administrator <a id="devopsadmin"></a>

Role assigned per project. For their assigned projects, DevOps administrators can perform additional actions in vSphere Integrated Containers Management Portal:

- Add developers and viewers and assign other DevOps administrators
- Add new registries to their project
- Change the project configurations, such as making the project registry public, changing deployment security settings, and enabling vulnerability scanning

## II. Cloud Administrator <a id="cloudadmin"></a>

The cloud administrator is the global administrator for all projects in vSphere Integrated Containers Management Portal. The cloud administrator role is assigned to the Administrators group for vCenter Server during the installation of vSphere Integrated Containers. Through the management portal, you can revoke that role for the Administrators group, only after you assign the role to another group. Cloud administrators can also assign the role to individual users.

The following global permissions are unique to the cloud administrator role:

- Add new cloud administrators
- Create new projects and assign the first DevOps administrator to them
- Add hosts as resources to a given project
- Add and manage registries, replication endpoints, and replication rules
- Add predefined credentials and certificates for authentication
- Add global and per project registries
- Set global configurations for registries
- View system logs

## I. Virtual Infrastructure Administrator <a id="viadmin"></a>

vSphere administrators prepare, install, and set up vSphere Integrated Containers. The typical workflow includes the following actions:
- Deploy the vSphere Integrated Containers appliance
- Deploy Virtual Container Hosts
- Provide the information for the deployed assets to vSphere Integrated Containers users
- Assign Cloud administrators
- Perform update and upgrade procedures for vSphere Integrated Containers

vSphere Administrators automatically have cloud administrator privileges in vSphere Integrated Containers Management Portal. 

You can also see the roles and personas described in the vSphere Integrated Containers overview video.
{{ 'https://www.youtube.com/watch?v=phsVFTVK4t4&t=' | noembed }}
 
## Example Users #####

You can create example Cloud administrator, DevOps administrator, and  Developer users during the deployment of vSphere Integrated Containers appliance. These users are created automatically as local users in the Platform Services Controller. By default, when you use the option to create example users, you end up with the following user accounts:

- vic-cloud-admin@*local_domain*
- vic-devops-admin@*local_domain*
- vic-developer@*local_domain*

You can use the example user accounts to log in to vSphere Integrated Containers Management Portal to test the different levels of access of each type of user.
