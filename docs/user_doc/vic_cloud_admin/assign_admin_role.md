# Assign the Cloud Administrator Role to Users 

You can assign the cloud administrator role to any user. Users with the cloud administrator role have extra permissions in addition to their project-specific privileges. 

- Browse and manage all projects
- Register new users
- Assign the cloud administrator role to other users
- Delete users
- Manage replication rules in a project
- Perform system-wide configuration 

The cloud administrator role owns the default public project named `library`.  

**Prerequisites**

You added at least one user in the system.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

    Use an account with Cloud Administrator privileges.
2. Select the **Administration** tab, and click **Users**.
7. In the list of users, click the 3 vertical dots next to a user name and select **Set as Administrator**.
8. To remove the administrator role from a user, click the 3 vertical dots next to a user name and select **Revoke Administrator**.