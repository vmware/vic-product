# Disable Client Verification

To deploy a virtual container host (VCH) that does not restrict access to the Docker API but still encrypts communication between clients and the VCH, you can disable client certificate verification. If you use `vic-machine` to deploy VCHs, you can also completely disable TLS authentication and encryption on both the client and server sides.

## Options <a id="options"></a>

The following sections each correspond to an entry in the Security page of the Create Virtual Container Host wizard. Each section also includes a description of the corresponding `vic-machine create` option. 

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### Disable Client Certificate Verification <a id="no-tlsverify"></a>

Disabling client certificate verification prevents the use of CAs for client authentication. VCHs still require a server certificate if you disable client authentication. You can either supply a custom server certificate or have vSphere Integrated Containers Engine automatically generate one. If you disable client authentication, there is no access control to the VCH from Docker clients, but connections remain encrypted.

If you disable client certificate verification, container developers run Docker commands against the VCH with the `--tls` option. The `DOCKER_TLS_VERIFY` environment variable must not be set. Note that setting `DOCKER_TLS_VERIFY` to 0 or `false` has no effect. For more information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

For example, you can access information about a VCH that uses a server certificate but does not perform client verification by running the following command in the Docker client:

<pre>docker -H <i>vch_dnsname</i>.example.org.example.org:2376 --tls info</pre>

#### Create VCH Wizard

To disable client certificate verification, set the **Client Certificates** switch to the gray OFF position. You must still either upload a custom server certificate or configure an automatically generated server certificate.

#### vic-machine Option 

`--no-tlsverify`, `--kv`

If you specify the `--no-tlsverify` option, `vic-machine create` performs the following actions during the deployment of the VCH:

- If you do not specify `--tls-server-cert` and `--tls-server-key`, automatically generates a self-signed server certificate.
- If you specify any or all of `tls-cname`, `organization`, or `cert-key-size`, generates the server certificate with those settings.
- If you specify `--tls-cert-path`, saves the server certificate in the location that you specify. Otherwise, creates a folder with the same name as the VCH in the location in which you run `vic-machine create`.
- If you specify `--no-tlsverify` with no additional security options, generates a generic server certificate.
- Creates an environment file named <code><i>vch_name</i>.env</code> in that folder, that contains the `DOCKER_HOST=vch_address` environment variable, that you can provide to container developers to use to set up their Docker client environment.

The `--no-tlsverify` option takes no arguments. 

<pre>--no-tlsverify</pre>

### Disable Secure Access <a id="no-tls"></a>

If you use `vic-machine` to deploy VCHs, you can completely disable authentication of connections between Docker clients and the VCH. VCHs use neither client nor server certificates. Any Docker client can connect to the VCH if you disable TLS authentication and connections are not encrypted. 

**IMPORTANT**: Disabling secure access is for testing purposes only. Do not disable secure access in production environments.

If you completely disable secure access to the VCH, container developers connect Docker clients to the VCH over HTTP on port 2375, instead of over HTTPS on port 2376. They do not need to specify any TLS options in the Docker command.

For example, you can access information about a VCH that does not use a server or client certificate by running the following command in the Docker client:

<pre>docker -H <i>vch_dnsname</i>.example.org.example.org:2375 info</pre>

#### Create VCH Wizard

It is not possible to completely disable secure access when deploying VCHs from the Create Virtual Container Host wizard.

#### vic-machine Option 

`--no-tls`, `-k`

Run `vic-machine create` with the `--no-tls` option and no other security options. The `--no-tls` option takes no arguments.

<pre>--no-tls</pre>

# Examples <a id="examples"></a>

This section provides examples of the options to use in the **Docker API Access** tab in the Security page of the Create Virtual Container Host wizard and in `vic-machine create`, to create VCHs that disable client certificate verification and that disable secure access completely.

- [Automatically Generate a Server Certificate and Disable Client Certificate Verification](#auto-notlsverify)
- [Use Custom Server Certificates and Disable Client Certificate Verification](#custom_notlsverify)
- [Automatically Generate a Generic Server Certificate and Disable Client Certificate Verification](#generic_no-tlsverify)
- [Disable Secure Access](#example_no-tls)

## Automatically Generate a Server Certificate and Disable Client Certificate Verification <a id="auto-notlsverify"></a>

This example deploys a VCH with the following security configuration. 

- Uses an automatically generated server certificate for which you provide some configuration information.
- Disables client certificate authentication.

### Create VCH Wizard

1. Set the **Client Certificates** switch to the gray OFF position.
2. Under Server Certificates, select the **Auto-generate** radio button.
3. In the **Common Name (CN)** text box, enter the IP address, FQDN, or a domain wildcard for the client systems that connect to this VCH.
4. In the **Organization (O)** text box, leave the default setting of the VCH name, or enter a different organization identifier.
5. In the **Certificate key size** text box, leave the default setting of 2048 bits, or enter a higher value.

### `vic-machine` Command

This example `vic-machine create` command specifies `--no-tlsverify` to disable client authentication, but configures the automatically generated server certificate by specifying `--tls-cname`, `--tls-cert-path`, `--organization`, and `--certificate-key-size`.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--tls-cname *.example.org
--tls-cert-path <i>path_to_cert_folder</i>
--organization 'My Organization'
--certificate-key-size 3072
--no-tlsverify
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Automatically generates a server certificate of size 3072 bits, setting the CN  to `*.example.org`, and the organization to `My Organization`.
- Saves the server certificate in the location that you specify in `--tls-cert-path`.
- Does not generate a client certificate or CA.

You do not need to provide any certificates to container developers. However, you can provide the generated `env` file, with which they can set environment variables in their Docker client.

## Use Custom Server Certificates and Disable Client Certificate Verification <a id="custom_notlsverify"></a>

This example deploys a VCH with the following security configuration: 

- Uses a custom server certificate.
- Disables client certificate authentication.

### Create VCH Wizard

1. Set the **Client Certificates** switch to the gray off position.
2. Under Server Certificates, select the **Existing** radio button.
3. For **Server certificate**, click **Select** and navigate to an existing `server-cert.pem` file.
4. For **Server private key**, click **Select** and navigate to an existing `server-key.pem` file.

### `vic-machine` Command

This example `vic-machine create` command provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files, and specifies the `--no-tlsverify` option to disable client authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--tls-server-cert ../some/relative/path/<i>certificate_file</i>.pem
--tls-server-key ../some/relative/path/<i>key_file</i>.pem
--no-tlsverify
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Uploads the custom server certificate and key to the VCH.
- Does not generate a client certificate or CA.

You do not need to provide any certificates to container developers. However, you can provide the generated `env` file, with which they can set environment variables in their Docker client.

## Automatically Generate a Generic Server Certificate and Disable Client Certificate Verification <a id="generic_no-tlsverify"></a>

This example deploys a VCH with the following security configuration. 

- Uses an automatically generated server certificate for which you provide no configuration information.
- Disables client certificate authentication.

### Create VCH Wizard

The Create Virtual Container Host wizard does not support this configuration.

### `vic-machine` Command

This example deploys a VCH with the following configuration:

- Specifies `--no-tlsverify` to disable client authentication. 
- Provides no options to configure the automatically generated server certificate.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Because no other security options are specified, automatically generates a generic server certificate.
- Does not generate a client certificate or CA.

You do not need to provide any certificates to container developers. However, you can provide the generated `env` file, with which they can set environment variables in their Docker client.

## Disable Secure Access <a id="example_no-tls"></a>

This example completely disables secure access to the VCH. All communication between the VCH and Docker clients is insecure and unencrypted.

### Create VCH Wizard

It is not possible to completely disable secure access when deploying VCHs from the Create Virtual Container Host wizard.

### `vic-machine` Command

This example deploys a VCH that specifies `--no-tls` to disable client and server authentication.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

### Result

When you run this command, `vic-machine create` does not generate any certificates. Connections to the VCH are possible by using HTTP rather than HTTPS. 

You do not need to provide any certificates to container developers. No `env` file is generated, as there are no environment variables to set.

# What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to [Configure Registry Access](vch_registry.md).