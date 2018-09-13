# vSphere Integrated Containers Certificate Reference #

vSphere Integrated Containers authenticates connections to its various components by using TLS certificates. In some cases, the certificates are always automatically generated and self-signed. In other cases, you have the option of providing custom certificates.

This topic provides a reference of all of the certificates that vSphere Integrated Containers uses.


|**Component**|**Certificate Type**|**Purpose**|**Used By**|
|---|---|---|---|
|vCenter Server or ESXi host|Self-signed or custom|Required for installation of the vSphere Client plug-ins and deployment and management of virtual container hosts (VCHs). See [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).|vSphere administrator|
|vSphere Integrated Containers Appliance|Self-signed or custom|Authenticates connections from browsers to vSphere Integrated Containers Management Portal, the appliance welcome page, downloads of vSphere Integrated Containers Engine binaries, and the installation of vSphere Client plug-ins. If you use custom certificates, vSphere Integrated Containers Management Portal requires you to provide the TLS private key as an unencrypted PEM-encoded PKCS#1 or PKCS#8-formatted file. <br />For information about how to use certificates with intermediate CAs, see [Use a Certificate with an Intermediate CA for the vSphere Integrated Containers Appliance](#intermediateca).<br />For information about how to obtain auto-generated appliance certificates, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).|vSphere administrator, Management Portal administrators, and DevOps admininistrators, developers|
|vSphere Integrated Containers Registry|Self-signed|Authenticates connections to vSphere Integrated Containers Registry instances from Docker clients, replication of projects between registry instances, and registration of additional registry instances in the management portal. For information about how to obtain the registry certificate, see [Configure System Settings](../vic_cloud_admin/configure_system.md).|Management Portal administrators and DevOps admininistrators, developers|
|VCH|None, self-signed, or custom|Authenticates connections from Docker clients to VCHs. If you use custom certificates, `vic-machine` requires you to supply each X.509 certificate in a separate file, using PEM encoding. PKCS#7 is not supported. For information about how to convert certificates to PEM format, see [Converting Certificates for Use with vSphere Integrated Containers](#convertcerts). For general information about how `vic-machine` uses certificates, see [Virtual Container Host Security](vch_security.md).|vSphere administrator, Management Portal administrators, and DevOps admininistrators, developers |
|VCH Administration Portal|None, self-signed, or custom|Authenticates connections from browsers to the administration portals of individual VCHs. See [VCH Administration Portal](access_vicadmin.md).|vSphere administrator|

## Converting Certificates for Use with vSphere Integrated Containers Engine <a id="convertcerts"></a>

To unwrap a PKCS#7 key for use with `vic-machine`, run the following command: <pre>$ openssl pkcs7 -print_certs -in <i>cert_name</i>.pem -out chain.pem</pre>

## Use a Certificate with an Intermediate CA for the vSphere Integrated Containers Appliance <a id="intermediateca"></a>

When you deploy the vSphere Integrated Containers appliance, you can  specify a certificate with an intermediate certificate authority (CA) as the appliance certificate. 

**Procedure**

1. Create a certificate chain PEM file, that goes all the way down to the root CA.
2. Follow the instructions in [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md) to start the deployment of the appliance.
3. At the Customize Template page of the deployment wizard, paste the contents of the certificate chain PEM file into the **Appliance TLS Certificate** text box. 

    A certificate with an intermediate CA looks something like this:

    ```
    -----BEGIN CERTIFICATE-----
    <VIC appliance server certificate>
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    <intermediate CA certificate>
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    <root certificate>
    -----END CERTIFICATE-----
    ```
4. Paste the contents of the unencrypted PEM encoded PKCS1 or PKCS8 format private key into the **Appliance TLS Certificate Key** text box.
5. Paste the contents of the root CA certificate into the **Certificate Authority Certificate** text box.
6. Continue with the procedure in [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md#step4).