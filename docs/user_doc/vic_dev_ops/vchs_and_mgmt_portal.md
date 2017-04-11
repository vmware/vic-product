# View and Manage VCHs, Add Registries, and Provision Containers Through the Management Portal #

You can view live stats and manage the hosts in your environment after you add your existing VCHs to the management portal. Connect each VCH by using an authentication method and protocol, per the security flavor that you deployed the host with.
- For hosts with no TLS authentication, connect over HTTP with no credentials.
- For hosts with only server-side TLS authentication, connect over HTTPS with no credentials.
- For hosts with full TLS authentication, connect over HTTPS by using a client certificate.

Use registries to store and distribute images. You can configure multiple registries to gain access to both public and private images. You must manually add Harbor as a registry. JFrog Artifactory is also supported.

- [Add Hosts with Server-Side TLS Authentication to the Management Portal](vic_dev_ops/add_vch_serversideTLS_in_portal.md)
- [Add Hosts with Full TLS Authentication to the Management Portal](vic_dev_ops/add_vch_fullTLS_in_portal.md)
- [Add Registries to the Management Portal](vic_dev_ops/add_repos_in_portal.md)
- [Provision Container VMs in the vSphere Integrated Containers Management Portal](vic_dev_ops/provision_containers_portal.md)
- [Manage Container VMs in the vSphere Integrated Containers Management Portal](vic_dev_ops/manage_containers_portal.md)