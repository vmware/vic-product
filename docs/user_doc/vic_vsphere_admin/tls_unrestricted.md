# Disable Client Verification

To deploy a virtual container host (VCH) that does not restrict access to the Docker API but still encrypts communication between clients and the VCH, you can disable client certificate verification. You can also completely disable TLS authentication and encryption on both the client and server sides.

- [Options](#options)
  - [Disable Client Certificate Verification](#no-tlsverify) 
  - [Disable Secure Access](#no-tls)
- [Examples](#examples)
  - [Automatically Generate Server Certificates and Disable Client Certificate Verification](#auto-notlsverify)
  - [Use Custom Server Certificates and Disable Client Certificate Verification](#custom_notlsverify)
  - [Disable Secure Access](#example_no-tls)
- [What to Do Next](#whatnext)

## Options <a id="options"></a>

The following sections each correspond to an entry in the Security page of the Create Virtual Container Host wizard if you select the **Docker API Access** tab. Each section also includes a description of the corresponding `vic-machine create` option. 

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### Disable Client Certificate Verification <a id="no-tlsverify"></a>

Disabling client certificate verification prevents the use of CAs for client authentication. You still require a server certificate if you disable client authentication. You can either supply a custom server certificate or have vSphere Integrated Containers Engine automatically generate one. If disable client authentication there is no access control to the VCH from Docker clients, but connections remain encrypted.

If you deploy a VCH with the `--no-tlsverify` option, container developers run Docker commands with the `--tls` option, and the `DOCKER_TLS_VERIFY` environment variable must not be set. Note that setting `DOCKER_TLS_VERIFY` to 0 or `false` has no effect. For more information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

#### Create VCH Wizard

Toggle the **Client Certificates** switch to the gray off position.

#### vic-machine Option 

`--no-tlsverify`, `--kv`

If you specify the `--no-tlsverify` option with no other security options, `vic-machine create` performs the following actions during the deployment of the VCH.

- Generates a self-signed server certificate if you do not specify `--tls-server-cert` and `--tls-server-key`.
- Creates a folder with the same name as the VCH in the location in which you run `vic-machine create`.
- Creates an environment file named <code><i>vch_name</i>.env</code> in that folder, that contains the `DOCKER_HOST=vch_address` environment variable, that you can provide to container developers to use to set up their Docker client environment.

The `--no-tlsverify` option takes no arguments. 

<pre>--no-tlsverify</pre>

### Disable Secure Access <a id="no-tls"></a>

You can completely disable authentication of connections between  Docker clients and the VCH. VCHs use neither client nor server certificates. Any Docker client can connect to the VCH if you disable TLS authentication and connections are not encrypted. 

**IMPORTANT**: Disabling secure access is for testing purposes only. Do not disable secure access in production environments.

If you completely disable secure access to the VCH, container developers connect Docker clients to the VCH over HTTP on 2375, instead of over the HTTPS port, 2376.

#### Create VCH Wizard

Toggle the **Enable secure access to this VCH** switch to the gray off position.

#### vic-machine Option 

`--no-tls`, `-k`

Run `vic-machine create` with the `--no-tls` option and no other security options. The `--no-tls` option takes no arguments.

<pre>--no-tls</pre>

# Examples <a id="examples"></a>

This section provides examples of the combinations of options to use in the **Docker API Access** tab in the Security page of the Create Virtual Container Host wizard and in `vic-machine create`, for the different security configurations that you can implement when using automatically generated and custom certificates.

- [Automatically Generate Server Certificates and Disable Client Certificate Verification](#auto-notlsverify)
- [Use Custom Server Certificates and Disable Client Certificate Verification](#custom_notlsverify)
- [Disable Secure Access](#example_no-tls)

## Automatically Generate Server Certificates and Disable Client Certificate Verification <a id="auto-notlsverify"></a>

This example deploys a VCH with the following security configuration. 

- Uses an automatically generated server certificate.
- Disables client certificate authentication.

### Create VCH Wizard

1. Leave the **Enable secure access to this VCH** switch in the green ON position.
2. For **Source of certificates**, select the **Auto-generate** radio button.
3. In the **Common Name (CN)** text box, enter the IP address, FQDN, or a domain wildcard for the client systems that connect to this VCH.
4. In the **Organization (O)** text box, leave the default setting of the VCH name, or enter a different organization identifier.
5. In the **Certificate key size** text box, leave the default setting of 2048 bits, or enter a higher value.
3. Toggle the **Client Certificates** switch to the gray off position.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH that specifies `--no-tlsverify` to disable client authentication.

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

This example deploys a VCH with the following security configuration: 

- Uses a custom server certificate.
- Disables client certificate authentication.

### Create VCH Wizard

1. Leave the **Enable secure access to this VCH** switch in the green ON position.
2. For **Source of certificates**, select the **Existing** radio button.
3. For **Server certificate**, click **Select** and navigate to an existing `server-cert.pem` file.
4. For **Server private key**, click **Select** and navigate to an existing `server-cert.pem` file.
5. Toggle the **Client Certificates** switch to the gray off position.

### `vic-machine` Command

This example `vic-machine create` command provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files, and specifies the `--no-tlsverify` option to disable client authentication.

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

### Disable Secure Access <a id="example_no-tls"></a>

This example completely disables secure access to the VCH. All communication between the VCH and Docker clients is insecure and unencrypted.

### Create VCH Wizard

Toggle the **Enable secure access to this VCH** switch to the gray off position.

### `vic-machine` Command

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

# What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, stay on the Security page and select the **Registry Access tab** to [Configure Registry Access](vch_registry.md).