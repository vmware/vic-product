# VCH Deployment Options

The command line utility for vSphere Integrated Containers Engine, `vic-machine`, provides a `create` command with options that allow you to customize the deployment of virtual container hosts (VCHs) to correspond to your vSphere environment.

- [vSphere Target Options](#vsphere)
- [Security Options](#security)
- [Private Registry Options](#registry)
- [Datastore Options](#datastore)
- [Networking Options](vch_networking.md)
- [General Deployment Options](#deployment)

To allow you to fine-tune the deployment of VCHs, `vic-machine create` provides [Advanced Options](#advanced).

- [Advanced Resource Management Options](#adv-mgmt)
- [Other Advanced Options](#adv-other)

**NOTE**: Wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system. 

Option arguments that might require quotation marks include the following:

- User names and passwords in `--target`, or in `--user` and `--password`.
- Datacenter names in `--target`.
- VCH names in `--name`.
- Datastore names and paths in `--image-store` and `--volume-store`.
- Network and port group names in all networking options.
- Cluster and resource pool names in `--compute-resource`.
- Folder names in the paths for `--tls-cert-path`, `--tls-server-cert`, `--tls-server-key`, `--appliance-iso`, and `--bootstrap-iso`.


## vSphere Target Options <a id="vsphere"></a>

The `create` command of the `vic-machine` utility requires you to provide information about where in your vSphere environment to deploy the VCH and the vCenter Server or ESXi user account to use.

You can set environment variables for the `--target`, `--user`, `--password`, and `--thumbprint` options. For information about setting environment variables, see [Set Environment Variables for Key `vic-machine` Options](vic_env_variables.md).

### `--target` ###

Short name: `-t`

The IPv4 address, fully qualified domain name (FQDN), or URL of the ESXi host or vCenter Server instance on which you are deploying a VCH. This option is always **mandatory**.

To facilitate IP address changes in your infrastructure, provide an FQDN whenever possible, rather than an IP address. If `vic-machine create` cannot resolve the FQDN, it fails with an error.

- If the target ESXi host is not managed by vCenter Server, provide the address of the ESXi host.<pre>--target <i>esxi_host_address</i></pre>
- If the target ESXi host is managed by vCenter Server, or if you are deploying to a cluster, provide the address of vCenter Server.<pre>--target <i>vcenter_server_address</i></pre>
- You can include the user name and password in the target URL. If you are deploying a VCH on vCenter Server, specify the username for an account that has the Administrator role on that vCenter Server instance. <pre>--target <i>vcenter_or_esxi_username</i>:<i>password</i>@<i>vcenter_or_esxi_address</i></pre>
  
  If you do not include the user name in the target URL, you must specify the `user` option. If you do not specify the `password` option or include the password in the target URL, `vic-machine create` prompts you to enter the password.

  You can configure a VCH so that it uses a non-administrator account for post-deployment operations by specifying the [`--ops-user`](#ops-user) option. 

- If you are deploying a VCH on a vCenter Server instance that includes more than one datacenter, include the datacenter name in the target URL. If you include an invalid datacenter name, `vic-machine create` fails and suggests the available datacenters that you can specify. 

  <pre>--target <i>vcenter_server_address</i>/<i>datacenter_name</i></pre>

### `--user` ###

Short name: `-u`

The username for the ESXi host or vCenter Server instance on which you are deploying a VCH.

If you are deploying a VCH on vCenter Server, specify a username for an account that has the Administrator role on that vCenter Server instance. 

<pre>--user <i>esxi_or_vcenter_server_username</i></pre>

You can specify the username in the URL that you pass to `vic-machine create` in the `target` option, in which case the `user` option is not required.

You can configure a VCH so that it uses a non-administrator account for post-deployment operations by specifying the [`--ops-user`](#--ops-user) option. If you do not specify `--ops-user`, VCHs use the vSphere administrator account that you specify in `--user` for general post-deployment operations.

### `--password` ###

Short name: `-p`

The password for the user account on the vCenter Server on which you  are deploying the VCH, or the password for the ESXi host if you are deploying directly to an ESXi host. If not specified, `vic-machine` prompts you to enter the password during deployment.

<pre>--password <i>esxi_host_or_vcenter_server_password</i></pre>

You can also specify the username and password in the URL that you pass to `vic-machine create` in the `target` option, in which case the `password` option is not required.

### `--compute-resource` ###

Short name: `-r`

The host, cluster, or resource pool in which to deploy the VCH. 

If the vCenter Server instance on which you are deploying a VCH only includes a single instance of a standalone host or cluster, `vic-machine create` automatically detects and uses those resources. In this case, you do not need to specify a compute resource when you run `vic-machine create`. If you are deploying the VCH directly to an ESXi host and you do not use `--compute-resource` to specify a resource pool, `vic-machine create` automatically uses the default resource pool. 

You specify the `--compute-resource` option in the following circumstances:

- A vCenter Server instance includes multiple instances of standalone hosts or clusters, or a mixture of standalone hosts and clusters.
- You want to deploy the VCH to a specific resource pool in your environment. 

If you do not specify the `--compute-resource` option and multiple possible resources exist, or if you specify an invalid resource name, `vic-machine create` fails and suggests valid targets for `--compute-resource` in the failure message. 

* To deploy to a specific resource pool on an ESXi host that is not managed by vCenter Server, specify the name of the resource pool: <pre>--compute-resource  <i>resource_pool_name</i></pre>
* To deploy to a vCenter Server instance that has multiple standalone hosts that are not part of a cluster, specify the IPv4 address or fully qualified domain name (FQDN) of the target host:<pre>--compute-resource <i>host_address</i></pre>
* To deploy to a vCenter Server with multiple clusters, specify the name of the target cluster: <pre>--compute-resource <i>cluster_name</i></pre>
* To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, or to a specific resource pool in a cluster, if the resource pool name is unique across all hosts and clusters, specify the name of the resource pool:<pre>--compute-resource <i>resource_pool_name</i></pre>
* To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, if the resource pool name is not unique across all hosts, specify the IPv4 address or FQDN of the target host and name of the resource pool:<pre>--compute-resource <i>host_name</i>/<i>resource_pool_name</i></pre>
* To deploy to a specific resource pool in a cluster, if the resource pool name is not unique across all clusters, specify the full path to the resource pool:<pre>--compute-resource <i>cluster_name</i>/Resources/<i>resource_pool_name</i></pre>

### `--thumbprint` <a id="thumbprint"></a>

Short name: None

The thumbprint of the vCenter Server or ESXi host certificate. Specify this option if your vSphere environment uses untrusted, self-signed certificates. If your vSphere environment uses trusted certificates that are signed by a known Certificate Authority (CA), you do not need to specify the `--thumbprint` option.

If you run `vic-machine` without the specifying the `--thumbprint` option and the operation fails, the resulting error message includes the certificate thumbprint. Always verify that the thumbprint in the error message is valid before attempting to run the command again.  

For information about how to obtain the certificate thumbprint either before running `vic-machine` or to verify a thumbprint from a `vic-machine` error message, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md). 

You can bypass certificate thumbprint verification by specifying the `--force` option instead of `--thumbprint`. 

**CAUTION**: It is not recommended to use `--force` to bypass thumbprint verification in production environments. Using `--force` in this way exposes VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials.

Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

<pre>--thumbprint <i>certificate_thumbprint</i></pre>

## Security Options <a id="security"></a>

The security options that `vic-machine create` provides allow for 3 broad categories of security:

- [Restrict access to the Docker API with Auto-Generated Certificates](#restrict_auto)
- [Restrict access to the Docker API with Custom Certificates](#restrict_custom)
- [Do Not Restrict Access to the Docker API](#unrestricted)

You can also configure a VCH to [use different user accounts for deployment and operation](#diff_users).

**NOTE**: Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### Restrict Access to the Docker API with Auto-Generated Certificates <a id="restrict_auto"></a>

As a convenience, `vic-machine create` provides the option of generating a client certificate, server certificate, and certificate authority (CA) as appropriate when you deploy a VCH. The generated certificates are functional, but they do not allow for fine control over aspects such as expiration, intermediate certificate authorities, and so on.

vSphere Integrated Containers Engine authenticates Docker API clients by using client certificates. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. A client certificate is accepted if it is signed by a CA that you provide by specifying one or more instances of the `--tls-ca` option. In the case of the certificates that `vic-machine create` generates, `vic-machine create` creates a CA and uses it to create and sign a single client certificate.

When using the Docker client, the client validates the server either by using CAs that are present in the root certificate bundle of the client system, or that are provided explicitly by using the `--tlscacert` option when running Docker commands. As a part of this validation, the server certificate must explicitly state at least one of the following, and must match the name or address that the client uses to access the server:

- The FQDN used to communicate with the server
- The IP address used to communicate with the server
- A wildcard domain that matches all of the FQDNs in a specific subdomain. For an example of a domain wildcard, see [https://en.wikipedia.org/wiki/Wildcard_certificate#Example](https://en.wikipedia.org/wiki/Wildcard_certificate#Example).

#### `--tls-cname` <a id="tls-cname"></a>

Short name: None

The FQDN or IP address to embed in an auto-generated server certificate. Specify an FQDN, IP address, or a domain wildcard. If you provide a custom server certificate by using the `--tls-server-cert` option, you can use `--tls-cname` as a sanity check to ensure that the certificate is valid for the deployment.

If you do not specify `--tls-cname` but you do set a static address for the VCH on the client network interface, `vic-machine create` uses that  address for the Common Name, with the same results as if you had specified `--tls-cname=x.x.x.x`. For information about setting a static IP address on the client network, see [Specify a Static IP Address for the VCH Endpoint VM](#static-ip).

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

#### `--tls-cert-path` <a id="cert-path"></a>

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

#### `--certificate-key-size` ###

Short name: `--ksz`

The size of the key for `vic-machine create` to use when it creates auto-generated trusted certificates. You can optionally use `--certificate-key-size` if you specify `--tls-cname`. If not specified, `vic-machine create` creates keys with default size of 2048 bits. It is not recommended to use key sizes of less than 2048 bits. 

<pre>--certificate-key-size 3072</pre>

#### `--organization` ###

Short name: None

A list of identifiers to record in certificates generated by `vic-machine`. You can optionally use `--organization` if you specify `--tls-cname`. If not specified,`vic-machine create` uses the name of the VCH as the organization value.

**NOTE**: The `client-ip-address` is used for `CommonName` but not  for  `Organisation`.

<pre>--organization <i>organization_name</i></pre>

### Restrict Access to the Docker API with Custom Certificates <a id="restrict_custom"></a>

To exercise fine control over the certificates that VCHs use, obtain or generate custom certificates yourself before you deploy a VCH. Use the `--tls-server-key`, `--tls-server-cert`, and `--tls-ca` options to pass the custom certificates to `vic-machine create`.

**IMPORTANT**: PKCS#7 certificates do not work with `vic-machine`. For information about how to convert certificates to the correct format, see [Converting Certificates for Use with vSphere Integrated Containers Engine](vic_cert_reference.md#convertcerts). 

#### `--tls-server-cert` <a id="cert"></a>

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

#### `--tls-server-key` <a id="key"></a>

Short name: none

The path to the private key file to use with a custom server certificate. This option is mandatory if you specify the `--tls-server-cert` option, that provides the path to a custom X.509 certificate file. Include the names of the certificate and key files in the paths. 

**IMPORTANT**: The key must not be encrypted.

<pre>--tls-server-cert <i>path_to_certificate_file</i>/<i>certificate_file_name</i>.pem 
--tls-server-key <i>path_to_key_file</i>/<i>key_file_name</i>.pem
</pre> 

#### `--tls-ca` <a id="tls-ca"></a>

Short name: `--ca`

You can specify `--tls-ca` multiple times, to point `vic-machine create` to a file that contains the public portion of a CA. `vic-machine create` uses these CAs to validate client certificates that are offered as credentials for Docker API access. This does not need to be the same CA that you use to sign the server certificate.

<pre>--tls-ca <i>path_to_ca_file</i></pre>

**NOTE**: The `--tls-ca` option appears in the extended help that you see by running <code>vic-machine-<i>os</i> create --extended-help</code> or <code>vic-machine-<i>os</i> create -x</code>.


### Do Not Restrict Access to the Docker API <a id="unrestricted"></a>
To deploy a VCH that does not restrict access to the Docker API, use the `--no-tlsverify` option. To completely disable TLS authentication, use the `--no-tls` option.

#### `--no-tlsverify` <a id="no-tlsverify"></a>

Short name: `--kv`

The `--no-tlsverify` option prevents the use of CAs for client authentication. You still require a server certificate if you use `--no-tlsverify`. You can still supply a custom server certificate by using the  [`--tls-server-cert`](#cert) and [`--tls-server-key`](#key)  options. If you do not use `--tls-server-cert` and `--tls-server-key` to supply a custom server certificate, `vic-machine create` generates a self-signed server certificate. If you specify `--no-tlsverify` there is no access control, however connections remain encrypted.

When you specify the `--no-tlsverify` option, `vic-machine create` performs the following actions during the deployment of the VCH.

- Generates a self-signed server certificate if you do not specify `--tls-server-cert` and `--tls-server-key`.
- Creates a folder with the same name as the VCH in the location in which you run `vic-machine create`.
- Creates an environment file named <code><i>vch_name</i>.env</code> in that folder, that contains the `DOCKER_HOST=vch_address` environment variable, that you can provide to container developers to use to set up their Docker client environment.

If you deploy a VCH with the `--no-tlsverify` option, container developers run Docker commands with the `--tls` option, and the `DOCKER_TLS_VERIFY` environment variable must not be set. Note that setting `DOCKER_TLS_VERIFY` to 0 or `false` has no effect. 

The `--no-tlsverify` option takes no arguments. 

<pre>--no-tlsverify</pre>

#### `--no-tls` <a id="no-tls"></a>

Short name: `-k`

Disables TLS authentication of connections between the Docker client and the VCH. VCHs use neither client nor server certificates.

Set the `no-tls` option if you do not require TLS authentication between the VCH and the Docker client. Any Docker client can connect to the VCH if you disable TLS authentication and connections are not encrypted. 

If you use the `no-tls` option, container developers connect Docker clients to the VCH via port 2375, instead of via port 2376.

<pre>--no-tls</pre>

### Specify Different User Accounts for VCH Deployment and Operation <a id="diff_users"></a>

Because deploying a VCH requires greater levels of permissions than running a VCH, you can configure a VCH so that it uses different user accounts for deployment and for operation. In this way, you can limit the day-to-day operation of a VCH to an account that does not have full administrator permissions on the target vCenter Server.

#### `--ops-user` <a id="ops-user"></a>

Short name: None

A vSphere user account with which the VCH runs after deployment. If not specified, the VCH runs with the vSphere Administrator credentials with which you deploy the VCH, that you specify in either `--target` or `--user`.

<pre>--ops-user <i>user_name</i></pre>

The user account that you specify in `--ops-user` must exist before you deploy the VCH. For information about the permissions that the `--ops-user` account requires, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

#### `--ops-password` ###

Short name: None

The password or token for the operations user that you specify in `--ops-user`. If not specified, `vic-machine create` prompts you to enter the password for the `--ops-user` account.

<pre>--ops-password <i>password</i></pre>

## Private Registry Options <a id="registry"></a>

If you use vSphere Integrated Containers Registry, or if container developers need to access Docker images that are stored in other private registry servers, you must configure VCHs to allow them to connect to these private registry servers when you deploy the VCHs. VCHs can connect to both secure and insecure private registry servers. You can also configure VCHs so that they can only access images from a whitelist of approved registries.


### `--registry-ca` <a id="registry-ca"></a>

Short name: `--rc`

The path to a CA certificate that can validate the server certificate of a private registry. You can specify `--registry-ca` multiple times to specify multiple CA certificates for different registries. This allows a VCH to connect to multiple registries. 

The use of registry certificates is independent of the Docker client security options that you specify. For example, it is possible to use the `--no-tls` option to disable TLS authentication between Docker clients and the VCH, and to use the `--registry-ca` option to enable TLS authentication  between the VCH and a private registry. 

You must use this option to allow a VCH to connect to vSphere Integrated Containers Registry. For information about how to obtain the CA certificate from vSphere Integrated Containers Registry, see [Deploy a VCH for Use with vSphere Integrated Containers Registry](deploy_vch_registry.md).

<pre>--registry-ca <i>path_to_ca_cert_1</i>
--registry-ca <i>path_to_ca_cert_2</i>
</pre>

**NOTE**: The `--registry-ca` option appears in the extended help that you see by running <code>vic-machine-<i>os</i> create --extended-help</code> or <code>vic-machine-<i>os</i> create -x</code>.


### `--insecure-registry` <a id="insecure-registry"></a>

Short name: `--dir`

If you set the `--insecure-registry` option, the VCH does not verify the certificate of that registry when it pulls images. Insecure private registries are not recommended in production environments.

If you authorize a VCH to connect to an insecure private registry server, the VCH attempts to access the registry server via HTTP if access via HTTPS fails. VCHs always use HTTPS when connecting to registry servers for which you have not authorized insecure access.

**NOTE**: You cannot configure VCHs to connect to vSphere Integrated Containers Registry instances as insecure registries. Connections to vSphere Integrated Containers Registry always require HTTPS and a certificate.

You can specify `--insecure-registry` multiple times if multiple insecure registries are permitted. If the registry server listens on a specific port, add the port number to the URL

<pre>--insecure-registry <i>registry_URL_1</i>
--insecure-registry <i>registry_URL_2</i>:<i>port_number</i>
</pre>


### `--whitelist-registry` <a id="whitelist-registry"></a>

You can restrict the registries to which a VCH allows access by setting the `--whitelist-registry` option. You can specify `--whitelist-registry` multiple times to allow access to multiple registries. If you specify `--whitelist-registry` at least once, the VCH runs in whitelist mode. In whitelist mode, users can only access those registries that you have specified in the `--whitelist-registry` option. Users cannot access any registries that are not in the whitelist, even if they are public registries, such as Docker Hub.

You can specify whitelisted registries in the following formats:
 
- IP addresses or FQDN to identify individual registry instances. During deployment, `vic-machine` validates the IP address of the registry.
- CIDR formatted ranges, for example, 192.168.1.1/24. If you specify a CIDR range, the VCH adds to the whitelist any IP addresses within that subnet. Note that `vic-machine` does not validate CIDR defined ranges during deployment.
- Wildcard domains, for example, . *.company.com. If you specify a wildcard domain, the VCH adds to the whitelist any IP addresses or FQDNs that it can validate against that domain. A numeric IP address causes VCHs to perform a reverse DNS lookup to validate against that wild card domain. Note that `vic-machine` does not validate wildcard domains during deployment. 

You use `--whitelist-registry` in combination with the `--registry-ca`  and `--insecure-registry` options. You can configure a VCH so that it includes both secure and insecure registries in its whitelist.

#### Whitelisting Secure Registries

VCHs include a base set of well-known certificates from public CAs. If a registry requires a certificate to authenticate access, and if that registry does not use one of the CAs in the VCH, you must provide the CA certificate for that registry in the `--registry-ca` option. You must also specify that registry in the `--whitelist-registry` option if the VCH is running in whitelist mode.

- If you provide a certificate in the `--registry-ca` option but you do not specify that registry in the `--whitelist-registry` option, the VCH does not allow access to that registry. 
- If you specify a registry in the `--whitelist-registry` option, but you do not provide a certificate in `--registry-ca` and the registry's CA is not in the set of well-known certificates in the VCH, the VCH does not allow access to that registry.

<pre>--whitelist-registry <i>registry_address</i> 
--registry-ca <i>path_to_ca_cert_1</i>
</pre>

#### Whitelisting Insecure Registries

You can add registries that you designate as insecure registries to the whitelist by specifying both of the `--insecure-registry` and `--whitelist-registry` options. 

- If you specify a registry in the `--whitelist-registry` option, but you do not specify that registry in `--insecure-registry`, the VCH attempts to verify the registry by using certificates. If it does not find a certificate, the VCH does not allow access to that registry.
- If you specify a registry in the `--insecure-registry` option but you do not specify this registry in `--whitelist-registry`, `vic-machine` adds the registry to the whitelist only if at least one other registry is specified in `--whitelist-registry`.

<pre>--whitelist-registry <i>registry_address</i> 
--insecure-registry <i>registry_address</i>
</pre>


## Datastore Options <a id="datastore"></a>
The `vic-machine` utility allows you to specify the datastore in which to store container image files, container VM files, and the files for the VCH. You can also specify datastores in which to create container volumes. 

- vSphere Integrated Containers Engine fully supports VMware vSAN datastores. 
- vSphere Integrated Containers Engine supports all alphanumeric characters, hyphens, and underscores in datastore paths and datastore names, but no other special characters.
- If you specify different datastores in the different datastore options, and if no single host in a cluster can access all of those datastores, `vic-machine create` fails with an error.
    <pre>No single host can access all of the requested datastores. 
  Installation cannot continue.</pre>
- If you specify different datastores in the different datastore options, and if only one host in a cluster can access all of them, `vic-machine create` succeeds with a warning.
    <pre>Only one host can access all of the image/container/volume datastores. 
  This may be a point of contention/performance degradation and HA/DRS 
  may not work as intended.</pre> 
- VCHs do not support datastore name changes. If a datastore changes name after you have deployed a VCH that uses that datastore, that VCH will no longer function.


### `--image-store` <a id="image"></a>

Short name: `-i`

The datastore in which to store container image files, container VM files, and the files for the VCH. The `--image-store` option is **mandatory** if there is more than one datastore in your vSphere environment. If there is only one datastore in your vSphere environment, the `--image-store` option is not required. 

If you do not specify the `--image-store` option and multiple possible datastores exist, or if you specify an invalid datastore name, `vic-machine create` fails and suggests valid datastores in the failure message. 

If you are deploying the VCH to a vCenter Server cluster, the datastore that you designate in the `image-store` option must be shared by at least two ESXi hosts in the cluster. Using non-shared datastores is possible, but limits the use of vSphere features such as vSphere vMotion&reg; and VMware vSphere Distributed Resource Scheduler&trade; (DRS).

To specify a whole datastore as the image store, specify the datastore name in the `--image-store` option:

<pre>--image-store <i>datastore_name</i></pre>

If you designate a whole datastore as the image store, `vic-machine` creates the following set of folders in the target datastore: 

-  <code><i>datastore_name</i>/VIC/<i>vch_uuid</i>/images</code>, in which to store all of the container images that you pull into the VCH.
- <code><i>datastore_name</i>/<i>vch_name</i></code>, that contains the VM files for the VCH.
- <code><i>datastore_name</i>/<i>vch_name</i>/kvstores</code>, a key-value store folder for the VCH.

You can specify a datastore folder to use as the image store by specifying a path in the `--image-store` option</code>: 

<pre>--image-store <i>datastore_name</i>/<i>path</i></pre> 

If the folder that you specify in `/path` does not already exist, `vic-machine create` creates it.

If you designate a datastore folder as the image store, `vic-machine` creates the following set of folders in the target datastore:

- <code><i>datastore_name</i>/<i>path</i>/VIC/<i>vcu_uuid</i>/images</code>, in which to store all of the container images that you pull into the VCH. 
- <code><i>datastore_name</i>/<i>vch_name</i></code>, that contains the VM files for the VCH. This is the same as if you specified a datastore as the image store.
- <code><i>datastore_name</i>/<i>vch_name</i>/kvstores</code>, a key-value store folder for the VCH. This is the same as if you specified a datastore as the image store.

By specifying the path to a datastore folder in the `--image-store` option, you can designate the same datastore folder as the image store for multiple VCHs. In this way, `vic-machine create` creates only one `VIC` folder in the datastore, at the path that you specify. The `VIC` folder contains one <code><i>vch_uuid</i>/images</code> folder for each VCH that you deploy. By creating one <code><i>vch_uuid</i>/images</code> folder for each VCH, vSphere Integrated Containers Engine limits the potential for conflicts of image use between VCHs, even if you share the same image store folder between multiple hosts.

When container developers create containers, vSphere Integrated Containers Engine stores the files for container VMs at the top level of the image store, in folders that have the same name as the containers.


### `--volume-store` <a id="volume-store"></a>

Short name: `--vs`

The datastore in which to create volumes when container developers use the `docker volume create` command. You can specify either a datastore that is backed by vSphere or an NFS share point as the volume store.

If you are deploying the VCH to a vCenter Server cluster, vSphere datastores that you designate in the `volume-store` option should be shared by at least two ESXi hosts in the cluster. Using non-shared datastores is possible and `vic-machine create` succeeds, but it issues a warning that this configuration limits the use of vSphere features such as vSphere vMotion and DRS.

If you use NFS volume stores, container developers can share the data in those volumes between containers by attaching the same volume to multiple containers. For example, you can use shared NFS volume stores to share configuration information between containers, or  to allow containers to access the data of another container. To use shared NFS volume stores, it is recommended that the NFS share points that you designate as the volume stores be directly accessible by the network that you use as the container network. For information about container networks, see the description of the [`--container-network`](#container-network) option.

The label that you specify is the volume store name that Docker uses. For example, the volume store label appears in the information for a VCH when container developers run `docker info`. Container developers specify the volume store label in the <code>docker volume create --opt VolumeStore=<i>volume_store_label</i></code> option when they create a volume.

**IMPORTANT**: The volume store label must be unique.

If you specify an invalid vSphere datastore name or an invalid NFS share point URL, `vic-machine create` fails and suggests valid datastores. 

**IMPORTANT** If you do not specify the `volume-store` option, no  volume store is created and container developers cannot create containers with volumes. You can add volume stores to a VCH after deployment by running `vic-machine configure --volume-store`. For information about adding volume stores after deployment, see [Add Volume Stores](configure_vch.md#volumes) in Configure Virtual Container Hosts.

- To specify a vSphere datastore, provide the datastore name and the volume store label. 

    <pre>--volume-store <i>datastore_name</i>:<i>volume_store_label</i></pre>

    You can optionally use the `ds://` prefix to specify a datastore that is backed by vSphere.

    <pre>--volume-store ds://<i>datastore_name</i>:<i>volume_store_label</i></pre>

    If you specify a vSphere datastore without specifying a path to a specific datastore folder, `vic-machine create` creates a folder named `VIC/volumes` at the top level of the target datastore. Any volumes that container developers create will appear in the `VIC/volumes` folder. 

- If you specify a vSphere datastore and a datastore path, `vic-machine create` creates a folder named `volumes` in the location that you specify in the datastore path. If the folders that you specify in the path do not already exist on the datastore, `vic-machine create` creates the appropriate folder structure.  Any volumes that container developers create will appear in the <code><i>path</i>/volumes</code> folder. 

    <pre>--volume-store <i>datastore_name</i>/<i>datastore_path</i>:<i>volume_store_label</i></pre>    

    The `vic-machine create` command creates the `volumes` folder independently from the folders for VCH files so that you can share volume stores between VCHs. If you delete a VCH, any volumes that the VCH managed will remain available in the volume store unless you specify the `--force` option when you delete the VCH. You can then assign an existing volume store that already contains data to a newly created VCH. 

     **IMPORTANT**: If multiple VCHs will use the same datastore for their volume stores, specify a different datastore folder for each VCH. Do not designate the same datastore folder as the volume store for multiple VCHs.

- To specify an NFS share point as a volume store, use the `nfs://` prefix and the path to a shared mount point.

    **IMPORTANT**: When container developers run `docker info` or `docker volume ls` against a VCH, there is currently no indication whether a volume store is backed by vSphere or by an NFS share point. Consequently, you should include an indication that a volume store is an NFS share point in the volume store label. 

    <pre>nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:<i>nfs_volume_store_label</i></pre>
- You can specify the `volume-store` option multiple times, to create multiple volume stores for the VCH.

- You can also specify the URL, UID, GID, and access protocol of a shared NFS mount point when you specify an NFS share point.
    <pre>--volume-store nfs://<i>datastore_address</i>/<i>path_to_share_point</i>?uid=1234&gid=5678&proto=tcp:<i>nfs_volume_store_label</i></pre>

- If you do not specify a UID and GID, vSphere Integrated Containers Engine uses the `anon` UID and GID when creating and interacting with the volume store. The `anon` UID and GID is 1000.    

-  You cannot specify the root folder of an NFS server as a volume store. 
    
- If you only require one volume store, set the volume store label to `default`. If you set the volume store label to `default`, container developers do not need to specify the <code>--opt VolumeStore=<i>volume_store_label</i></code> option when they run `docker volume create`. 

    **NOTE**: If container developers intend to use `docker create -v` to create containers that are attached to anonymous or named volumes, you must create a volume store with a label of `default`.

    <pre>--volume-store <i>datastore_name</i>:default</pre>
    <pre>--volume-store nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:default</pre>
 
- You can specify the `volume-store` option multiple times, to create multiple volume stores for the VCH. You can add a mixture of vSphere datastores and NFS share points to a VCH.

    <pre>--volume-store <i>datastore_name</i>/path:<i>volume_store_label_1</i>
--volume-store <i>datastore_name</i>/<i>path</i>:<i>volume_store_label_2</i>
--volume-store nfs://<i>datastore_name</i>/<i>path_to_share_point</i>:<i>nfs_volume_store_label</i>
</pre>

## General Deployment Options <a id="deployment"></a>

The `vic-machine` utility provides options to customize the VCH.

### `--name` ###

Short name: `-n`

A name for the VCH. If not specified, `vic-machine` sets the name of the VCH to `virtual-container-host`. If a VCH of the same name exists on the ESXi host or in the vCenter Server inventory, or if a folder of the same name exists in the target datastore, `vic-machine create` creates a folder named <code><i>vch_name</i>_1</code>. If the name that you provide contains unsupported characters, `vic-machine create` fails with an error.
 
<pre>--name <i>vch_name</i></pre>

### `--memory` ###

Short name: `--mem`

Limit the amount of memory that is available for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the memory limit value in MB. If not specified, `vic-machine create` sets the limit to 0 (unlimited).

<pre>--memory 1024</pre>

### `--cpu` ###

Short name: None

Limit the amount of CPU capacity that is available for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the CPU limit value in MHz. If not specified, `vic-machine create` sets the limit to 0 (unlimited).

<pre>--cpu 1024</pre>

### `--force` ###

Short name: `-f`

Forces `vic-machine create` to ignore warnings and non-fatal errors and continue with the deployment of a VCH. Errors such as an incorrect compute resource still cause the deployment to fail.

If your vSphere environment uses untrusted, self-signed certificates, you can bypass certificate thumbprint verification by specifying the `--force` option instead of `--thumbprint`. 

**CAUTION**: It is not recommended to use `--force` to bypass thumbprint verification in production environments. Using `--force` in this way exposes VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials.

<pre>--force</pre>

### `--timeout` ###

Short name: none

The timeout period for uploading the vSphere Integrated Containers Engine files and ISOs to the ESXi host, and for powering on the VCH. Specify a value in the format `XmYs` if the default timeout of 3m0s is insufficient.

<pre>--timeout 5m0s</pre> 


# Advanced Options <a id="advanced"></a>

The options in this section are exposed in the `vic-machine create` help if you run <code>vic-machine create --extended-help</code>, or <code>vic-machine create -x</code>. 

## Specify a Static IP Address for the VCH Endpoint VM <a id="static-ip"></a>





## Advanced Resource Management Options <a id="adv-mgmt"></a>

You can set limits on the memory and CPU shares and reservations on the VCH. For information about memory and CPU shares and reservations, see [Allocate Memory Resources](https://pubs.vmware.com/vsphere-65/topic/com.vmware.vsphere.vm_admin.doc/GUID-49D7217C-DB6C-41A6-86B3-7AFEB8BF575F.html), and [Allocate CPU Resources](https://pubs.vmware.com/vsphere-65/topic/com.vmware.vsphere.vm_admin.doc/GUID-6C9023B2-3A8F-48EB-8A36-44E3D14958F6.html) in the vSphere documentation.

### `--memory-reservation` ###

Short name: `--memr`

Reserve a quantity of memory for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the memory reservation value in MB. If not specified, `vic-machine create` sets the reservation to 1.

<pre>--memory-reservation 1024</pre>

### `--memory-shares` ###

Short name: `--mems`

Set memory shares on the VCH vApp in vCenter Server, or on the VCH resource pool on an ESXi host.  This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the share value as a level or a number, for example `high`, `normal`, `low`, or `163840`. If not specified, `vic-machine create` sets the share to `normal`.

<pre>--memory-shares low</pre>

### `--cpu-reservation` ###

Short name: `--cpur`

Reserve a quantity of CPU capacity for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool.  Specify the CPU reservation value in MHz. If not specified, `vic-machine create` sets the reservation to 1.

<pre>--cpu-reservation 1024</pre>

### `--cpu-shares` ###

Short name: `--cpus`

Set CPU shares on the VCH vApp in vCenter Server, or on the VCH resource pool on an ESXi host.  This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the share value as a level or a number, for example `high`, `normal`, `low`, or `163840`. If not specified, `vic-machine create` sets the share to `normal`.

<pre>--cpu-shares low</pre>

### `--endpoint-cpu ` ###

Short name: none

The number of virtual CPUs for the VCH endpoint VM. The default is 1. Set this option to increase the number of CPUs in the VCH endpoint VM.

**NOTE** Always use the `--cpu` option instead of the `--endpoint-cpu` option to increase the overall CPU capacity of the VCH vApp, rather than increasing the number of CPUs on the VCH endpoint VM. The `--endpoint-cpu` option is mainly intended for use by VMware Support.

<pre>--endpoint-cpu <i>number_of_CPUs</i></pre>

### `--endpoint-memory ` ###

Short name: none

The amount of memory for the VCH endpoint VM. The default is 2048MB. Set this option to increase the amount of memory in the VCH endpoint VM if the VCH will pull large container images.

**NOTE** With the exception of VCHs that pull large container images, always use the `--memory` option instead of the `--endpoint-memory` option to increase the overall amount of memory for the VCH vApp, rather than on the VCH endpoint VM. Use `docker create -m` to set the memory on container VMs. The `--endpoint-memory` option is mainly intended for use by VMware Support.

<pre>--endpoint-memory <i>amount_of_memory</i></pre>


## Other Advanced Options <a id="adv-other"></a>

### `--base-image-size` ###

Short name: None

The size of the base image from which to create other images. You should not normally need to use this option. Specify the size in `GB` or `MB`. The default size is 8GB. Images are thin-provisioned, so they do not usually consume 8GB of space.  

<pre>--base-image-size 4GB</pre>

### `--container-store` ###

Short name: `--cs`

The `container-store` option is not enabled. Container VM files are stored in the datastore that you designate as the image store. 

### `--appliance-iso` ###

Short name: `--ai`

The path to the ISO image from which the VCH appliance boots. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--appliance-iso <i>path_to_ISO_file</i>/appliance.iso</pre>

### `--bootstrap-iso` ###

Short name: `--bi`

The path to the ISO image from which to boot container VMs. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>

### `--use-rp` ###

Short name: none

Deploy the VCH appliance to a resource pool on vCenter Server rather than to a vApp. If you specify this option, `vic-machine create` creates a resource pool with the same name as the VCH.

**NOTE**: If you specify both of the `--ops-user` and  `--use-rp` options when you create a VCH, you must specify an additional permission when you create the roles for the operations user. For information about operations user roles and permissions, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

<pre>--use-rp</pre>


### `--debug` <a id="debug"></a>
Short name: `-v`

Deploy the VCH with more verbose levels of logging, and optionally modify the behavior of `vic-machine` for troubleshooting purposes. Specifying the `--debug` option increases the verbosity of the logging for all aspects of VCH operation, not just deployment. For example, by setting the `--debug` option, you increase the verbosity of the logging for VCH initialization, VCH services, container VM initialization, and so on. If not specified, the `--debug` value is set to 0 and verbose logging is disabled.

**NOTE**: Do not confuse the `vic-machine create --debug` option with the `vic-machine debug` command, that enables access to the VCH endpoint VM. For information about `vic-machine debug`, see [Debugging the VCH](debug_vch.md). 

When you specify `vic-machine create --debug`, you set a debugging level of 1, 2, or 3. Setting `--debug` to 2 or 3 changes the behavior of `vic-machine create` as well as increasing the level of verbosity of the logs:

- `--debug 1` Provides verbosity in the logs, with no other changes to `vic-machine` behavior. This is the default setting.
- `--debug 2` Exposes servers on more interfaces, launches `pprof` in container VMs.
- `--debug 3` Disables recovery logic and logs sensitive data. Disables the restart of failed components and prevents container VMs from shutting down. Logs environment details for user application, and collects application output in the log bundle. This is the maximum  supported debugging level.

Additionally, deploying a VCH with a `--debug 3` enables SSH access to the VCH endpoint VM console by default, with a root password of `password`, without requiring you to run the `vic-machine debug` command. This functionality enables you to perform targeted interactive diagnostics in environments in which a VCH endpoint VM failure occurs consistently and in a fashion that prevents `vic-machine debug` from functioning. 

**IMPORTANT**: There is no provision for persistently changing the default root password. Only use this configuration for debugging in a secured environment.

### `--syslog-address` <a id="syslog"></a>

Short name: None

Configure a VCH so that it sends the logs in the `/var/log/vic` folder on the VCH endpoint VM to a syslog endpoint that is not located in the VCH. The VCH also sends container logs to the same syslog endpoint.

You specify the address and port of the syslog endpoint in the `--syslog-address` option. You must also specify whether the transport protocol is UDP or TCP. If you do not specify a port, the default port is 514.

<pre>--syslog-address udp://<i>syslog_host_address</i>[:<i>port</i>]</pre>
<pre>--syslog-address tcp://<i>syslog_host_address</i>[:<i>port</i>]</pre>

### `--container-name-convention` <a id="container-name-convention"></a>

Short name: `--cnc`

Enforce a naming convention for container VMs, that applies a prefix to the names of all container VMs that run in a VCH. Applying a naming convention to container VMs facilitates organizational requirements such as chargeback. The container naming convention applies to the display name of the container VM that appears in the vSphere Client, not to the container name that Docker uses.

You specify the container naming convention by providing a prefix to apply to container names, and adding `-{name}` or `-{id}` to specify whether to use the container name or the container ID for the second part of the container VM display name. If you specify `-{name}`, the container VM display names use either the name that Docker generates, or a name that the container developer specifies in `docker run --name` when they run the container.

<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}</pre>
<pre>--container-name-convention <i>cVM_name_prefix</i>-{id}</pre>