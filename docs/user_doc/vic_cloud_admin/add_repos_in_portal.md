# Add Registries to the Management Portal #

You can add multiple registries to gain access to both public and private images. You can enable and disable the registries that you added. When you disable a registry, searching for templates and images in that registry is disabled. Even if you disable the default https://registry.hub.docker.com registry, you can still access the popular templates. To customize your popular templates, see [Customize the Popular Templates list](https://github.com/vmware/admiral/wiki/Configuration-guide#customize-the-popular-templates-list) in the Admiral documentation.

vSphere Integrated Containers can interact with both Docker Registry HTTP API V1 and V2 in the following manner:

Protocol | Description
------------ | -------------
**V1 over HTTP (unsecured, plain HTTP registry)** | You can freely search this kind of registry, but you must manually configure each Docker host with the `--insecure-registry` flag to provision containers based on images from insecure registries. You must restart the Docker daemon after setting the property. You cannot use HTTP connections with vSphere Integrated Containers Registry instances.
**V1 over HTTPS** | Use behind a reverse proxy, such as NGINX. The standard implementation is available through open source at https://github.com/docker/docker-registry.
**V2 over HTTPS** | The standard implementation is open sourced at https://github.com/docker/distribution.
**V2 over HTTPS with basic authentication** | The standard implementation is open sourced at https://github.com/docker/distribution.
**V2 over HTTPS with authentication through a central service** | You can run a Docker registry in standalone mode, in which there are no authorization checks.


**Procedure**

1. In the management portal, navigate to **Templates** > **Registries** and click **Add**.

5. In the Add Registry dialog box, configure the registry settings.
	1. As address, enter the IP or hostname of the registry and the port.

    If you add the vSphere Integrated Containers Registry, enter https://*hostname*:443.
	2. Enter name for the registry.
	3. Select the login credential and click **Verify**.
	4. If prompted to trust the registry certificate, click **OK**.
	5. After successful verification, click **Save**.


**Result**

The registry appears on the Registries page and you can access the images stored in that registry.