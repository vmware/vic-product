# Virtual Container Host Security #

By default, virtual container hosts (VCHs) authenticate connections from Docker API clients by using server and client TLS certificates. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. 

- [About TLS Certificates](#about_tls)
- [Certificate Usage in Docker](#docker_certs)
  - [`DOCKER_CERT_PATH`](#dockercertpath)
- [Virtual Container Host Security Options](#vch_tlsoptions)
  - [Supported Configurations](#configs)
- [Registry Access](#registry) 

## About TLS Certificates <a id="about_tls"></a>

A certificate is made up of two parts:

- A public certificate part, that is distributed to anyone who needs it
- A private key part, that is kept secret

Paired certificate and key files follow general naming conventions:

- `cert.pem` and `key.pem`
- `<prefix>.pem` and `<prefix>-key.pem`
- `<prefix>-cert.pem` and `<prefix>-key.pem`

For general information about TLS certificates, see https://en.wikipedia.org/wiki/Transport_Layer_Security.

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
|`cert.pem`, `key.pem`|Client certificate **(1)** and private key. client certificate.|
|`server-cert.pem`, `server-key.pem`|Server certificate **(2)**|
|`ca.pem`|Public portion of the certificate authority that signed the server certificate **(3)**. Allows the server to confirm that a client is authorized.|

For information about how to provide certificates to Docker clients, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

## Virtual Container Host Security Options <a id="vch_tlsoptions"></a>

As a convenience, vSphere Integrated Containers Engine can optionally generate client **(1)** and server **(2)** certificates. It can also  automatically generate one CA that serves as both **(3)** and **(4)**. If you use an automatically generated CA, vSphere Integrated Containers Engine uses that CA to sign both of the client and server certificates. This means that you must provide to the Docker client both the client certificate and the public part of the CA, so that the client can trust the server. You must provide a client certificate and CA for every VCH that a Docker client connects to.

Rather than using an automatically generated CA, in a production deployment you would normally use custom CAs. In this case:

- **(3)** is usually signed by a company certificate that is rooted by a public or corporate trust authority, for example Verisign. 
- **(4)** can be unique per client or group of clients. Using the same CA for a group of clients allows each client to have a unique certificate, but allows the group to be authorized as a whole. For example, you could use one CA per VCH, multiple CAs per VCH, or one CA per group of VCHs.

When you deploy a VCH, you must specify the level of security that applies to connections from Docker clients to the Docker API endpoint in the VCH, and whether to use automatically generated or custom certificates, or a combination of both. 
 
### Supported Configurations <a id="configs"></a>

You can use all automatically generated certificates, all custom certificates, or a combination of both. 

**NOTE**: The Create Virtual Container Host wizard in the vSphere Client does not support automatically generated CA or client certificates. To use automatically generated CA and client certificates, you must use the `vic-machine` CLI utility to deploy VCHs.

The following table provides a summary of the configurations that vSphere Integrated Containers Engine supports, and whether you can implement those configurations in the Create Virtual Container Host wizard in the vSphere Client.

|**Configuration**|**Available in vSphere Client?**|**Examples**|
|---|---|
|Auto-generated server certificate + auto-generated CA + auto-generated client certificate|No|[Example](vch_cert_options.md#full-auto)|
|Auto-generated server certificate + custom CA + custom client certificate|Yes|[Example](vch_cert_options.md#auto-server)|
|Auto-generated server certificate + custom CA + auto-generated client certificate|No|[Example](vch_cert_options.md#auto-server-client-custom-ca)|
|Custom server certificate + custom CA + custom client certificate|Yes|[Example](vch_cert_options.md#all-custom)|
|Custom server certificate + custom CA + auto-generated client certificate|No|[Example](vch_cert_options.md#custom-server-ca)|
|Custom server certificate + auto-generated CA + auto-generated client certificate|No|[Example](vch_cert_options.md#custom-server-auto-client-ca)|
|Auto-generated server certificate + no client verification|Yes|[Example](tls_unrestricted.md#)|
|Custom server certificate + no client verification|Yes|[Example](tls_unrestricted.md#)|
|No server or client certificate verification|Yes|[Example](tls_unrestricted.md#)|

The following topics describe how to achieve all of the configurations listed in the table above, by using either the Create Virtual Container Host wizard or the `vic-machine` CLI, or both. The Examples column provides direct links to the relevant example in those topics for each configuration.

- [Virtual Container Host Certificate Options](vch_cert_options.md)
- [Disable Certificate Authentication](tls_unrestricted.md)

## Registry Access <a id="registry"></a>

In addition to configuring the level of security to apply to connections from Docker clients to VCHs, you must also configure the level of security to apply to connections from VCHs to registry servers. For example, to use vSphere Integrated Containers Registry, you must configure VCHs accordingly when you deploy them. 

For information about configuring VCHs to use registry servers, see [Configure Registry Access](vch_registry.md).