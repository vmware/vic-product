# Virtual Container Host Certificate Requirements #

Virtual container hosts (VCHs) authenticate connections from Docker API clients and vSphere Integrated Containers Management Portal by using server and client TLS certificates. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. 

- [Certificate Usage in Docker](#docker_certs)
  - [`DOCKER_CERT_PATH`](#dockercertpath)
- [Certificate Usage in VCHs](#vch_cert_use)
  - [Automatically Generated Certificates](#auto)
  - [Custom Certificates](#custom)
     - [Server Certificate](#servercert)
     - [Client Certificate](#clientcert) 
  - [Converting PKCS#7 Certificate Keys for Use with VCHs](#convertcerts)
- [VCH Administration Portal Certificate](#vch_admin)

## Certificate Usage in Docker <a id="docker_certs"></a>

There are four certificates in use in a Docker `tlsverify` configuration:

- **(1)** A client certificate, held by the Docker client.
- **(2)** A server certificate, held by the server, which in a VCH is the Docker API endpoint.
- **(3)** A certificate authority (CA), that signs the server certificate.
- **(4)** Another CA, that signs the client certificate and is held by the server.

When using the Docker client, the client validates the server either by using CAs that are present in the root certificate bundle of the client system, or that container developers provide explicitly by using the `--tlscacert` option when they run Docker commands. As a part of this validation, the Common Name (CN) in the server certificate must match the name or address of the system from which the Docker client accesses the server. The server certificate must explicitly state at least one of the following in the CN:

- The FQDN of the system from which the Docker client communicates with the server
- The IP address of the system from which the Docker client communicates  with the server
- A wildcard domain that matches all of the FQDNs in a specific subdomain. 

If the server certificate includes a wildcard domain, all of the systems in that domain can connect to the server. For an example of a domain wildcard, see [https://en.wikipedia.org/wiki/Wildcard_certificate#Example](https://en.wikipedia.org/wiki/Wildcard_certificate#Example).

### `DOCKER_CERT_PATH` <a id="dockercertpath"></a>

Docker clients search for certificates in the `DOCKER_CERT_PATH` location on the system on which the Docker client is running. Docker requires certificate files to have the following names if they are to be  consumed automatically from `DOCKER_CERT_PATH`:

|**File Name**|**Description**|
|---|---|
|`cert.pem`, `key.pem`|Client certificate **(1)** and private key.|
|`server-cert.pem`, `server-key.pem`|Server certificate **(2)**|
|`ca.pem`|Public portion of the certificate authority that signed the server certificate **(3)**. Allows the server to confirm that a client is authorized.|

## Certificate Usage in VCHs <a id="vch_cert_use"></a>

As a convenience, vSphere Integrated Containers Engine can optionally generate client **(1)** and server **(2)** certificates. It can also  automatically generate one CA that serves as both **(3)** and **(4)**. If you use an automatically generated CA, vSphere Integrated Containers Engine uses that CA to sign both of the client and server certificates. This means that you must provide the `cert.pem`, `key.pem`, and `ca.pem` client certificate files to all container developers who need to connect Docker clients to the VCHs. You must also provide the client certificate files to vSphere Integrated Containers Management Portal if you register the VCH in a project.

Rather than using an automatically generated CA, in a production deployment you would normally use custom CAs. In this case:

- **(3)** is usually signed by a company certificate that is rooted by a public or corporate trust authority, for example Verisign. 
- **(4)** can be unique per client or group of clients. Using the same CA for a group of clients allows each client to have a unique certificate, but allows the group to be authorized as a whole. For example, you could use one CA per VCH, multiple CAs per VCH, or one CA per group of VCHs.

When you deploy a VCH, you must specify the level of security that applies to connections from Docker clients to the Docker API endpoint in the VCH, and whether to use automatically generated or custom certificates, or a combination of both. 

This diagram shows how VCHs use certificates to authenticate connections between the different components. The diagram shows a deployment in which verification of client certificates is enabled on virtual container hosts (VCHs).

![vSphere Integrated Containers Appliance Certificates](graphics/vch_certs.png)

### Automatically Generated Certificates <a id="auto"></a>

vSphere Integrated Containers Engine provides the option of automatically generating a server certificate for the Docker API endpoint in the VCH. The generated certificates are functional, but they do not allow for fine control over aspects such as expiration, intermediate certificate authorities, and so on. To use more finely configured certificates, use custom server certificates.

VCHs accept client certificates if they are signed by a CA that you  can optionally provide to the VCH. Alternatively, you can configure a VCH so that vSphere Integrated Containers Engine creates a Certificate Authority (CA) certificate that it uses to automatically generate and sign a single client certificate. If you use the options to automatically generate a client certificate, you must distribute the automatically generated certificate to container developers so that they can configure their Docker clients to connect to the VCH. For information about how to provide client certificates to Docker clients, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

**NOTE**: The Create Virtual Container Host wizard in the vSphere Client does not support automatically generated CA or client certificates. To use automatically generated CA and client certificates, you must use the `vic-machine` CLI utility to create the VCH.

### Custom Certificates <a id="custom"></a>

To exercise fine control over the certificates that VCHs use, you must obtain or generate custom certificates yourself before you deploy a VCH. You can create a VCH that uses a custom server certificate, for example a server certificate that has been signed by Verisign or another public root. For information about how to create custom certificates for use with Docker, see [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/) in the Docker documentation. 

You can deploy a VCH to use custom certificates in combination with auto-generated certificates, as demonstrated in the VCH security [Examples](vch_cert_options.md#examples). 

The table below shows the certificate formats that VCHs support, and the required components.

|**Certificate Format**|**Required Components**|
|---|---|
|pksc#12|End-entity (leaf) certificate, CA chain certificate, private key in PKCS#8 format|
|PKCS#7|End-entity certificate, private key in PKCS#8 format|
|RSA/PKCS#1|Private key in PKCS#8 format|

**IMPORTANT**: PKCS#7 certificate keys do not work with `vic-machine`. For information about how to convert certificates to the correct format, see [Converting PKCS#7 Certificates for Use with VCHs](vic_cert_reqs.md#convertcerts).

#### Server Certificate <a id="servercert"></a>

- You must use an X.509 server certificate.
- Server certificates must have the following certificate usages:
  - `KeyEncipherment`
  - `DigitalSignature`
  - `KeyAgreement`
  - `ServerAuth`
- Server keys must not be encrypted. 

#### Client Certificate <a id="clientcert"></a>

For the VCH to trust the CA that you use to sign the client certificate, the CA must include the following elements:

- The name or address of the system from which the Docker client accesses the server in the subject or subject alternative name. This can be an FQDN or a wildcard domain.
- Key usage in the v3 extensions that match the key usage chosen for the VCH server certificate:
  - `KeyEncipherment`
  - `KeyAgreement`

### Converting PKCS#7 Certificate Keys for Use with VCHs <a id="convertcerts"></a>

VCHs do not support PKCS#7 certificate keys. You must convert PCKS#7 keys to PKCS#8 format before you can use them with VCHs.

To unwrap a PKCS#7 key for use with a VCH, run the following command: <pre>$ openssl pkcs7 -print_certs -in <i>cert_name</i>.pem -out chain.pem</pre>

## VCH Administration Portal Certificate <a id="vch_admin"></a>

- **Type**: None, self-signed, or custom
- **Format**: `*.pfx`
- **Used by**: vSphere administrators

If you deploy a VCH with client and server authentication, vSphere Integrated Containers Engine generates a *.pfx certificate that you can use to authenticate connections to with the VCH Admin portal. See [VCH Administration Portal](access_vicadmin.md).