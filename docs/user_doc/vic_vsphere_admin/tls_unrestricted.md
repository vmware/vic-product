# Disable Certificate Authentication

To deploy a virtual container host (VCH) that does not restrict access to the Docker API but still encrypts communication between clients and the VCH, you can disable client certificate verification. You can also completely disable TLS authentication and encryption on both the client and server sides.

- [Options](#options)
  - [Disable Secure Access](#no-tls)
  - [Disable Client Certificate Verification](#no-tlsverify) 
- [Example `vic-machine` Commands](#examples)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Docker API Access tab in the Security page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Disable Secure Access <a id="no-tls"></a>

You can completely disable TLS authentication of connections between  Docker clients and the VCH. VCHs use neither client nor server certificates. Any Docker client can connect to the VCH if you disable TLS authentication and connections are not encrypted. 

**IMPORTANT**: Disabling secure access is for testing purposes only. Do not disable secure access in production environments.

If you use the `no-tls` option, container developers connect Docker clients to the VCH via the HTTP port, 2375, instead of via the HTTPS port, 2376.

#### Create VCH Wizard

Toggle the **Enable secure access to this VCH** switch to the gray off position.

#### vic-machine Option 

`--no-tls`, `-k`

Run `vic-machine create` with the `--no-tls` option. The `--no-tls` option is exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

The `--no-tls` option takes no arguments.

<pre>--no-tls</pre>

### Disable Client Certificate Verification <a id="no-tlsverify"></a>

Disabling client certificate verification prevents the use of CAs for client authentication. You still require a server certificate if you use `--no-tlsverify`. You can supply a custom server certificate by using the  [`--tls-server-cert`](tls_custom_certs.md#cert) and [`--tls-server-key`](tls_custom_certs.md#key) options. If you specify `--no-tlsverify` but do not use `--tls-server-cert` and `--tls-server-key` to supply a custom server certificate, `vic-machine create` generates a self-signed server certificate. If you specify `--no-tlsverify` there is no access control, however connections remain encrypted.

When you specify the `--no-tlsverify` option, `vic-machine create` performs the following actions during the deployment of the VCH.

- Generates a self-signed server certificate if you do not specify `--tls-server-cert` and `--tls-server-key`.
- Creates a folder with the same name as the VCH in the location in which you run `vic-machine create`.
- Creates an environment file named <code><i>vch_name</i>.env</code> in that folder, that contains the `DOCKER_HOST=vch_address` environment variable, that you can provide to container developers to use to set up their Docker client environment.

If you deploy a VCH with the `--no-tlsverify` option, container developers run Docker commands with the `--tls` option, and the `DOCKER_TLS_VERIFY` environment variable must not be set. Note that setting `DOCKER_TLS_VERIFY` to 0 or `false` has no effect. For more information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

#### Create VCH Wizard

Toggle the **Client Certificates** switch to the gray off position.

#### vic-machine Option 

`--no-tlsverify`, `--kv`

--no-tlsverify: the certificate generated with this option is a _server certificate_ and should exist on the VCH endpoint VM and should not be needed by Admiral. This certificate allows the client to confirm the servers identity (as with banking websites, etc) so long as the client can validate the certificate chain - this may require the CA be provided to the client if using self-signed certificates. The server certificate files should now be named as expected by the docker client. This does not require the client to verify it's identity for the server.

Run `vic-machine create` with the `--no-tlsverify` option. The `--no-tlsverify` option takes no arguments. 

<pre>--no-tlsverify</pre>

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
