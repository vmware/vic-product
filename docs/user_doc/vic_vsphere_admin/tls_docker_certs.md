# About TLS Certificates and Docker #

- [About TLS Certificates](#about_tls)
- [Certificate Usage in Docker](#docker_certs)

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
- A wildcard domain that matches all of the FQDNs in a specific subdomain 

If the server certificate includes a wildcard domain, all of the systems in that domain can connect to the server. For an example of a domain wildcard, see [https://en.wikipedia.org/wiki/Wildcard_certificate#Example](https://en.wikipedia.org/wiki/Wildcard_certificate#Example).

Docker clients search for certificates in the `DOCKER_CERT_PATH` location on the system on which the Docker client is running. Docker requires certificate files to have the following names if they are to be  consumed automatically from `DOCKER_CERT_PATH`:

|**File Name**|**Description**|
|---|---|
|`cert.pem`, `key.pem`|Client certificate **(1)** and private key.|
|`server-cert.pem`, `server-key.pem`|Server certificate **(2)**|
|`ca.pem`|Public portion of the certificate authority that signed the server certificate **(3)**. Allows the server to confirm that a client is authorized.|