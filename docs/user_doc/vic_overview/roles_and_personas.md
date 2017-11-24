# Roles and Personas #

vSphere Integrated Containers needs the Virtual Infrastructure Admin and features four additional roles for user access. The viewer role has the lowest level of access with the global administrator having the highest. 

![vSphere Integrated Containers Conceptual Overview](graphics/conceptual-overview.png)

Permissions per role are described below in reversed order, as every next role listed, inherits the permissions of the previous role and has additional ones.

**V. Viewer**

Role assigned per project.
- If assigned, role only has view access to the repositories for a project.

**IV. Developer**

Role assigned per project. In addition to the view access, a developer can also:
- Provision containers
- Push images
- Create and import templates

**III. DevOps Administrator**

Role assigned per project. For their assigned projects DevOps administrators can perform additional actions:
- Add developers and viewers and assign other DevOps administrators
- Change the project configurations, such as making the project registry public, changing deployment security settings, and enabling vulnerability scanning

**II. Cloud administrator / Global Administrator for all projects**

The cloud administrator role is assigned to the Administrators group for vCenter Server during the installation of vSphere Integrated Containers. Through the management portal, you can revoke that role for the Administrators group, only after you assign the role to another group. Cloud administrators can also assign the role to individual users.

The following global permissions are unique to the cloud administrator role:
- Add new cloud administrators
- Create new projects and assign the first DevOps administrator to them
- Add hosts and clusters as resources to a given project
- Add and manage registries, replication endpoints, and replication rules
- Add predefined credentials and certificates for authentication
- Set global configurations for registries handling
- View system logs