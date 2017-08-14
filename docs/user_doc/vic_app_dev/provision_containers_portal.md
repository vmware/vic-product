# Provisioning Container VMs in the Management Portal #

You can provision container VMs from the management portal. You can quick-provision containers by using default settings or you can customize your deployment by using the available settings. You can either provision or save as a template your configured container.

You can provision containers, templates, or images. 
- To provision a single container, go to **Home** > **Containers** and click **Create container**.
- To provision an image with additional settings, go to **Templates** > **Templates**, filter by images, and under **Provision** click **Enter additional info**.
- To provision a template, go to **Templates** > **Templates**, filter by templates, and click **Provision**.

When you create containers from the Containers page in the management portal, you can configure the following settings:
- Basic configuration
	- Image to be used
	- Name of the container
	- Custom commands
	- Links
- Network configuration
	- Port bindings and ports publishing
	- Hostname
	- Network mode
- Storage configuration
	- Select volumes
	- Configure a working directory
- Policy configuration
	- Define clusters
	- Resource allocation
	- Anti-affinity rules
- Custom environment variables
- Health checks
- Logging

**Related topics**

- [Configuring Links](configuring_links.md)
- [Configuring Health Checks](configuring_health_checks.md)
- [Configuring Cluster Size and Scale](configuring_clusters.md)