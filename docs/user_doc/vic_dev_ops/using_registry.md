# Managing Images, Projects, and Users with vSphere Integrated Containers Registry #

vSphere Integrated Containers Registry is an enterprise-class registry server that you can use to store and distribute container images. vSphere Integrated Containers Registry extends the open source Docker Distribution project by adding the features that enterprise users require, such as user management, access control, and activity auditing. You can improve image transfer efficiency by deploying vSphere Integrated Containers Registry alongside vSphere Integrated Containers Engine, so that your registry is located close to the build and run environment. 

The sections below present the key features of vSphere Integrated Containers Registry.

- [Projects and Role-Based Access Control](#projects)
- [User Authentication](#authentication)
- [Rule-Based Image Replication](#replication)
- [Garbage Collection](#gc)
- [Logging](#logging)

## Projects and Role-Based Access Control {#projects}

In vSphere Integrated Containers Registry, you organize repositories in projects. "Repository" is Docker terminology for a collection of container images that have the same name but that have different tags. You assign users to the projects and you assign roles with different permissions to the users in each project. There are two types of project in vSphere Integrated Containers Registry:  

  - **Public projects**: All users can pull images from the project. Users must be members of a project and have the appropriate privileges to push images to the project.
  - **Private projects**: Only members of the project can pull images from private private projects. Members must have the appropriate privileges to be able to push images to the project.

When you first deploy vSphere Integrated Containers Registry, a default public project named `library` is created. You can toggle projects from public to private, or the reverse, at any moment.

For information about projects, see [Create a Project](creating_projects_registry.md), [Assign Users to a Project](add_users_registry.md), [Manage Project Members](manage_project_members.md), and [Manage Projects](manage_projects.md).

## User Authentication {#authentication}

You can configure vSphere Integrated Containers Registry to use an existing LDAP or Active Domain service, or use local user management to authenticate and manage users.

### Local User Management ###
	
You create user and manage user accounts locally in vSphere Integrated Containers Registry. User information is stored in a database that is embedded in vSphere Integrated Containers Registry. When you first deploy vSphere Integrated Containers Registry, the registry uses local user management by default. For information about creating local user accounts, see [Create Users](vic_dev_ops/creating_users_registry.md).

### LDAP Authentication ###  

Immediately after you deploy vSphere Integrated Containers Registry, can you configure the registry to use an external LDAP or Active Directory server  to authenticate users. If you implement LDAP authentication, users whose credentials are stored by the external LDAP or Active Directory server can log in to vSphere Integrated Containers Registry directly. In this case, you do not need to create user accounts locally.

**IMPORTANT**: The option to switch from local user management to LDAP authentication is only available while the local database is empty. If you start to populate the database with users and projects, the option to switch to LDAP authentication is disabled. If you want to implement LDAP authentication, you must enable this option when you first log in to a new registry instance. 

For information about enabling LDAP authentication, see [Configure a Registry](configure_registry.md).

## Rule Based Image Replication {#replication}

You can set up multiple registries and replicate images between registry instances. Replicating images between registries helps with load balancing and high availability, and allows you to create multi-datacenter, hybrid, and multi-cloud setups. For information about image replication, see [Replicating Images](replicating_images.md).

## Garbage Collection {#gc}

You can configure vSphere Integrated Containers Registry to perform garbage collection whenever you restart the registry service. If you implement garbage collection, the registry recycles the storage space that is consumed by images that you have deleted. For more information about garbage collection, see [Delete a Repository](delete_repository_registry.md). See also [Garbage Collection](https://docs.docker.com/registry/garbage-collection/) in the Docker documentation.

**IMPORTANT**: The option to activate garbage collection is only available when you deploy the vSphere Integrated Containers appliance. After you have deployed the appliance, you cannot retroactively enable or disable garbage collection.

## Logging {#logging}

vSphere Integrated Containers Registry keeps a log of every operation that users perform in a project. The logs are fully searchable, to assist you with activity auditing. For information about project logs, see [Access Project Logs](access_project_logs.md).
