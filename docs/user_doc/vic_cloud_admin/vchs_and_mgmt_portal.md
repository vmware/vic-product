# Add Container Hosts to Projects #

You can provision containers, view live stats, and manage the hosts in your environment after you add existing Docker hosts or vSphere Integrated Containers virtual container hosts (VCHs) to projects.

**IMPORTANT**: vSphere Integrated Containers Management Portal allows you to provision containers from the registries that are included in the lists of global registries that the Management Portal Administrator configures, or from project registry lists that the DevOps administrator configures. However, if the vSphere administrator deployed a VCH with whitelist mode enabled, and if the whitelist on the VCH is more restrictive than the global and project registry lists, you can only provision containers from the registries that the VCH permits in its whitelist, even if the VCH is included in a project that permits other registries. Also, if you add a VCH to a project on which content trust is enabled, vSphere Integrated Containers updates the whitelist configuration of the VCH. As a consequence, you should only add a given VCH to one project at a time. Adding the same VCH to multiple projects can lead to conflicts if the registry lists and content trust setttings are different in the different projects.

- For information about global and project registry lists, see [Working with Registries](working_with_registries.md).
- For information about the impact of registry lists on VCHs, see [VCH Whitelists and Registry Lists in vSphere Integrated Containers Management Portal](../vic_vsphere_admin/vch_registry.md#vch-whitelist-mp) in *vSphere Integrated Containers for vSphere Administrators*.
- For information about content trust, see [Enabling Content Trust in Projects](content_trust.md).
- For information about how enabling content trust affects VCHs, see [VCH Whitelists and Content Trust](../vic_vsphere_admin/vch_registry.md#vch-content-trust) in *vSphere Integrated Containers for vSphere Administrators*. 

You add hosts to projects according to the security flavor that they are deployed with. 

- [Add Container Hosts with Full TLS Authentication](add_vch_fullTLS_in_portal.md)
- [Add Container Hosts with Server-Side TLS Authentication](add_vch_serversideTLS_in_portal.md)
- [Add Container Hosts with No TLS Authentication](add_vch_noTLS_in_portal.md)