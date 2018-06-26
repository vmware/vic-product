# Enabling Content Trust in Projects #

vSphere Integrated Containers Registry provides a Docker Notary server that allows you to implement content trust by signing and verifying the images in the registry. 

Content trust is enabled at the project level. If content trust is enabled on a project, users can only push and pull images to and from that project if they are signed and verified by the Notary server. 

Enabling content trust on a project automatically modifies the registry whitelist settings of any virtual container hosts (VCHs) that are registered with the project. Consequently, when content trust is enabled, the VCHs in the project can only pull signed and verified images from the registry instance that is running in the vSphere Integrated Containers appliance. 

If you enable content trust on a project, the developers who work on that project must configure their Docker clients so that they can connect to the Notary server running in vSphere Integrated Containers Registry. 

- For general information about content trust, see [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/) in the Docker documentation.
- For information about how to enable content trust on a project, see [Configure Project Settings](manage_projects.md).
- For information about how enabling content trust affects VCHs, see [VCH Whitelists and Content Trust](../vic_vsphere_admin/vch_registry.md#vch-content-trust) in *vSphere Integrated Containers for vSphere Administrators*.
- For information about how to configure Docker clients for content trust, see the section on [Using vSphere Integrated Containers Registry with Content Trust](../vic_app_dev/configure_docker_client.md#notary) in *Developing Applications with vSphere Integrated Containers*.