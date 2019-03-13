# Virtual Container Host Certificate Options

This topic describes the different certificate options that you use when deploying virtual container hosts (VCHs) that implement verification of client certificates. It provides examples of how to combine the options to achieve different configurations.

For information about how VCHs and Docker use certificates, see [Virtual Container Host Certificate Requirements](vch_cert_reqs.md).

For information about how to deploy VCHs that do not verify  connections from clients, see [Disable Client Authentication](tls_unrestricted.md).

# Options <a id="options"></a>

The following sections each correspond to an entry in the Security page of the Create Virtual Container Host wizard. Each section also includes a description of the corresponding `vic-machine create` option. 

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

## Client Certificates <a id="client"></a>

You upload an existing Certificate Authority (CA) for vSphere Integrated Containers Engine to use to sign client certificates. If you use `vic-machine`, you can opt for vSphere Integrated Containers Engine to automatically generate a CA, or you can provide a custom CA. If you use the Create Virtual Container Host wizard, you must provide a custom CA.

### Select CA Certificate PEM File <a id="ca-pem"></a>

If you do not use an automatically generated CA, you must provide the public portion of a CA for the VCH to use to validate client certificates. The client certificates are used as credentials for access to the Docker API running in the VCH. This does not need to be the same CA as you use to sign the server certificate, if you use a custom CA to sign server certificates. You can specify multiple CAs if you use more than one CA to sign client certificates. 

You must provide `cert.pem` and `key.pem` client certificate files that are signed by this CA to container developers, so that they can connect Docker clients to the VCH. vSphere Integrated Containers Management Portal administrators require these files when they add VCHs to projects in management portal.

- For information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).
- For information about how to add VCHs to management portal, see [Add Container Hosts with Full TLS Authentication](add_vch_fullTLS_in_portal.md) in *vSphere Integrated Containers Management Portal Administration*. 
- For information about the requirements for client certificates, see the section on custom certificates in [Virtual Container Host Certificate Requirements](vch_cert_reqs.md#custom).

#### Create VCH Wizard

If you use the Create Virtual Container Host wizard and you do not disable client verification, it is **mandatory** to upload at least one custom CA file. The Create Virtual Container Host wizard does not support automatic generation of CA files.

1. Leave the **Client Certificates** switch in the green ON position, to enable verification of client certificates.
2. For **Select the X.509 certificate pem** file, click **Select** and navigate to an existing `ca.pem` file for the custom CA that you use to sign client certificates.
3. Optionally click **Select** again to upload additional CAs.

#### vic-machine Option 

`--tls-ca`, `--ca`

Specify the path to an existing `ca.pem` file for the custom CA that you use to sign client certificates. Include the filename in the path. You can specify `--tls-ca` multiple times. If not specified, and if no CA exists in the certificate folder on the machine on which you run `vic-machine`, `vic-machine create` automatically generates a CA.

<pre>--tls-ca <i>path_to_ca_file</i>/ca.pem</pre>

## Server Certificates <a id="server"></a>

You can opt for vSphere Integrated Containers Engine to automatically generate server certificates, or you can upload existing custom certificates.

### Common Name (CN) <a id="tls-cname"></a>

The IP address, FQDN, or a domain wildcard, for the client system or systems that connect to this VCH. This option is only applicable if you are using an automatically generated server certificate. 

**NOTE**: Specifying an FQDN or wildcard assumes that there is a DHCP server offering IP addresses on the client network, and that those addresses have corresponding DNS entries such as `dhcp-a-b-c.example.com`.

#### Create VCH Wizard

1. For **Source of certificates**, select the **Auto-generate** radio button.
2. In the **Common Name (CN)** text box, enter the IP address, FQDN, or a domain wildcard  for the client systems that connect to this VCH.

#### vic-machine Option 

`--tls-cname`, no short name

The IP address, FQDN, or a domain wildcard, for the client system or systems that connect to this VCH. 

<pre>--tls-cname vch-name.example.org</pre>
<pre>--tls-cname *.example.org</pre>

If you specify `--tls-cname`, `vic-machine create` performs the following actions during the deployment of the VCH:

- On the system on which you run `vic-machine`, checks for an existing server certificate in either a folder that has the same name as the VCH that you are deploying, or in a location that you can optionally specify in the [`--tls-cert-path`](#cert-path) option. If a valid  server certificate exists that includes the same Common Name attribute as the one that you specify in `--tls-cname`, `vic-machine create` reuses that certificate. Reusing certificates allows you to delete and recreate VCHs for which you have already distributed the client certificates to container developers.
- If certificates are present in the certificate folder that include a different Common Name attribute to the one that you specify in `--tls-cname`, `vic-machine create` fails.  
- If a certificate folder does not exist, `vic-machine create` creates a folder with the same name as the VCH in the location from which you run `vic-machine`, or creates a folder in a location that you specify in the `--tls-cert-path` option. 
- If valid certificates do not already exist, `vic-machine create` automatically creates a CA and uses that CA to sign and create a client certificate and to sign the server certificate. The CA and client certificate allow the server to confirm the identity of the client. The `vic-machine create` command creates the following CA, server, and client certificate/key pairs in the certificate folder:
  - `ca.pem`
  - `ca-key.pem`
  - `cert.pem` 
  - `key.pem`
  - `server-cert.pem`
  - `server-key.pem`
- Creates a browser-friendly PFX client certificate, `cert.pfx`, to use to authenticate connections to the VCH Admin portal for the VCH.

**NOTE**: The folder and file permissions for the generated certificate and key are readable only by the user who created them.

Running `vic-machine create` with the `--tls-cname` option also creates an environment file named <code><i>vch_name</i>.env</code>, that contains Docker environment variables that container developers can use to configure their Docker client environment. For information about how to connect Docker clients to VCHs, see [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md).

**NOTE**: If you do not specify `--tls-cname` but you do set a static address for the VCH on the client network interface, `vic-machine create` uses that  address for the Common Name, with the same results as if you had specified `--tls-cname`. For information about setting a static IP address on the client network, see [Configure the Client Network](client_network.md).


### Organization (O) <a id="org"></a>

A list of identifiers to record in automatically generated server certificates, to add basic descriptive information to the server certificate. This information is visible to clients if they inspect the server certificate. 

#### Create VCH Wizard

1. For **Source of certificates**, select the **Auto-generate** radio button.
2. In the **Organization (O)** text box, leave the default setting of the VCH name, or enter a different organization identifier.

#### vic-machine Option 

`--organization`, no short name

If you specify `--tls-cname`, you can optionally specify `--organization`. If not specified, `vic-machine create` uses the name of the VCH as the `organization` value.

**NOTE**: If you specify a static IP address on the client network, the `client-ip-address` is used for `CommonName` but not  for  `Organization`.

<pre>--organization <i>my_organization_name</i></pre>

### Certificate Key Size <a id="keysize"></a>

The size of the key for vSphere Integrated Containers Engine to use when it creates auto-generated certificates. It is not recommended to use key sizes of less than the default of 2048 bits. 

#### Create VCH Wizard

1. For **Source of certificates**, select the **Auto-generate** radio button.
2. In the **Certificate key size** text box, leave the default setting of 2048 bits, or enter a higher value.

#### vic-machine Option 

`--certificate-key-size`, `--ksz`

If you specify `--tls-cname`, you can optionally specify `--certificate-key-size`. If not specified, `vic-machine create` creates keys with default size of 2048 bits.

<pre>--certificate-key-size 3072</pre>

### Certificate Path <a id="cert-path"></a>

If you are using the Create Virtual Container Host wizard, the certificate path setting is not applicable.

#### vic-machine Option 

`--tls-cert-path`, none

By default `--tls-cert-path` is a folder in the current directory on the system on which you are running `vic-machine`. The certificate folder takes its name from the VCH name that you specify in the `--name` option. If specified, `vic-machine create` checks in the `--tls-cert-path` folder for existing certificates with the standard names and uses those certificates if they are present:

* `server-cert.pem` 
* `server-key.pem`
* `ca.pem`

If `vic-machine create` does not find existing certificates with the standard names in the folder you specify in `--tls-cert-path`, or if you do not specify certificates directly by using the `--tls-server-cert`, `--tls-server-key`, and `--tls-ca` options, `vic-machine create` automatically generates certificates. Automatically generated certificates are saved in the `--tls-cert-path` folder with the standard names. `vic-machine create` additionally generates other certificates:

* `cert.pem` and `key.pem` for client certificates, if required.
* `ca-key.pem`, the private key for the certificate authority. 

If the folder that you specify in `--tls-cert-path` does not exist, `vic-machine create` creates it. 

<pre>--tls-cert-path '<i>path_to_certificate_folder</i>'
</pre>

### Server Certificate <a id="server-cert"></a>

A custom X.509 server certificate for the VCH if you do not select the options to automatically generate a server certificate. The server certificate identifies the VCH endpoint VM both to Docker clients and to browsers that connect to the VCH Admin portal. For information about the requirements for server certificates, see the section on custom certificates in [Virtual Container Host Certificate Requirements](vch_cert_reqs.md#custom).

#### Create VCH Wizard

1. For **Source of certificates**, select the **Existing** radio button.
2. For **Server certificate**, click **Select** and navigate to an existing `server-cert.pem` file.

#### vic-machine Option 

`--tls-server-cert`, no short name

This option is **mandatory** if you use custom server certificates, rather than auto-generated certificates. If you do not use  an automatically generated server certificate, use this option in combination with the `--tls-server-key` option, that provides the path to the private key file for the custom server certificate. Include the name of the certificate file in the path.

If you provide a custom server certificate by using the `--tls-server-cert` option, you can use `--tls-cname` as a sanity check to ensure that the certificate is valid for the deployment.

<pre>--tls-server-cert <i>path_to_certificate_file</i>/<i>certificate_file_name</i>.pem</pre> 

### Server Private Key <a id="server-key"></a>

The private key file to use with a custom server certificate. This option is mandatory if you specify a custom X.509 server certificate. Include the name of the key file in the path. 

**IMPORTANT**: The key must not be encrypted.

#### Create VCH Wizard

1. For **Source of certificates**, select the **Existing** radio button.
2. For **Server private key**, click **Select** and navigate to an existing `server-key.pem` file.

#### vic-machine Option 

`--tls-server-key`, no short name

Use this option in combination with the `--tls-server-cert` option. Include the name of the key file in the path.

<pre>--tls-server-key <i>path_to_key_file</i>/<i>key_file_name</i>.pem
</pre> 

## How to Connect to VCHs with Client Verification <a id="connect"></a>

After deployment, the Docker API for VCHs that implement client verification is accessible at https://<i>vch_dnsname</i>.example.org:2376.

You must provide the `cert.pem`, `key.pem`, and `ca.pem` files to all container developers who need to connect Docker clients to the VCH.

- If you deploy VCHs by using the Create Virtual Container Host wizard, you must create the `cert.pem` and `key.pem` files manually, using the custom `ca.pem` file to sign them. 
- If you deploy VCHs by using `vic-machine`, you can either use the auto-generated client certificate, or use a client certificate that you create and sign manually.

If vSphere Integrated Containers Management Portal administrators or DevOps administrators intend to add the VCH to a project in vSphere Integrated Containers Management Portal, they also require the `cert.pem`, `key.pem`, and `ca.pem` files.

# Examples <a id="examples"></a>

This section provides examples of the combinations of options to use in the Security page of the Create Virtual Container Host wizard and in `vic-machine create`, for the different security configurations that you can implement when using automatically generated and custom certificates.

- [Automatically Generate Server, Client, and CA Certificates](#full-auto)
- [Automatically Generate Server Certificates and Use Custom CA and Client Certificates](#auto-server)
- [Use Custom Server and Client Certificates and a Custom CA](#all-custom)
- [Use a Custom Server Certificate and Automatically Generate a CA and Client Certificate](#custom-server-auto-client-ca)

## Automatically Generate Server, Client, and CA Certificates <a id="full-auto"></a>

This example deploys a VCH with the following security configuration: 

- Uses an automatically generated server certificate
- Implements client authentication with an automatically generated client certificate
- Uses an automatically generated CA to sign the client and server certificates 

### Create VCH Wizard

The Create Virtual Container Host wizard does not support automatic generation of CAs and client certificates.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides a wildcard domain, `*.example.org`, for the client systems that will connect to this VCH, for use as the Common Name in the  server certificate. This assumes that there is a DHCP server offering IP addresses on the public network, and that those addresses have corresponding DNS entries such as `dhcp-a-b-c.example.com`.
- Specifies an empty folder in which to save the auto-generated certificates. 
- Sets the certificate's `organization` (`O`) field to `My Organization`.
- Generates a certificate with a key size of 3072 bits.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
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
- No existing `server-cert.pem`, `server-key.pem`, or `ca.pem` certificates are present in the folder, so `vic-machine` automatically generates them and saves them in the certificate folder.
- Automatically generates a client certificate and saves it in the  certificate folder.
- Uses the automatically generated CA to sign the server and client certificates.
- Automatically generates a `.pfx` certificate to allow access to the VCH Admin portal for this VCH.
- Generates an `env` file that includes the environment variables with which to configure Docker clients that connect to this VCH.

## Automatically Generate Server Certificates and Use a Custom CA for Client Certificates <a id="auto-server"></a>

This section provides examples of using both the Create Virtual Container Host wizard and `vic-machine create` to deploy a VCH with the following security configuration: 

- Uses an automatically generated server certificate.
- Uploads the CA certificate for a custom CA that you use to sign custom client certificates.
- Implements client authentication with a custom client certificate.

### Prerequisites

- Create or obtain the `ca.pem` file for the CA that you use to sign client certificates.
- Use the custom CA to create and sign client certificates.

### Create VCH Wizard

1. Leave the **Client Certificates** switch in the green ON position, to enable verification of client certificates.
2. Click **Select** and navigate to an existing `ca.pem` file for the custom CA that you use to sign client certificates.
3. Optionally click **Select** again to upload additional CAs.
4. Under Server Certificates, select the **Auto-generate** radio button.
5. In the **Common Name (CN)** text box, enter the IP address, FQDN, or a domain wildcard for the client systems that connect to this VCH.
6. In the **Organization (O)** text box, leave the default setting of the VCH name, or enter a different organization identifier.
7. In the **Certificate key size** text box, leave the default setting of 2048 bits, or enter a higher value.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides a wildcard domain `*.example.org` as the FQDN for the client systems that connect to the VCH, for use as the Common Name in the  automatically generated server certificate. This assumes that there is a DHCP server offering IP addresses on the public network, and that those addresses have corresponding DNS entries such as `dhcp-a-b-c.example.com`.
- Specifies the folder in which to save auto-generated certificates in the `--tls-cert-path` option. 
- Sets the certificate's `organization` (`O`) field to `My Organization`.
- Generates certificates with a key size of 3072 bits.
- Provides the path to an existing `ca.pem` file for the CA that you use to sign client certificates.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
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
- Since no existing `server-cert.pem` or `server-key.pem` certificates are present in the folder, `vic-machine` automatically generates them.
- Automatically generates a client certificate, signs it with the custom CA, and saves it in the certificate folder. However, you can use any client certificate that is signed by the CA that you provided to the VCH.

You must provide the custom `cert.pem`, `key.pem`, and `ca.pem` files to all container developers who need to connect Docker clients to this VCH.

## Use a Custom Server Certificate and a Custom CA for Client Certificates <a id="all-custom"></a>

This example deploys a VCH with the following security configuration: 

- Uses a custom server certificate.
- Implements client authentication with a custom client certificate.
- Uses a custom CA. 

### Prerequisite

Create or obtain server and client certificates, that you sign by  using a custom CA.

### Create VCH Wizard

1. Leave the **Client Certificates** switch in the green ON position, to enable verification of client certificates.
2. Click **Select** and navigate to an existing `ca.pem` file for the custom CA that you use to sign client certificates.
3. Optionally click **Select** again to upload additional CAs.
4. Under Server Certificates, select the **Existing** radio button.
5. For **Server certificate**, click **Select** and navigate to an existing `server-cert.pem` file.
6. For **Server private key**, click **Select** and navigate to an existing `server-key.pem` file.

### `vic-machine` Command

This example `vic-machine create` command provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files, and a custom CA.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--tls-server-cert <i>path_to_folder</i>/<i>certificate_file</i>.pem
--tls-server-key <i>path_to_folder</i>/<i>key_file</i>.pem
--tls-ca <i>path_to_folder</i>/ca.pem
--name vch1
--thumbprint <i>certificate_thumbprint</i>
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Uploads the custom server certificate and key to the VCH.
- Uploads the CA to the VCH, to verify client certificates that have been signed by that CA.

You must provide the custom `cert.pem`, `key.pem`, and `ca.pem` files to all container developers who need to connect Docker clients to this VCH.


## Use a Custom Server Certificate and Automatically Generate a CA and Client Certificate <a id="custom-server-auto-client-ca"></a>

Specifying the `--tls-server-cert` and `--tls-server-key` options for the server certificate does not affect the automatic generation of client certificates. If you specify the [`--tls-cname`](#tls-cname) option to match the common name value of the server certificate, `vic-machine create` generates self-signed certificates for Docker client authentication and deployment of the VCH succeeds.

### Prerequisite

Create or obtain a custom server certificate, that you sign by using a custom CA.

### Create VCH Wizard

The Create Virtual Container Host wizard does not support automatic generation of CAs and client certificates.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH with the following configuration:

- Provides the paths relative to the current location of the `*.pem` files for the custom server certificate and key files.
- Specifies the common name from the server certificate in the `--tls-cname` option. The `--tls-cname` option is used in this case to ensure that the auto-generated client certificate is valid for the resulting VCH, given the network configuration.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--tls-server-cert ../some/relative/path/<i>certificate_file</i>.pem
--tls-server-key ../some/relative/path/<i>key_file</i>.pem
--tls-cname <i>cname_from_server_cert</i>
--name vch1
--thumbprint <i>certificate_thumbprint</i>
</pre>

### Result

When you run this command, `vic-machine create` performs the following operations:

- Uploads the `server-cert.pem` or `server-key.pem` to the VCH.
- Automatically generates a CA.
- Uses the CA to create and sign a client certificate.

After deployment, the Docker API for this VCH is accessible at https://dhcp-a-b-c.example.org:2376.

You must provide the automatically generated `cert.pem`, `key.pem`, and `ca.pem` file to all container developers who need to connect Docker clients to this VCH.

### Troubleshooting <a id="troubleshooting"></a>

If you see certificate errors during deployment, see the following troubleshooting topics:

* [VCH Deployment Fails with a Certificate Verification Error](ts_thumbprint_error.md)
* [VCH Deployment Fails with Missing Common Name Error Even When TLS Options Are Specified Correctly](ts_cli_argument_error.md)
* [VCH Deployment Fails with Certificate cname Mismatch](ts_cname_mismatch.md)

# What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to [Configure Registry Access](vch_registry.md).