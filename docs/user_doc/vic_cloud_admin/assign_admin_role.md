# Assign the System-Wide Administrator Role to Users # 

You can assign the system-wide administrator role to any user. Users with the administrator role have extra permissions in addition to their project-specific privileges. 

- Browse and manage all projects
- Register new users
- Assign the administrator role to other users
- Delete users
- Manage replication rules in a project
- Perform system-wide configuration 

The administrator role owns the default public project named `library`.  

**Prerequisites**

You have created at least one user.

**Procedure**

1. Log in to the vSphere Integrated Containers Management Portal at https://<i>vic_appliance_address</i>:8282.

   Use the `admin` account, or an account with Administrator privileges. If the vSphere Integrated Containers appliance uses a different port for vSphere Integrated Containers Registry, replace 443 with the appropriate port.
2. Expand **Administration** on the left, and click **Users**.
7. In the list of users, click the 3 vertical dots next to a user name and select **Set as Administrator**.
8. To remove the administrator role from a user, click the 3 vertical dots next to a user name and select **Revoke Administrator**.