# Provisioning Container VMs in the Management Portal #

You can provision containers or container VMs from the management portal depending on the target host. If your target host is a VCH, you provision container VMs. If your target host is a Docker host, you provision standard containers. You can quick-provision by using default settings or you can customize your deployment by using the available settings. You can either provision or save as a template your configured container.

If you provision 

You can provision containers, templates, or images. 
- To provision a single container, go to **Home** > **Containers** and click **+ Container**.
- To provision an image with additional settings, go to **Home** > **Templates** and import a new template from file that you can later provision.


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
	- HTTP
	- TCP connection
	- Command
- Logging

When you configure a container, on the **Environment** tab, you can add industry standard variables.
For information about using Docker environment variables, see [Environment variables in Compose](https://docs.docker.com/compose/environment-variables/) in the Docker documentation.

**Related topics**

- [Configuring Links](configuring_links.md)
- [Configuring Health Checks](configuring_health_checks.md)
- [Configuring Cluster Size and Scale](configuring_clusters.md)
