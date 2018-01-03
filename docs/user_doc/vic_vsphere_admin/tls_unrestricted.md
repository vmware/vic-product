# Disable Certificate Authentication

To deploy a virtual container host (VCH) that does not restrict access to the Docker API but still encrypts communication between clients and the VCH, you can disable client certificate verification. You can also completely disable TLS authentication and encryption on both the client and server sides.

- [Options](#options)
  - [Disable Client Certificate Verification](#no-tlsverify) 
  - [Disable Secure Access](#no-tls)
- [Automatically Generate Server Certificates and Disable Client Certificate Verification](#auto-notlsverify)
- [Use Custom Server Certificates and Disable Client Certificate Verification](#custom_notlsverify)
- [Disable Client and Server Authentication](#example_no-tls)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Docker API Access tab in the Security page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### Disable Client Certificate Verification <a id="no-tlsverify"></a>

Disabling client certificate verification prevents the use of CAs for client authentication. You still require a server certificate if you use `--no-tlsverify`. You can supply a custom server certificate by using the  [`--tls-server-cert`](vch_cert_options.md#cert) and [`--tls-server-key`](vch_cert_options.md#key) options. If you specify `--no-tlsverify` but do not use `--tls-server-cert` and `--tls-server-key` to supply a custom server certificate, `vic-machine create` generates a self-signed server certificate. If you specify `--no-tlsverify` there is no access control, however connections remain encrypted.

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

## Automatically Generate Server Certificates and Disable Client Certificate Verification <a id="auto-notlsverify"></a>

This example deploys a VCH with the following security configuration. 

- Uses an automatically generated server certificate.
- Disables client certification authentication.

### Create VCH Wizard

1. Leave the **Enable secure access to this VCH** switch in the green ON position.
2. For **Source of certificates**, select the **Auto-generate** radio button.
3. In the **Common Name (CN)** text box, enter the IP address, FQDN, or a domain wildcard for the client systems that connect to this VCH.
4. In the **Organization (O)** text box, leave the default setting of the VCH name, or enter a different organization identifier.
5. In the **Certificate key size** text box, leave the default setting of 2048 bits, or enter a higher value.
3. Toggle the **Client Certificates** switch to the gray off position.

### `vic-machine` Command

This example deploys a VCH that specifies `--no-tlsverify` to disable client authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Use Custom Server Certificates and Disable Client Certificate Verification <a id="custom_notlsverify"></a>

This example deploys a VCH with the following configuration:

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

### Disable Client and Server Authentication <a id="example_no-tls"></a>

This example deploys a VCH that specifies `--no-tls` to disable client and server authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>
