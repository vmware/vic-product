# Provisioning Container VMs in the Management Portal #

You can provision containers or container VMs from the management portal depending on the target host. If your target host is a VCH, you provision container VMs. If your target host is a Docker host, you provision standard containers. 

You can customize your deployment by using the available settings. You can either provision your configured container or save it as a template. Saving the configuration as a template allows you deploy identical container VMs. 

**IMPORTANT**: vSphere Integrated Containers Management Portal allows you to provision containers from the registries that are included in the lists of global registries that the Management Portal Administrator configures, or project registries that the DevOps administrator configures. However, if the vSphere administrator deployed a VCH with whitelist mode enabled, and if the whitelist on the VCH is more restrictive than the global and project registry lists, you can only provision containers from the registries that the VCH permits in its whitelist, even if the VCH is included in a project that permits other registries. For more information, see [VCH Whitelists and Registry Lists in vSphere Integrated Containers Management Portal](../vic_vsphere_admin/vch_registry.md#vch-whitelist-mp) in *vSphere Integrated Containers for vSphere Administrators*.

You can provision containers, templates, or images. 

When you create containers from the Containers page in the management portal, you can configure the following settings:

- [Basic configuration](container_basic.md)
- [Network configuration](container_network.md)
- [Storage configuration](container_storage.md)
- [Policy configuration](container_policy.md)
- [Environment configuration](container_environment.md)
- [Health configuration](container_healthconfig.md)
- [Logging configuration](container_logconfig.md)

**Related topics**

- [Configuring Links](configuring_links.md)
- [Provisioning Container Volumes Using Templates](provisioning_volumes_templates.md)
- [Configuring Health Checks](configuring_health_checks.md)
- [Configuring Cluster Size and Scale](configuring_clusters.md)
