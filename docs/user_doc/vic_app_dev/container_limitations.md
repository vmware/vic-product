# Use and Limitations of vSphere Integrated Containers Engine

vSphere Integrated Containers Engine currently includes the following capabilities and limitations:

## Supported Docker Features
This version of vSphere Integrated Containers Engine supports these features:

- `docker-compose`
- Pulling images from Docker hub and private registries
- Named data volumes
- Anonymous data volumes
- Sharing concurrent NFS share points between containers
- Bridged networks
- External networks
- Port mapping
- Network links/aliases

## Unsupported Docker Features

This version of vSphere Integrated Containers Engine does not support these features:

- Pulling images via image digest 
- Mapping a local host folder to a container volume
- Mapping a local host file to a container
- `docker push`
- `docker build`

For limitations of using vSphere Integrated Containers with volumes, see [Using Volumes with vSphere Integrated Containers Engine](using_volumes_with_vic.md).

## Limitations of vSphere Integrated Containers Engine
vSphere Integrated Containers Engine includes these limitations:

- If you do not configure a `PATH` environment variable, or if you create a container from an image that does not supply a `PATH`, vSphere Integrated Containers Engine provides a default `PATH`.
- You can resolve the symbolic names of a container from within another container, except in the following cases:
	- Aliases
	- IPv6
	- Service discovery
- Containers can acquire DHCP addresses only if they are on a network that has DHCP.
- When you use a standard Docker Engine, an image can have a maximum of 120 layers. When you use a vSphere Integrated Containers Engine virtual container host (VCH), an image can have a maximum of 90 layers. For more information, see [Pulling Images into VCHs Fails with Image Store Error](../vic_vsphere_admin/ts_imagestore_error.md) in the Troubleshooting section.