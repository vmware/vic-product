# Manage Internal Repositories in Projects

You can access the list of internal repositories that users have pushed to a project. You can browse repositories to see the different tags applied to images in the repository. You can also delete a repository or a tag in a repository.

Deleting a repository involves two steps. First, you delete a repository in vSphere Integrated Containers Management Portal. This is known as soft deletion. You can delete the entire repository or just one tag in the repository. After a soft deletion, the registry no longer manages the repository. However, the repository files remain in the registry storage until you run garbage collection by restarting the registry. You can optionally add a description for the repository.

**Prerequisites**

- Log in to vSphere Integrated Containers Management Portal with a vSphere administrator, Management Portal administrator, or DevOps administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).
- You have created a project and pushed at least one repository to the project.

**Procedure**

1. Navigate to **Administration** > **Projects** > **Your_project**.
   
    Use an account with the Management Portal administrator role, or an account that has the DevOps administrator role for this project.

2. Click the **Internal Repositories** tab to see the number of tags that the repository contains and how many times that users have pulled the repository
3. (Optional) To delete a repository, select the check box next to a repository name and click **Delete**.

    **CAUTION**: If two tags refer to the same image, if you delete one tag, the other tag is also deleted.
4. Click a repository name to view its contents.
5. (Optional) To add or edit a repository description, click the **Edit** button in the **Info** tab.
	
    Use an account with the Management Portal administrator role, or an account that has the DevOps administrator role to add or edit a description.

**What to Do Next**

If you deleted respositories, and if the registry is configured with garbage collection enabled, restart the registry. vSphere Integrated Containers Registry will perform garbage collection when it reboots. For information about restarting the registry, see [Restart the vSphere Integrated Containers Services](../vic_vsphere_admin/restart_services.md) in *vSphere Integrated Containers for vSphere Administrators*.