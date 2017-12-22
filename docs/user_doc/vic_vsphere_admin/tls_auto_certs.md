# Use Automatically Generated Server Certificates

As a convenience, vSphere Integrated Containers Engine provides the option of automatically generating a server certificate for the Docker API endpoint in the VCH. The generated certificates are functional, but they do not allow for fine control over aspects such as expiration, intermediate certificate authorities, and so on. To use more finely configured certificates, see  [Use Custom Server Certificates](tls_custom_certs.md).

VCHs accept client certificates if they are signed by a CA that you  can optionally provide to the VCH. Alternatively, you can configure a VCH so that vSphere Integrated Containers Engine creates a Certificate Authority (CA) certificate that it uses to automatically generate and sign a single client certificate.

**NOTE**: The Create Virtual Container Host wizard in the vSphere Client does not support automatically generated CA or client certificates. To use automatically generated CA and client certificates, you must use the `vic-machine` CLI utility to create the VCH.

This topic describes how to use automatically generated server certificates in combination with automatically generated CA and client certificates, custom CA and client certificates, and with no client certificate validation.

- [Options](#options)
  - [Common Name (CN)](#tls-cname)
  - [Organization (O)](#org)
  - [Certificate key size](#keysize)
  - [Certificate Path](#cert-path)
- [Automatically Generate Server, Client, and CA Certificates](#full-auto)
- [Automatically Generate Server Certificates and Use Custom CA and Client Certificates](#auto-server)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Security page of the Create Virtual Container Host wizard if you select **Docker API Access** > **Source of certificates**: **Auto-generate**. Each section also includes a description of the corresponding `vic-machine create` option. This topic provides examples of the combinations of options to use in both the Create Virtual Container Host wizard and in `vic-machine create`, for the different security configurations that you can implement when using automatically generated server certificates.

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### Common Name (CN) <a id="tls-cname"></a>

The IP address, FQDN, or a domain wildcard for the client system or systems that connect to this VCH, to embed in an automatically generated server certificate. 

**NOTE**: Specifying an FQDN or wildcard assumes that there is a DHCP server offering IP addresses on the client network, and that those addresses have corresponding DNS entries such as `dhcp-a-b-c.example.com`.

#### Create VCH Wizard

Enter the IP address, FQDN, or a domain wildcard in the **Common Name (CN)** text box.

#### vic-machine Option 

`--tls-cname`, None

Specify the IP address, FQDN, or a domain wildcard in the `--tls-cname` option. If you specify `--tls-cname`, `vic-machine create` performs the following actions during the deployment of the VCH:

- Checks for an existing certificate in either a folder that has the same name as the VCH that you are deploying, or in a location that you can optionally specify in the [`--tls-cert-path`](#cert-path) option. If a valid certificate exists that includes the same Common Name attribute as the one that you specify in `--tls-cname`, `vic-machine create` reuses that certificate. Reusing certificates allows you to delete and recreate VCHs for which you have already distributed the client certificates to container developers.
- If certificates are present in the certificate folder that include a different Common Name attribute to the one that you specify in `--tls-cname`, `vic-machine create` fails.  
- If a certificate folder does not exist, `vic-machine create` creates a folder with the same name as the VCH, or creates a folder in the location that you specify in the `--tls-cert-path` option. 
- If valid certificates do not already exist, `vic-machine create` creates a CA certificate and a client certificate signed by that authority. The CA and client certificate allow the server to confirm the identity of the client. The `vic-machine create` command creates the following CA, server, and client certificate/key pairs in the certificate folder:
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

- By using the `tlsverify`, `tlscert`, and `tlskey` options in Docker commands, adding `tlscacert` if a custom CA was used to sign the server certificate.
- By setting the `DOCKER_CERT_PATH=/path/to/client/cert.pem` and `DOCKER_TLS_VERIFY=1` Docker environment variables. 

For more information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

**NOTE**: If you do not specify `--tls-cname` but you do set a static address for the VCH on the client network interface, `vic-machine create` uses that  address for the Common Name, with the same results as if you had specified `--tls-cname`. For information about setting a static IP address on the client network, see [Configure the Client Network](client_network.md).

<pre>--tls-cname vch-name.example.org</pre>
<pre>--tls-cname *.example.org</pre>

### Organization (O) <a id="org"></a>

A list of identifiers to record in automatically generated server certificates, to add basic descriptive information to the certificate. This information is visible to clients if they inspect the server certificate. 

**NOTE**: The `client-ip-address` is used for `CommonName` but not  for  `Organisation`.

#### Create VCH Wizard

Leave the default setting of the VCH name, or enter a different organization identifier.

#### vic-machine Option 

`--organization`, None

If you specify `--tls-cname`, you can optionally specify `--organization`. If not specified,`vic-machine create` uses the name of the VCH as the `organization` value.

<pre>--organization <i>my_organization_name</i></pre>

### Certificate key size <a id="keysize"></a>

The size of the key for vSphere Integrated Containers Engine to use when it creates auto-generated trusted certificates. It is not recommended to use key sizes of less than the default of 2048 bits. 

#### Create VCH Wizard

Leave the default setting of 2048 bits, or enter a higher value.

#### vic-machine Option 

`--certificate-key-size`, `--ksz`

If you specify `--tls-cname`, you can optionally specify `--certificate-key-size`. If not specified, `vic-machine create` creates keys with default size of 2048 bits.

<pre>--certificate-key-size 3072</pre>

### Certificate Path <a id="cert-path"></a>

If you are using the Create Virtual Container Host wizard, setting the certificate path is not applicable.

#### vic-machine Option 

`--tls-cert-path`, none

By default `--tls-cert-path` is a folder in the current directory, that takes its name from the VCH name that you specify in the `--name` option. If specified, `vic-machine create` checks in `--tls-cert-path` for existing certificates with the standard names and uses those certificates if they are present:

* `server-cert.pem` 
* `server-key.pem`
* `ca.pem`

If `vic-machine create` does not find existing certificates with the standard names in the folder you specify in `--tls-cert-path`, or if you do not specify certificates directly by using the `--tls-server-cert`, `--tls-server-key`, and `--tls-ca` options, `vic-machine create` generates certificates. Generated certificates are saved in the `--tls-cert-path` folder with the standard names listed. `vic-machine create` additionally generates other certificates:

* `cert.pem` and `key.pem` for client certificates, if required.
* `ca-key.pem`, the private key for the certificate authority. 

<pre>--tls-cert-path '<i>path_to_certificate_folder</i>'
</pre>

## Automatically Generate Server, Client, and CA Certificates <a id="full-auto"></a>

This example deploys a VCH with the following security configuration. 

- Uses an automatically generated server certificate
- Implements client authentication with an automatically generated client certificate
- Uses an automatically generated CA to sign the client and server certificates 

### Create VCH Wizard

The Create Virtual Container Host wizard does not support automatic generation of CAs and client certificates. You cannot use the Create Virtual Container Host wizard to deploy VCHs with automatically generated CA and client certificates.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides the wildcard domain, `*.example.org`, of the client systems that will connect to this VCH, for use as the Common Name in the certificate. This assumes that there is a DHCP server offering IP addresses on VM Network, and that those addresses have corresponding DNS entries such as `dhcp-a-b-c.example.com`.
- Specifies a folder in which to store the auto-generated certificates.
- Sets the certificate's `organization` (`O`) field to `My Organization`.
- Generates a certificate with a key size of 3072 bits.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--tls-cname *.example.org
--tls-cert-path <i>path_to_cert_folder</i>
--organization 'My Organization'
--certificate-key-size 3072
--thumbprint <i>certificate_thumbprint</i>
--name vch1
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Checks for existing certificates in the folder that you specified in `--tls-cert-path`.
- If no existing `server-cert.pem`, `server-key.pem`, or `ca.pem` certificates are present in the folder, `vic-machine` automatically generates them.
- Automatically generates a client certificate.
- Uses the automatically generated CA to sign the server and client certificates.

After deployment, the Docker API for this VCH is accessible at https://dhcp-a-b-c.example.org:2376.

You must provide the automatically generated `cert.pem`, `key.pem`, and `ca.pem` files to all container developers who need to connect Docker clients to this VCH.

## Automatically Generate Server Certificates and Use Custom CA and Client Certificates <a id="auto-server"></a>

This section provides examples of using both the Create Virtual Container Host wizard and `vic-machine create` to deploy a VCH with the following security configuration: 

- Uses an automatically generated server certificate.
- Uploads the CA certificate for the custom CA that you use to sign the client certificates.
- Implements client authentication with a custom client certificate.

### Prerequisite

Create or obtain the `ca.pem` file for the CA that you use to sign client certificates.

### Create VCH Wizard

1. Leave the **Enable secure access to this VCH** switch in the green ON position.
2. For **Source of certificates**, select the **Auto-generate** radio button.
3. In the **Common Name (CN)** text box, enter the IP address, FQDN, or a domain wildcard for the client systems that connect to this VCH.
4. In the **Organization (O)** text box, leave the default setting of the VCH name, or enter a different organization identifier.
5. In the **Certificate key size** text box, leave the default setting of 2048 bits, or enter a higher value.
6. Leave the **Client Certificates** switch in the green ON position, to enable verification of client certificates.
7. Click **Select** and navigate to an existing `ca.pem` file for the custom CA that you use to sign client certificates.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides a wildcard domain `*.example.org` as the FQDN for the client systems that connect to the VCH, for use as the Common Name in the certificate.
- Specifies a folder for the certificates in the `--tls-cert-path` option.
- Sets the certificate's `organization` (`O`) field to `My Organization`.
- Generates certificates with a key size of 3072 bits.
- Provides the path to an existing `ca.pem` file for the CA that you use to sign client certificates.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--tls-cname *.example.org
--tls-cert-path <i>path_to_cert_folder</i>
--organization 'My Organization'
--certificate-key-size 3072
--tls-ca <i>path_to_folder</i>/ca.pem
--thumbprint <i>certificate_thumbprint</i>
--name vch1
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Checks for existing certificates in the folder that you specified in `--tls-cert-path`.
- If no existing `server-cert.pem` or `server-key.pem` certificates are present in the folder, `vic-machine` automatically generates them.
- Automatically generates a client certificate.
- Uses the CA that you provided to sign the server and client certificates.

After deployment, the Docker API for this VCH is accessible at https://dhcp-a-b-c.example.org:2376.

You must provide the automatically generated `cert.pem` and `key.pem` files and the custom `ca.pem` file to all container developers who need to connect Docker clients to this VCH.