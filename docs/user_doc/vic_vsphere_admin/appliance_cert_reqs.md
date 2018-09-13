# vSphere Integrated Containers Appliance Certificate Requirements #

vSphere Integrated Containers authenticates connections between its various components by using TLS certificates. In some cases, the certificates are always automatically generated and self-signed. In other cases, you have the option of providing custom certificates. 

**IMPORTANT**: The certificate requirements for the appliance and for virtual container hosts (VCHs) are different. For information about how VCHs use certificates, see [Virtual Container Host Certificate Requirements](vch_cert_reqs.md). 

- [Overview of vSphere Integrated Containers Certificate Use](#overview)
- [vCenter Server or ESXi Host Certificate](#vcenter)
- [vSphere Integrated Containers Appliance Certificate](#appliance)
- [vSphere Integrated Containers Registry Root CA](#registry)

## Overview of vSphere Integrated Containers Appliance Certificate Use <a id="overview"></a>

This diagram shows how the vSphere Integrated Containers appliance uses certificates to authenticate connections between the different components. The diagram shows a deployment in which verification of client certificates is enabled on virtual container hosts (VCHs).

![vSphere Integrated Containers Appliance Certificates](graphics/appliance_certs.png)

### Custom Certificates <a id="customcerts"></a>

If you intend to use a custom certificate, the vSphere Integrated Containers appliance supports PEM encoded PKCS#1 and PEM encoded PKCS#8 formats for TLS private keys. If you provide a PKCS#1 format certificate, vSphere Integrated Containers converts it to PKCS8 format. The appliance uses a single TLS certificate for all of the services that run in the appliance.

## vCenter Server or ESXi Host Certificate <a id="vcenter"></a>

- **Type**: Self-signed or custom
- **Format**: See [vSphere Security Certificates](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.psc.doc/GUID-779A011D-B2DD-49BE-B0B9-6D73ECF99864.html) in the vSphere documentation
- **Used by**: vSphere administrator

Required for installation of the vSphere Client plug-ins and deployment and management of virtual container hosts (VCHs). See [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

## vSphere Integrated Containers Appliance Certificate <a id="appliance"></a>

- **Type**: Self-signed or custom
- **Format**: Supports unencrypted PEM encoded PKCS#1 and unencrypted PEM encoded PKCS#8 formats for TLS private keys. If you provide a PKCS#1 format certificate, vSphere Integrated Containers converts it to PKCS#8 format.
- **Used by**: vSphere administrator, Management Portal administrators,  DevOps admininistrators, developers

Authenticates connections from browsers to vSphere Integrated Containers Management Portal, the Getting Started page, downloads of vSphere Integrated Containers Engine binaries, and the installation of vSphere Client plug-ins. Also authenticates the Management Portal, Registry, and file server connections with vCenter Server during initialization of the appliance.

To use a certificate that uses a chain of intermediate CAs, create a certificate chain PEM file that includes a chain of the intermediate CAs all the way down to the root CA.

For information about where to obtain auto-generated appliance certificates after deployment, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).