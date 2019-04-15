# Provisioning Container VMs in the Management Portal #

You can provision containers or container VMs from the management portal depending on the target host. If your target host is a VCH, you provision container VMs. If your target host is a Docker host, you provision standard containers. 

You can customize your deployment by using the available settings. You can either provision your configured container or save it as a template. Saving the configuration as a template allows you deploy multiple containers with the same configuration. 

**IMPORTANT**: vSphere Integrated Containers Management Portal allows you to provision containers from the registries that are included in the lists of global registries that the Management Portal Administrator configures, or project registries that the DevOps administrator configures. However, if the vSphere administrator deployed a VCH with whitelist mode enabled, and if the whitelist on the VCH is more restrictive than the global and project registry lists, you can only provision containers from the registries that the VCH permits in its whitelist, even if the VCH is included in a project that permits other registries. For more information, see [VCH Whitelists and Registry Lists in vSphere Integrated Containers Management Portal](../vic_vsphere_admin/vch_registry.md#vch-whitelist-mp) in *vSphere Integrated Containers for vSphere Administrators*.

You can provision containers and create templates from images. 

**Procedure**

1. In the management portal, navigate to **Deployments** > **Containers** and click **+Container**.
2. On the Provision a Container page, configure the following settings:
    - Basic configuration
    - Network configuration
    - Storage configuration
    - Policy configuration
    - Environment configuration
    - Health configuration
    - Logging configuration
3. Click **PROVISION** to provision the container with the configured settings. Click **SAVE AS TEMPLATE** to save the configured container as a template. 

For information about the container configuration, see [Container Provisioning Options Reference](container_provisioning_options_reference.md)


