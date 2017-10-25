# Restrict Access to the Docker API with Auto-Generated Certificates

As a convenience, `vic-machine create` provides the option of generating a client certificate, server certificate, and certificate authority (CA) as appropriate when you deploy a VCH. The generated certificates are functional, but they do not allow for fine control over aspects such as expiration, intermediate certificate authorities, and so on.

vSphere Integrated Containers Engine authenticates Docker API clients by using client certificates. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. A client certificate is accepted if it is signed by a CA that you provide by specifying one or more instances of the `--tls-ca` option. In the case of the certificates that `vic-machine create` generates, `vic-machine create` creates a CA and uses it to create and sign a single client certificate.

When using the Docker client, the client validates the server either by using CAs that are present in the root certificate bundle of the client system, or that are provided explicitly by using the `--tlscacert` option when running Docker commands. As a part of this validation, the server certificate must explicitly state at least one of the following, and must match the name or address that the client uses to access the server:

- The FQDN used to communicate with the server
- The IP address used to communicate with the server
- A wildcard domain that matches all of the FQDNs in a specific subdomain. For an example of a domain wildcard, see [https://en.wikipedia.org/wiki/Wildcard_certificate#Example](https://en.wikipedia.org/wiki/Wildcard_certificate#Example).

This topic includes the following sections.

- [`vic-machine `Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

### `--tls-cname` <a id="tls-cname"></a>

Short name: None

The FQDN or IP address to embed in an auto-generated server certificate. Specify an FQDN, IP address, or a domain wildcard. If you provide a custom server certificate by using the `--tls-server-cert` option, you can use `--tls-cname` as a sanity check to ensure that the certificate is valid for the deployment.

If you do not specify `--tls-cname` but you do set a static address for the VCH on the client network interface, `vic-machine create` uses that  address for the Common Name, with the same results as if you had specified `--tls-cname=x.x.x.x`. For information about setting a static IP address on the client network, see [Specify a Static IP Address for the VCH Endpoint VM](vch_static_ip.md).

When you specify the `--tls-cname` option, `vic-machine create` performs the following actions during the deployment of the VCH:

- Checks for an existing certificate in either a folder that has the same name as the VCH that you are deploying, or in a location that you specify in the [`--tls-cert-path`](#cert-path) option. If a valid certificate exists that includes the same Common Name attribute as the one that you specify in `--tls-cname`, `vic-machine create` reuses it. Reusing certificates allows you to delete and recreate VCHs for which you have already distributed the certificates to container developers.
- If certificates are present in the certificate folder that include a different Common Name attribute to the one that you specify in `--tls-cname`, `vic-machine create` fails.  
- If a certificate folder does not exist, `vic-machine create` creates a folder with the same name as the VCH, or creates a folder in the location that you specify in the `--tls-cert-path` option. 
- If valid certificates do not already exist, `vic-machine create` creates the following trusted CA, server, and client certificate/key pairs in the certificate folder:
  - `ca.pem`
  - `ca-key.pem`
  - `cert.pem`
  - `key.pem`
  - `server-cert.pem`
  - `server-key.pem`
- Creates a browser-friendly PFX client certificate, `cert.pfx`, to use to authenticate connections to the VCH Admin portal for the VCH.

**NOTE**: The folder and file permissions for the generated certificate and key are readable only by the user who created them.

Running `vic-machine create` with the `--tls-cname` option also creates an environment file named <code><i>vch_name</i>.env</code>, that contains Docker environment variables that container developers can use to configure their Docker client environment:

- Activates TLS client verification.<pre>DOCKER_TLS_VERIFY=1</pre>
- The path to the client certificates.<pre>DOCKER_CERT_PATH=<i>path_to_certs</i></pre>
- The address of the VCH.<pre>DOCKER_HOST=<i>vch_address</i>:2376</pre>

You must provide copies of the `cert.pem` and `key.pem` client certificate files and the environment file to container developers so that they can connect Docker clients to the VCH. If you deploy the VCH with the `--tls-cname` option, container developers must configure the client appropriately with one of the following options:
- By using the following `tlsverify`, `tlscert`, and `tlskey` Docker options, adding `tlscacert` if a custom CA was used to sign the server certificate.
- By setting `DOCKER_CERT_PATH=/path/to/client/cert.pem` and `DOCKER_TLS_VERIFY=1`.

<pre>--tls-cname vch-name.example.org</pre>
<pre>--tls-cname *.example.org</pre>

### `--tls-cert-path` <a id="cert-path"></a>

Short name: none

By default `--tls-cert-path` is a folder in the current directory, that takes its name from the VCH name that you specify in the `--name` option. `vic-machine create` checks in `--tls-cert-path` for existing certificates with the standard names and uses those certificates if they are present:
* `server-cert.pem` 
* `server-key.pem`
* `ca.pem`

If `vic-machine create` does not find existing certificates with the standard names in `--tls-cert-path`, or if you do not specify certificates directly by using the `--tls-server-cert`, `--tls-server-key`, and `--tls-ca` options, `vic-machine create` generates certificates. Generated certificates are saved in the `--tls-cert-path` folder with the standard names listed. `vic-machine create` additionally generates other certificates:
* `cert.pem` and `key.pem` for client certificates, if required.
* `ca-key.pem`, the private key for the certificate authority. 

<pre>--tls-cert-path '<i>path_to_certificate_folder</i>'
</pre>

### `--certificate-key-size` ###

Short name: `--ksz`

The size of the key for `vic-machine create` to use when it creates auto-generated trusted certificates. You can optionally use `--certificate-key-size` if you specify `--tls-cname`. If not specified, `vic-machine create` creates keys with default size of 2048 bits. It is not recommended to use key sizes of less than 2048 bits. 

<pre>--certificate-key-size 3072</pre>

### `--organization` ###

Short name: None

A list of identifiers to record in certificates generated by `vic-machine`. You can optionally use `--organization` if you specify `--tls-cname`. If not specified,`vic-machine create` uses the name of the VCH as the organization value.

**NOTE**: The `client-ip-address` is used for `CommonName` but not  for  `Organisation`.

<pre>--organization <i>organization_name</i></pre>

## Example `vic-machine` Command <a id="example"></a>

You can deploy a VCH that implements two-way authentication with trusted auto-generated TLS certificates that are signed by a CA. 

To automatically generate a server certificate that can pass client verification, you must specify the Common Name (CN) for the certificate by using the [`--tls-cname`](#tls-cname) option. The CN should be the FQDN or IP address of the server, or a domain with a wildcard. The CN value must match the name or address that clients will use to connect to the server. You can use the `--organization` option to add basic descriptive information to the server certificate. This information is visible to clients if they inspect the server certificate.

If you specify an existing CA file with which to validate clients, you must also provide an existing server certificate that is compatible with the `--tls-cname` value or the IP address of the client interface.

This example deploys a VCH with the following configuration:

- Specifies the user, password, datacenter, image store, cluster, bridge network, and name for the VCH.
- Provides a wildcard domain `*.example.org` as the FQDN for the VCH, for use as the Common Name in the certificate. This assumes that there is a DHCP server offering IP addresses on VM Network, and that those addresses have corresponding DNS entries such as `dhcp-a-b-c.example.com`.
- Specifies a folder in which to store the auto-generated certificates.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--tls-cname *.example.org
--tls-cert-path <i>path_to_cert_folder</i>
--thumbprint <i>certificate_thumbprint</i>
--name vch1
</pre>

The Docker API for this VCH will be accessible at `https://dhcp-a-b-c.example.com:2376`.