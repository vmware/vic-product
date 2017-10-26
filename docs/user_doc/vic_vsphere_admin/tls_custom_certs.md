# Restrict Access to the Docker API with Custom Certificates <a id="restrict_custom"></a>

To exercise fine control over the certificates that VCHs use, obtain or generate custom certificates yourself before you deploy a VCH. For information about how to create custom certificates for use with Docker, see [Protect the Docker daemon socket](https://docs.docker.com/engine/security/https/) in the Docker documentation. 

When you have created or obtained custom certificates, you use the `--tls-server-key`, `--tls-server-cert`, and `--tls-ca` options to pass the custom certificates to `vic-machine create`.

**IMPORTANT**: PKCS#7 certificates do not work with `vic-machine`. For information about how to convert certificates to the correct format, see [Converting Certificates for Use with vSphere Integrated Containers Engine](vic_cert_reference.md#convertcerts). 

- [`vic-machine `Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

### `--tls-server-cert` <a id="cert"></a>

Short name: none

The path to a custom X.509 server certificate. This certificate identifies the VCH endpoint VM both to Docker clients and to browsers that connect to the VCH Admin portal.

- This certificate should have the following certificate usages:
  - `KeyEncipherment`
  - `DigitalSignature`
  - `KeyAgreement`
  - `ServerAuth`
- This option is mandatory if you use custom TLS certificates, rather than auto-generated certificates.
- Use this option in combination with the `--tls-server-key` option, that provides the path to the private key file for the custom certificate.
- Include the names of the certificate and key files in the paths.
- If you use trusted custom certificates, container developers run Docker commands with the `--tlsverify`, `--tlscacert`, `--tlscert`, and `--tlskey` options.

<pre>--tls-server-cert <i>path_to_certificate_file</i>/<i>certificate_file_name</i>.pem 
--tls-server-key <i>path_to_key_file</i>/<i>key_file_name</i>.pem
</pre> 

### `--tls-server-key` <a id="key"></a>

Short name: none

The path to the private key file to use with a custom server certificate. This option is mandatory if you specify the `--tls-server-cert` option, that provides the path to a custom X.509 certificate file. Include the names of the certificate and key files in the paths. 

**IMPORTANT**: The key must not be encrypted.

<pre>--tls-server-cert <i>path_to_certificate_file</i>/<i>certificate_file_name</i>.pem 
--tls-server-key <i>path_to_key_file</i>/<i>key_file_name</i>.pem
</pre> 

### `--tls-ca` <a id="tls-ca"></a>

Short name: `--ca`

You can specify `--tls-ca` multiple times, to point `vic-machine create` to a file that contains the public portion of a CA. `vic-machine create` uses these CAs to validate client certificates that are offered as credentials for Docker API access. This does not need to be the same CA that you use to sign the server certificate.

<pre>--tls-ca <i>path_to_ca_file</i></pre>

**NOTE**: The `--tls-ca` option appears in the extended help that you see by running <code>vic-machine-<i>os</i> create --extended-help</code> or <code>vic-machine-<i>os</i> create -x</code>.

## Example `vic-machine` Commands <a id="example"></a>

You can create a VCH that uses a custom server certificate, for example  a server certificate that has been signed by Verisign or another public root. You use the `--tls-server-cert` and `--tls-server-key` options to provide the paths to a custom X.509 certificate and its key when you deploy a VCH. The paths to the certificate and key files must be relative to the location from which you are running `vic-machine create`.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--tls-server-cert ../some/relative/path/<i>certificate_file</i>.pem
--tls-server-key ../some/relative/path/<i>key_file</i>.pem
--name vch1
--thumbprint <i>certificate_thumbprint</i>
</pre>


### Combine Custom Server Certificates and Auto-Generated Client Certificates <a id="certcombo"></a>

You can create a VCH with a custom server certificate by specifying the paths to custom `server-cert.pem` and `server-key.pem` files in the `--tls-server-cert` and `--tls-server-key` options. The key should be un-encrypted. Specifying the `--tls-server-cert` and `--tls-server-key` options for the server certificate does not affect the automatic generation of client certificates. If you specify the `--tls-cname` option to match the common name value of the server certificate, `vic-machine create` generates self-signed certificates for Docker client authentication and deployment of the VCH succeeds.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files.
- Specifies the common name from the server certificate in the `--tls-cname` option. The `--tls-cname` option is used in this case to ensure that the certificate is valid for the resulting VCH, given the network configuration.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--tls-server-cert ../some/relative/path/<i>certificate_file</i>.pem
--tls-server-key ../some/relative/path/<i>key_file</i>.pem
--tls-cname <i>cname_from_server_cert</i>
--name vch1
--thumbprint <i>certificate_thumbprint</i>
</pre>