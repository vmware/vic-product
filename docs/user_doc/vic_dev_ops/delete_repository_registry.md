# Delete a Repository

Deleting a repository involves two steps. First, you delete a repository in vSphere Integrated Containers Registry interface. This is known as soft deletion. You can delete the entire repository or just one tag in the repository. After a soft deletion, the registry no longer manages the repository. However, the repository files remain in the registry storage until you run garbage collection by restarting the registry. 

**IMPORTANT**: The option to activate garbage collection is only available when you deploy the vSphere Integrated Containers appliance. After you have deployed the appliance, you cannot retroactively enable or disable garbage collection.


**Prerequisites**

You have created a project and pushed at least one repository to the project.

**Procedure**

1. Log in to the vSphere Integrated Containers Registry interface at https://<i>vic_appliance_address</i>:443.

   Use the `admin` account, an account with the system-wide Administrator role, or an account that has the Project Admin role for this project. If the vSphere Integrated Containers appliance uses a different port for vSphere Integrated Containers Registry, replace 443 with the appropriate port.
2. Click **Projects** on the left and click the name of a project in the project list.
3. In the list of repositories, click the 3 vertical dots next to a repository name and select **Delete**.

   **CAUTION**: If two tags refer to the same image, if you delete one tag, the other tag is also deleted.

**What to Do Next**

If the registry is configured with garbage collection enabled, restart the registry. vSphere Integrated Containers Registry will perform garbage collection when it reboots. For information about restarting the registry, see [Restart the vSphere Integrated Containers Services](../vic_vsphere_admin/restart_services.md) in *vSphere Integrated Containers for vSphere Administrators*.
