# vSphere Integrated Containers Certificate Reference #

vSphere Integrated Containers authenticates connections to its various components by using TLS certificates. In some cases, the certificates are always automatically generated and self-signed. In other cases, you have the option of providing custom certificates.

This topic provides a reference of all of the certificates that vSphere Integrated Containers uses.


|**Component**|**Certificate Type**|**Purpose**|**Used By**|
|---|---|---|---|
|vCenter Server or ESXi host|Self-signed or custom|Required for installation of the vSphere Client plug-ins and deployment and management of virtual container hosts (VCHs). See [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md).|vSphere administrator|
|vSphere Integrated Containers Management Portal|Self-signed or custom|Authenticates connections from browsers to vSphere Integrated Containers Management Portal. See [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).|Cloud and DevOps admininistrators, developers|
|vSphere Integrated Containers Registry|Self-signed|Authenticates connections to vSphere Integrated Containers Registry instances from Docker clients, replication of projects between registry instances, and registration of additional registry instances in the management portal. See [Configure System Settings](../vic_cloud_admin/configure_system.md).|Cloud and DevOps admininistrators, developers|
|vSphere Integrated Containers file server|Self-signed or custom|Authenticates connections to the Getting Started page, downloads of vSphere Integrated Containers Engine binaries, and the installation of vSphere Client plug-ins. See [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).|vSphere administrator, Cloud and DevOps admininistrators, developers|
|VCHs|None, self-signed, or custom|Authenticates connections from Docker clients to VCHs. See [VCH Deployment Options](vch_installer_options.md#security).|vSphere administrator, Cloud and DevOps admininistrators, developers |
|VCH Administration Portal|None, self-signed, or custom|Authenticates connections from browsers to the administration portals of individual VCHs. See [VCH Administration Portal](access_vicadmin.md).|vSphere administrator|


