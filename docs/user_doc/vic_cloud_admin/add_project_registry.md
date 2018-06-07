# Add Project Specific Registries #

In addition to the integrated vSphere Integrated Containers Registry and the global registries added by the Cloud administrator, DevOps administrators can add project specific registries. From the Project registries view, DevOps administrators can add, update, and delete project specific registries and also see the available global registries but cannot remove them.

Starting with vSphere Integrated Containers 1.4, you can also configure namespaces for the registries that you add. If you add a new registry and configure a namespace for it, developers cannot search, browse, or deploy images that are outside of that namespace. You can add a registry multiple times to allow developers to reach different namespaces in that registry.   

**Prerequisites** 

Log in to vSphere Integrated Containers Management Portal with a vSphere administrator, Cloud administrator, or DevOps administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).

**Procedure**

1. Navigate to **Administration** > **Projects** and click your project.
2. On the Project Registries tab, click **+ New Project Registry**.
3. On the Add Project Registry page, configure your new registry.
	1. As address, enter the IP or hostname of the registry, the port, and optionally a namespace.

	For example: `https://registry.hub.docker.com:443/library`

	2. Enter a name for the registry.
	3. Optionally, select the login credentials to access the registry.
	4. Click **Verify** and if prompted to trust the registry certificate, click **OK**.
	5. After successful verification, click **Save**.


**Result**

The registry appears on the Project Registries page and you can access the images stored in that registry.
