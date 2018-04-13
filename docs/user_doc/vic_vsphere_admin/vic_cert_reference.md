# vSphere Integrated Containers Certificate Reference #

vSphere Integrated Containers authenticates connections to its various components by using TLS certificates. In some cases, the certificates are always automatically generated and self-signed. In other cases, you have the option of providing custom certificates.

This topic provides a reference of all of the certificates that vSphere Integrated Containers uses.


|**Component**|**Certificate Type**|**Purpose**|**Used By**|
|---|---|---|---|
|vCenter Server or ESXi host|Self-signed or custom|Required for installation of the vSphere Client plug-ins and deployment and management of virtual container hosts (VCHs). See [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).|vSphere administrator|
|vSphere Integrated Containers Appliance|Self-signed or custom|Authenticates connections from browsers to vSphere Integrated Containers Management Portal, the Getting Started page, downloads of vSphere Integrated Containers Engine binaries, and the installation of vSphere Client plug-ins. If you use custom certificates, vSphere Integrated Containers Management Portal requires you to provide the TLS private key as an unencrypted PEM-encoded PKCS#1 or PKCS#8-formatted file. For information about how to obtain auto-generated appliance certificates, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).|vSphere administrator, Cloud and DevOps admininistrators, developers|
|vSphere Integrated Containers Registry|Self-signed|Authenticates connections to vSphere Integrated Containers Registry instances from Docker clients, replication of projects between registry instances, and registration of additional registry instances in the management portal. For information about how to obtain the registry certificate, see [Configure System Settings](../vic_cloud_admin/configure_system.md).|Cloud and DevOps admininistrators, developers|
|VCH|None, self-signed, or custom|Authenticates connections from Docker clients to VCHs. If you use custom certificates, `vic-machine` requires you to supply each X.509 certificate in a separate file, using PEM encoding. PKCS#7 is not supported. For information about how to convert certificates to PEM format, see [Converting Certificates for Use with vSphere Integrated Containers](#convertcerts). For general information about how `vic-machine` uses certificates, see [Virtual Container Host Security](vch_security.md).|vSphere administrator, Cloud and DevOps admininistrators, developers |
|VCH Administration Portal|None, self-signed, or custom|Authenticates connections from browsers to the administration portals of individual VCHs. See [VCH Administration Portal](access_vicadmin.md).|vSphere administrator|

## Converting Certificates for Use with vSphere Integrated Containers Engine <a id="convertcerts"></a>

To unwrap a PKCS#7 key for use with `vic-machine`, run the following command: <pre>$ openssl pkcs7 -print_certs -in <i>cert_name</i>.pem -out chain.pem</pre>



