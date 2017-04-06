# Obtain a VCH #

vSphere Integrated Containers Engine does not currently provide an automated means of obtaining virtual container hosts (VCHs).

When the vSphere administrator uses `vic-machine create` to deploy a VCH, the VCH endpoint VM obtains an IP address. The IP address can either be static or be obtained from DHCP. As a container developer, you require the IP address of the VCH endpoint VM when you run Docker commands. 

Depending on the nature of your organization, you might deploy VCHs yourself, or you might request a VCH from a different person or team. If you do not run `vic-machine create` yourself, your organization must define the process by which you obtain VCH addresses. This process can be as simple as an exchange of emails with a vSphere administrator, or as advanced as a custom self-provisioning portal or API end-point.

If the vSphere administrator deploys VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. You can use the contents of the `env` file to set environment variables in your Docker client. The vSphere administrator or an automated provisioning service for VCHs could potentially provide the `env` file to you when you request a VCH.