# Virtual Container Host Certificate Requirements #

Virtual container hosts (VCHs) authenticate connections from Docker API clients and vSphere Integrated Containers Management Portal by using server and client TLS certificates. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. 

**IMPORTANT**: The certificate requirements for VCHs and for the vSphere Integrated Containers appliance are different. For information about how the appliance uses certificates, see [vSphere Integrated Containers Appliance Certificate Requirements](appliance_cert_reqs.md).

- [Certificate Usage in VCHs](#vch_cert_use)
  - [Automatically Generated Certificates](#auto)
     - [Automatically Generated Server Certificate](#auto-servercert)
     - [Automatically Generated Client Certificate](#auto-clientcert)
  - [Custom Certificates](#custom)
     - [Custom Server Certificate](#servercert)
     - [Custom Client Certificate](#clientcert) 
  - [Converting PKCS#7 Certificate Keys for Use with VCHs](#convertcerts)
- [VCH Administration Portal Certificate](#vch_admin)

## Certificate Usage in VCHs <a id="vch_cert_use"></a>

When you deploy a VCH, you specify the level of security to apply to connections from Docker clients or vSphere Integrated Containers Management Portal to the Docker API endpoint in the VCH. You can set the following  levels of security:

|**Option**|**Security Level**|**Encrypted Communication**|
|---|---|---|
|Client-server authentication|Only verified clients can connect to VCH|Yes|
|Server authentication|Any client can connect to VCH|Yes|
|No authentication|Insecure|No|

As a convenience, vSphere Integrated Containers Engine can optionally generate client **(1)** and server **(2)** certificates. It can also  automatically generate one CA that signs both the server certificate **(3)** and signs the client certificate **(4)**. If you use an automatically generated CA, vSphere Integrated Containers Engine uses that CA to sign both of the client and server certificates. This means that you must provide the `cert.pem`, `key.pem`, and `ca.pem` client certificate files to all container developers who need to connect Docker clients to the VCHs. If the VCH implements client authentication, you must also provide the contents of client certificate files to vSphere Integrated Containers Management Portal if you register the VCH in a project. 

Rather than using an automatically generated CA, in a production deployment you would normally use custom CAs. In this case:

- The CA that signs the server certificate **(3)** is usually signed by a company certificate that is rooted by a public or corporate trust authority, for example Verisign. 
- The CA that signs the client certificate **(4)** can be unique per client or group of clients. Using the same CA for a group of clients allows each client to have a unique certificate, but allows the group to be authorized as a whole. For example, you could use one CA per VCH, multiple CAs per VCH, or one CA per group of VCHs.

This diagram shows how VCHs use certificates to authenticate connections between the different components in a vSphere Integrated Containers environment. The diagram shows a deployment in which verification of client certificates is enabled on virtual container hosts (VCHs).

![vSphere Integrated Containers Appliance Certificates](graphics/vch_certs.png)

If you implement client authentication, you must distribute the client certificate to container developers or DevOps administrators so that they can configure their Docker clients and vSphere Integrated Containers Management Portal to connect to the VCH. 

- For information about how to provide client certificates to Docker clients, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).
- For information about how to provide client certificates to vSphere Integrated Containers Management Portal, see [Add Container Hosts with Full TLS Authentication](../vic_cloud_admin/add_vch_fullTLS_in_portal.md) in *vSphere Integrated Containers Management Portal Administration*.

### Automatically Generated Certificates <a id="auto"></a>

vSphere Integrated Containers Engine provides the option of automatically generating server and client certificates.

### Custom Certificates <a id="custom"></a>

To exercise fine control over the certificates that VCHs use, you must obtain or generate custom certificates yourself before you deploy a VCH. You can create a VCH that uses a custom server certificate, for example a server certificate that has been signed by Verisign or another public root. For information about how to create custom certificates for use with Docker, see [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/) in the Docker documentation. 

You can deploy a VCH to use custom certificates in combination with auto-generated certificates, as demonstrated in the VCH security [Examples](vch_cert_options.md#examples). 

The table below shows the certificate formats that VCHs support, and the required components.

|**Certificate Format**|**Required Components**|
|---|---|
|PKCS#12|End-entity (leaf) certificate, CA chain certificate, private key in PKCS#8 format|
|PKCS#7|End-entity certificate, private key in PKCS#8 format|
|RSA/PKCS#1|Private key in PKCS#8 format|

**IMPORTANT**: PKCS#7 certificate keys do not work with `vic-machine`. For information about how to convert certificate keys to the correct format, see [Converting PKCS#7 Certificates for Use with VCHs](appliance_cert_reqs.md#convertcerts).

### Converting PKCS#7 Certificate Keys for Use with VCHs <a id="convertcerts"></a>

VCHs do not support PKCS#7 certificate keys. You must convert PCKS#7 keys to PKCS#8 format before you can use them with VCHs.

To unwrap a PKCS#7 key for use with a VCH, run the following command: <pre>$ openssl pkcs7 -print_certs -in <i>cert_name</i>.pem -out chain.pem</pre>

## VCH Server Certificate 

#### Automatically Generated Server Certificate <a id="auto-servercert"></a>

You can automatically generate a server certificate for the Docker API endpoint in the VCH. The generated certificates are functional, but they do not allow for fine control over aspects such as expiration, intermediate certificate authorities, and so on. To use more finely configured certificates, use custom server certificates. 

You can download the automatically generated server certificate for a VCH from the vSphere Client. For information about downloading server certificates, see [View All VCH and Container Information in the HTML5 vSphere Client](access_h5_ui.md).

#### Custom Server Certificate <a id="servercert"></a>

Custom server certificates for VCHs must meet the following requirements:

- You must use an X.509 server certificate.
- The Common Name (CN) in the server certificate must match the FQDN or  IP address of the system from which the Docker client accesses the server, or a wildcard domain that matches all of the FQDNs in a specific subdomain.
- Server certificates must have the following certificate usages:
  - `KeyEncipherment`
  - `DigitalSignature`
  - `KeyAgreement`
  - `ServerAuth`
- Server keys must not be encrypted. 

If you use certificates that are not signed by a trusted certificate authority, container developers might require the server certificate when they run Docker commands in `--tlsverify` client mode. You can download the server certificate for a VCH from the vSphere Client. For information about downloading server certificates, see [View All VCH and Container Information in the HTML5 vSphere Client](access_h5_ui.md).

## VCH Client Certificate

### Automatically Generated Client Certificate <a id="auto-clientcert"></a>

VCHs accept client certificates if they are signed by a CA. You can optionally provide a custom CA to the VCH. Alternatively, you can configure a VCH so that vSphere Integrated Containers Engine creates an automatically generated CA. vSphere Integrated Containers Engine uses the CA to automatically generate and sign a single client certificate. 

**NOTE**: The Create Virtual Container Host wizard in the vSphere Client does not support automatically generated CA or client certificates. To use automatically generated CA and client certificates, you must use the `vic-machine` CLI utility to create the VCH.

### Custom Client Certificate <a id="clientcert"></a>

For the VCH to trust the CA that you use to sign the client certificate, the CA must include the following elements:

- The name or address of the system from which the Docker client accesses the server in the subject or subject alternative name. This can be an FQDN or a wildcard domain.
- Key usage in the v3 extensions that match the key usage chosen for the VCH server certificate:
  - `KeyEncipherment`
  - `KeyAgreement`

You cannot download client certificates for VCHs from the vSphere Client. vSphere administrators distribute client certificates directly.

## VCH Administration Portal Certificate <a id="vch_admin"></a>

- **Type**: None, self-signed, or custom
- **Format**: `*.pfx`
- **Used by**: vSphere administrators

If you deploy a VCH with client and server authentication, vSphere Integrated Containers Engine generates a *.pfx certificate that you can use to authenticate connections to with the VCH Admin portal. See [VCH Administration Portal](access_vicadmin.md).