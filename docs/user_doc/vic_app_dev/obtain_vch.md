# Obtain a Virtual Container Host #

vSphere Integrated Containers Engine does not currently provide an automated means of obtaining virtual container hosts (VCHs).

When the vSphere administrator uses `vic-machine create` to deploy a VCH, the VCH endpoint VM obtains an IP address. The IP address can either be static or be obtained from DHCP. As a container developer, you require the IP address of the VCH endpoint VM when you run Docker commands. 

You can see the addresses of the VCHs that are associated with your project by logging in to vSphere Integrated Containers Management Portal and selecting **Home** > **Infrastructure** > **Container Hosts**.

If the vSphere administrator deploys VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. You can use the contents of the `env` file to set environment variables in your Docker client. Similarly, if the vSphere administrator deployed the VCH with TLS authentication of clients, you must obtain the client certificates. The vSphere administrator or an automated provisioning service for VCHs could potentially provide the `env` file to you when you request a VCH. For more information about setting environment variables and client certificates for VCHs in your Docker client, see [Configure the Docker Client for Use with vSphere Integrated Containers](configure_docker_client.html). 