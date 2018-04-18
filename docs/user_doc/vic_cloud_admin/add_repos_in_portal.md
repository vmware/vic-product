# Add Global Registries #

You can add multiple registries, in addition to the integrated vSphere Integrated Containers Registry to gain access to both public and private images. You can enable and disable the registries that you added. You can add global registries, that are visible to all projects, and project registries, that are available only to the project to which they are added. When you disable a registry, searching for templates and images in that registry is disabled. Even if you disable the default https://registry.hub.docker.com registry, you can still access the popular templates. To customize your popular templates, see [Customize the Popular Templates list](https://github.com/vmware/admiral/wiki/Configuration-guide#customize-the-popular-templates-list) documentation.

Starting with vSphere Integrated Containers 1.4, you can configure namespaces for the registries that you add. If you add a new registry and configure a namespace for it, developers cannot search, browse, or deploy images that are outside of that namespace. You can add a registry multiple times to allow developers to reach different namespaces in that registry.  

Use registries to store and distribute images. You can configure multiple registries to gain access to both public and private images. JFrog Artifactory is also supported.

vSphere Integrated Containers can interact with both Docker Registry HTTP API V1 and V2 in the following manner:

Protocol | Description
------------ | -------------
**V1 over HTTP (unsecured, plain HTTP registry)** | You can freely search this kind of registry, but you must manually configure each Docker host with the `--insecure-registry` flag to provision containers based on images from insecure registries. You must restart the Docker daemon after setting the property. You cannot use HTTP connections with vSphere Integrated Containers Registry instances.
**V1 over HTTPS** | Use behind a reverse proxy, such as NGINX. The standard implementation is available through open source at https://github.com/docker/docker-registry.
**V2 over HTTPS** | The standard implementation is open sourced at https://github.com/docker/distribution.
**V2 over HTTPS with basic authentication** | The standard implementation is open sourced at https://github.com/docker/distribution.
**V2 over HTTPS with authentication through a central service** | You can run a Docker registry in standalone mode, in which there are no authorization checks.


**Procedure**

1. In the management portal, navigate to **Administration** > **Global Registries** > **Source Registries** and click **+Registry**.

2. In the dialog box that opens, configure the registry settings.
	1. As address, enter the IP or hostname of the registry, the port, and optionally a namespace.

	For example: `https://registry.hub.docker.com:443/vmware`

	2. Enter a name for the registry.
	3. Optionally, select the login credentials to access the registry.
	4. Click **Verify** and if prompted to trust the registry certificate, click **OK**.
	5. After successful verification, click **Save**.


**Result**

The registry appears on the Global Registries page and you can access the images stored in that registry.
