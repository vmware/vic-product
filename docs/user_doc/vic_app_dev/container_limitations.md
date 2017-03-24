# Use and Limitations of vSphere Integrated Containers Engine

vSphere Integrated Containers Engine currently includes the following capabilities and limitations:

## Supported Docker Features
This version of vSphere Integrated Containers Engine supports these features:

- `docker-compose`
- Pulling images from Docker hub and private registries
- Named data volumes
- Anonymous data volumes
- Bridged networks
- External networks
- Port mapping
- Network links/aliases

## Limitations
vSphere Integrated Containers Engine includes these limitations:

- Container VMs only support root user.
- When you do not configure a `PATH` environment variable, or create a container from an image that does not supply a `PATH`, vSphere Integrated Containers Engine provides a default PATH.
- You can resolve the symbolic names of a container from within another container, except in the following cases:
	- Aliases
	- IPv6
	- Service discovery
- Containers can acquire DHCP addresses only if they are on a network that has DHCP.

## Using `docker-compose` with TLS

vSphere Integrated Containers supports TLS v1.2, so you must configure `docker-compose` to use TLS 1.2. However, `docker-compose` does not allow you to specify the TLS version on the command line. You must use environment variables to set the TLS version for `docker-compose`. For more information, see [`docker-compose` issue 4651](https://github.com/docker/compose/issues/4651). Furthermore, `docker-compose` has a limitation that requires you to set TLS options either by using command line options or by using environment variables. You cannot use a mixture of both command line options and environment variables. 

To use `docker-compose` with vSphere Integrated Containers and TLS, set the following environment variables:<pre>COMPOSE_TLS_VERSION=TLSv1_2
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH="<i>path to your cert files</i>"</pre>

The certificate file path must lead to `CA.pem`, `client_key.pem`, and `client cert.pem`. You can run `docker-compose` with the following command:<pre>docker-compose -H <i>vch_address</i> up</pre>

## Unsupported Docker Features

This version of vSphere Integrated Containers Engine does not support these features:

- Pulling images via image digest 
- Sharing concurrent data volume between containers
- Mapping a local host folder to a container volume
- Mapping a local host file to a container
- `docker push`
- `docker build`
- `docker cp`

For limitations of using vSphere Integrated Containers with volumes, see [Using Volumes with vSphere Integrated Containers Engine](using_volumes_with_vic.md).