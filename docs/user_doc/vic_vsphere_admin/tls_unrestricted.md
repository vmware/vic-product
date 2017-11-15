# Unrestricted Access to the Docker API <a id="unrestricted"></a>

To deploy a VCH that does not restrict access to the Docker API but still encrypts communication between clients and the VCH, use the `--no-tlsverify` option. To completely disable TLS authentication and encryption, use the `--no-tls` option.

- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Options <a id="options"></a>

The `--no-tls` option is exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### `--no-tlsverify` <a id="no-tlsverify"></a>

**Short name**: `--kv`

The `--no-tlsverify` option prevents the use of CAs for client authentication. You still require a server certificate if you use `--no-tlsverify`. You can supply a custom server certificate by using the  [`--tls-server-cert`](tls_custom_certs.md#cert) and [`--tls-server-key`](tls_custom_certs.md#key) options. If you specify `--no-tlsverify` but do not use `--tls-server-cert` and `--tls-server-key` to supply a custom server certificate, `vic-machine create` generates a self-signed server certificate. If you specify `--no-tlsverify` there is no access control, however connections remain encrypted.

When you specify the `--no-tlsverify` option, `vic-machine create` performs the following actions during the deployment of the VCH.

- Generates a self-signed server certificate if you do not specify `--tls-server-cert` and `--tls-server-key`.
- Creates a folder with the same name as the VCH in the location in which you run `vic-machine create`.
- Creates an environment file named <code><i>vch_name</i>.env</code> in that folder, that contains the `DOCKER_HOST=vch_address` environment variable, that you can provide to container developers to use to set up their Docker client environment.

If you deploy a VCH with the `--no-tlsverify` option, container developers run Docker commands with the `--tls` option, and the `DOCKER_TLS_VERIFY` environment variable must not be set. Note that setting `DOCKER_TLS_VERIFY` to 0 or `false` has no effect. For more information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

**Usage**:

The `--no-tlsverify` option takes no arguments. 

<pre>--no-tlsverify</pre>

### `--no-tls` <a id="no-tls"></a>

**Short name**: `-k`

Disables TLS authentication of connections between the Docker client and the VCH. VCHs use neither client nor server certificates.

Set the `no-tls` option if you do not require TLS authentication between the VCH and the Docker client, for example for testing purposes. Any Docker client can connect to the VCH if you disable TLS authentication and connections are not encrypted. 

If you use the `no-tls` option, container developers connect Docker clients to the VCH via the HTTP port, 2375, instead of via the HTTPS port, 2376.

**Usage**:

The `--no-tls` option takes no arguments.

<pre>--no-tls</pre>

## Example `vic-machine` Commands <a id="examples"></a>

- [Disable Client Authentication and Use Auto-Generated Server Certificates](#auto_server)
- [Disable Client Authentication and Use Custom Server Certificates](#custom_server)
- [Disable Client and Server Authentication](#no-auth)

### Disable Client Authentication and Use Auto-Generated Server Certificates <a id="auto_server"></a>

You use the `--no-tlsverify` option with no other TLS options to disable client authentication and auto-generate a server certificate.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Specifies `--no-tlsverify` to disable client authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Disable Client Authentication and Use Custom Server Certificates <a id="custom_server"></a>

You use the `--tls-server-cert`, `--tls-server-key`, and `--no-tlsverify` options to use a custom X.509 server certificate and key and disable client authentication.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files.
- Specifies `--no-tlsverify` option to disable client authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--tls-server-cert ../some/relative/path/<i>certificate_file</i>.pem
--tls-server-key ../some/relative/path/<i>key_file</i>.pem
--no-tlsverify
</pre>

### Disable Client and Server Authentication <a id="no-auth"></a>

You use the `--no-tls` option with no other TLS options to disable client and server authentication.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Specifies `--no-tls` to disable client and server authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

