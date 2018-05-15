# Add VCHs in vSphere Integrated Containers Management Portal #

You can provision containers, view live stats, and manage the hosts in your environment after you add existing Docker hosts or vSphere Integrated Containers virtual container hosts (VCHs) to projects. You can add the same VCH to multiple projects.

**NOTE**: vSphere Integrated Containers Management Portal allows you to provision containers from the registries that are included in the lists of   global registries that the cloud administrator configures, or project registries that the DevOps administrator configures. However, if the vSphere administrator deployed a VCH with whitelist mode enabled, and if the whitelist on the VCH is more restrictive than the global and project registry lists, you can only provision containers from the registries that the VCH permits in its whitelist, even if the VCH is included in a project that permits other registries. For more information, see [VCH Whitelists and Registry Lists in vSphere Integrated Containers Management Portal](../vic_vsphere_admin/vch_registry.md#vch-whitelist-mp) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.

You add VCHs to projects according to the security flavor that you deployed the host with. 

- [Add Virtual Container Hosts with Full TLS Authentication to the Management Portal](add_vch_fullTLS_in_portal.md)
- [Add Virtual Container Hosts with Server-Side TLS Authentication to the Management Portal](add_vch_serversideTLS_in_portal.md)
- [Add Virtual Container Hosts with No TLS Authentication to the Management Portal](add_vch_noTLS_in_portal.md)