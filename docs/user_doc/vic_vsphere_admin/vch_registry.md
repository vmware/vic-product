# Configure Registry Access #

If you use vSphere Integrated Containers Registry, or if container developers need to access Docker images that are stored in other private registry servers, you must configure virtual container hosts (VCHs) to allow them to connect to these private registry servers when you deploy the VCHs. VCHs can connect to both secure and insecure private registry servers. You can also configure VCHs so that they can only access images from a whitelist of approved registries.

- [Obtain the vSphere Integrated Containers Registry Certificate](#regcert)
- [Options](#options)
  - [Whitelist Registry Mode](#whitelist-registry)
  - [Insecure Registry Access](#insecure-registry)
  - [Additional Registry Certificates](#registry-ca)
- [Example `vic-machine` Commands](#examples)
  - [Authorize Access to a Whitelist of Registries](#whitelist)
  - [Authorize Access to an Insecure Private Registry Server](#insecureregistry)
  - [Authorize Access to Secure Registries and vSphere Integrated Containers Registry](#secureregistry)

## Obtain the vSphere Integrated Containers Registry Certificate <a id="regcert"></a>

To use vSphere Integrated Containers Engine with vSphere Integrated Containers Registry, you must obtain the registry certificate and pass it to a VCH when you create that VCH.

When you deployed the vSphere Integrated Containers appliance, vSphere Integrated Containers Registry auto-generated a Certificate Authority (CA) certificate. You can download the registry CA certificate from the vSphere Integrated Containers Management Portal.

**Prerequisites**

- You downloaded the vSphere Integrated Containers Engine bundle from  http://<i>vic_appliance_address</i>.
- Obtain the vCenter Server or ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and log in with a vSphere administrator or Cloud administrator user account.

    vSphere administrator accounts for the Platform Service Controller with which vSphere Integrated Containers is registered are automatically granted Cloud Admin access in the management portal.
2. Go to **Administration** > **Configuration**, and click the link to download the **Registry Root Cert**.

**What to Do Next**

Use `vic-machine create` to deploy a VCH, specifying the registry's CA certificate by using the [`--registry-ca`](vch_registry.md#registry-ca) option. For an example of the vic-machine command with which to deploy a VCH that accesses vSphere Integrated Containers Registry, see [Authorize Access to Secure Registries and vSphere Integrated Containers Registry](#secureregistry).

## Options <a id="options"></a>

You configure access from a VCH to a registry server by using the [`--registry-ca`](#registry-ca), [`--insecure-registry`](#insecure-registry), and [`--whitelist-registry`](#whitelist-registry) options.

### Whitelist Registry Mode <a id="whitelist-registry"></a>

#### Create VCH Wizard

xxx

#### vic-machine Option 

`--whitelist-registry`, `--wr`

You can restrict the registries to which a VCH allows access by setting the `--whitelist-registry` option. You can specify `--whitelist-registry` multiple times to allow access to multiple registries. If you specify `--whitelist-registry` at least once, the VCH runs in whitelist mode. In whitelist mode, users can only access those registries that you have specified in the `--whitelist-registry` option. Users cannot access any registries that are not in the whitelist, even if they are public registries, such as Docker Hub.

You can specify whitelisted registries in the following formats:
 
- IP addresses or FQDN to identify individual registry instances. During deployment, `vic-machine` validates the IP address of the registry.
- CIDR formatted ranges, for example, 192.168.1.1/24. If you specify a CIDR range, the VCH adds to the whitelist any IP addresses within that subnet. Note that `vic-machine` does not validate CIDR defined ranges during deployment.
- Wildcard domains, for example, . *.company.com. If you specify a wildcard domain, the VCH adds to the whitelist any IP addresses or FQDNs that it can validate against that domain. A numeric IP address causes VCHs to perform a reverse DNS lookup to validate against that wild card domain. Note that `vic-machine` does not validate wildcard domains during deployment. 

You use `--whitelist-registry` in combination with the `--registry-ca`  and `--insecure-registry` options. You can configure a VCH so that it includes both secure and insecure registries in its whitelist.

#### Whitelisting Secure Registries

VCHs include a base set of well-known certificates from public CAs. If a registry requires a certificate to authenticate access, and if that registry does not use one of the CAs in the VCH, you must provide the CA certificate for that registry in the `--registry-ca` option. You must also specify that registry in the `--whitelist-registry` option if the VCH is running in whitelist mode.

- If you provide a certificate in the `--registry-ca` option but you do not also specify that registry in the `--whitelist-registry` option, the VCH does not allow access to that registry. 
- If you specify a registry in the `--whitelist-registry` option, but you do not provide a certificate in `--registry-ca` and the registry's CA is not in the set of well-known certificates in the VCH, the VCH does not allow access to that registry.

**Usage**: 

<pre>--whitelist-registry <i>registry_address</i> 
--registry-ca <i>path_to_ca_cert_1</i>
</pre>

#### Whitelisting Insecure Registries

You can add registries that you designate as insecure registries to the whitelist by specifying both of the `--insecure-registry` and `--whitelist-registry` options. 

- If you specify a registry in the `--whitelist-registry` option, but you do not specify that registry in `--insecure-registry`, the VCH attempts to verify the registry by using certificates. If it does not find a certificate, the VCH does not allow access to that registry.
- If you specify a registry in the `--insecure-registry` option but you do not specify this registry in `--whitelist-registry`, `vic-machine` adds the registry to the whitelist only if at least one other registry is specified in `--whitelist-registry`.

**Usage**: 

<pre>--whitelist-registry <i>registry_address</i> 
--insecure-registry <i>registry_address</i>
</pre>

### Insecure Registry Access <a id="insecure-registry"></a>

#### Create VCH Wizard

xxx

#### vic-machine Option 

`--insecure-registry`, `--dir`

If you set the `--insecure-registry` option, the VCH does not verify the certificate of that registry when it pulls images. Insecure private registries are not recommended in production environments.

If you authorize a VCH to connect to an insecure private registry server, the VCH first attempts to access the registry server via HTTPS, then attempts to connect with HTTP if access via HTTPS fails. VCHs always use HTTPS when connecting to registry servers for which you have not authorized insecure access.

**NOTE**: You cannot use `--insecure-registry` to configure VCHs to connect to vSphere Integrated Containers Registry instances. Connections to vSphere Integrated Containers Registry always require HTTPS and a certificate.

You can specify `--insecure-registry` multiple times if multiple insecure registries are permitted. If the registry server listens on a specific port, add the port number to the URL.

**Usage**: 

<pre>--insecure-registry <i>registry_URL_1</i>
--insecure-registry <i>registry_URL_2</i>:<i>port_number</i>
</pre>


### Additional Registry Certificates <a id="registry-ca"></a>

#### Create VCH Wizard

xxx

#### vic-machine Option 

`--registry-ca`, `--rc`

The path to a CA certificate that can validate the server certificate of a private registry. You can specify `--registry-ca` multiple times to specify multiple CA certificates for different registries. This allows a VCH to connect to multiple registries. 

The use of registry certificates is independent of the Docker client security options that you specify. For example, it is possible to use the `--no-tls` option to disable TLS authentication between Docker clients and the VCH, and to use the `--registry-ca` option to enable TLS authentication  between the VCH and a private registry. 

You must use this option to allow a VCH to connect to vSphere Integrated Containers Registry. vSphere Integrated Containers Registry does not permit insecure connections.

**Usage**: 

<pre>--registry-ca <i>path_to_ca_cert_1</i>
--registry-ca <i>path_to_ca_cert_2</i>
</pre>

## Examples <a id="examples"></a>

The examples in this section demonstrate how to configure a VCH to use a secure private registry server, an insecure private registry server, and how to add registries to the whitelist for a VCH,

- [Authorize Access to a Whitelist of Registries](#whitelist)
- [Authorize Access to an Insecure Private Registry Server](#insecureregistry)
- [Authorize Access to Secure Registries and vSphere Integrated Containers Registry](#secureregistry)

### Authorize Access to a Whitelist of Registries <a id="whitelist"></a>

To restrict the registries to which a VCH allows access, set the `--whitelist-registry` option. You can specify `--whitelist-registry` multiple times to add multiple registries to the whitelist. You use `--whitelist-registry` in combination with the `--registry-ca`  and `--insecure-registry` options.

This example `vic-machine create` command deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Adds to the whitelist:
  - The single registry instance running at 10.2.40.40:443
  - All registries running in the range 10.2.2.1/24 
  - All registries in the domain *.mycompany.com
- Provides the CA certificate for the registry instance 10.2.40.40:443.
- Adds a single instance of an insecure registry to the whitelist by specifying `--insecure-registry`.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--whitelist-registry 10.2.40.40:443 
--whitelist-registry 10.2.2.1/24 
--whitelist-registry=*.mycompany.com
--registry-ca=/home/admin/mycerts/ca.crt
--insecure-registry=192.168.100.207  
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Authorize Access to an Insecure Private Registry Server <a id="insecureregistry"></a>

This example shows how to use `--insecure-registry` to authorize access to two insecure registry instances,  without verifying the certificates for those registries.

**NOTE**: You cannot configure VCHs to connect to vSphere Integrated Containers Registry instances as insecure registries. Connections to vSphere Integrated Containers Registry always require HTTPS and a certificate.

This example `vic-machine create` command deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Authorizes the VCH to pull Docker images from the insecure private registry servers located at the URLs <i>registry_URL_1</i> and <i>registry_URL_2</i>.
- The registry server at <i>registry_URL_2</i> listens for connections on port 5000. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--insecure-registry <i>registry_URL_1</i>
--insecure-registry <i>registry_URL_2:5000</i>
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Authorize Access to Secure Registries and vSphere Integrated Containers Registry <a id="secureregistry"></a>

This example shows how to use `--registry-ca` to authorize access to a vSphere Integrated Containers Registry instance or to another secure registry.

This example `vic-machine create` command deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Authorizes the VCH to pull Docker images from a secure private registry server, for example a vSphere Integrated Containers Registry instance, for which you have downloaded the certificate to `/home/admin/mycerts/ca.crt`.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch_registry
--thumbprint <i>vcenter_server_certificate_thumbprint</i>
--no-tlsverify
--registry-ca /home/admin/mycerts/ca.crt
</pre>