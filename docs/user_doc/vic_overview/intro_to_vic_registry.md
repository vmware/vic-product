# Introduction to vSphere Integrated Containers Registry

vSphere Integrated Containers Registry is an enterprise-class registry server that you can use to store and distribute container images. The registry runs as a container in the vSphere Integrated Containers virtual appliance. vSphere Integrated Containers Registry allows DevOps administrators to organize image repositories in projects, and to set up role-based access control to those projects to define which users can access which repositories. vSphere Integrated Containers Registry also provides rule-based replication of images between registries, implements Docker Content Trust and vulnerability scanning, and provides detailed logging for project and user auditing.

- [Rule-Based Image Replication](#replication)
- [Docker Content Trust](#notary)
- [Vulnerability Scanning](#vulnerability)
- [Garbage Collection](#gc)
- [Logging](#logging)

For demo videos of some of the features of vSphere Integrated Containers Registry, see the [VMware Harbor YouTube Channel](https://www.youtube.com/channel/UCSxaozHKrX3F0UnZeYe5Itg).

## Rule Based Image Replication <a id="replication"></a>

You can set up multiple registries and replicate images between registry instances. Replicating images between registries helps with load balancing and high availability, and allows you to create multi-datacenter, hybrid, and multi-cloud setups. For information about image replication, see [Replicating Images](../vic_cloud_admin/replicating_images.md).


## Docker Content Trust <a id="notary"></a>

vSphere Integrated Containers Registry provides a Docker Notary server that allows you to implement Docker Content Trust by signing and verifying the images in the registry. For information about Docker Notary, see [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/) in the Docker documentation. 

The Notary server runs by default. For information about how container developers use Docker Content Trust with vSphere Integrated Containers Registry, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md) in *Develop Container Applications with vSphere Integrated Containers*.

## Vulnerability Scanning <a id="vulnerability"></a>

vSphere Integrated Containers Registry provides the ability to scan all images for known vulnerabilities. DevOps and cloud dministrators can set threshold values that prevent users from running vulnerable images that exceed those thresholds. Once an image is uploaded into the registry, vSphere Integrated Containers Registry checks the various layers of the image against known vulnerability databases and reports issues to the DevOps and cloud administrators. 

## Garbage Collection <a id="gc"></a>

You can configure vSphere Integrated Containers Registry to perform garbage collection whenever you restart the registry service. If you implement garbage collection, the registry recycles the storage space that is consumed by images that you have deleted. For more information about garbage collection, see [Manage Repositories](../vic_cloud_admin/manage_repository_registry.md). See also [Garbage Collection](https://docs.docker.com/registry/garbage-collection/) in the Docker documentation.

## Logging <a id="logging"></a>

vSphere Integrated Containers Registry keeps a log of every operation that users perform in a project. The logs are fully searchable, to assist you with activity auditing. For information about project logs, see [Access Project Logs](../vic_cloud_admin/access_project_logs.md).

**Next topic**: [vSphere Integrated Containers Roles and Personas](roles_and_personas.md)
