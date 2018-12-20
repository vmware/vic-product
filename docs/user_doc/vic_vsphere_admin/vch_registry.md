# Configure Registry Access #

If you use vSphere Integrated Containers Registry, or if container developers need to access Docker images that are stored in other private registry servers, you must configure virtual container hosts (VCHs) to allow them to connect to these private registry servers when you deploy the VCHs. VCHs can connect to both secure and insecure private registry servers. You can also configure VCHs so that they can only access images from a whitelist of approved registries.

- [Options](#options)
  - [Whitelist Registry Mode](#whitelist-registry)
     - [Whitelisting Secure Registries](#vch-whitelist-secure) 
     - [Whitelisting Insecure Registries](#vch-whitelist-insecure)
     - [VCH Whitelists and Registry Lists in vSphere Integrated Containers Management Portal](#vch-whitelist-mp)
     - [VCH Whitelists and Content Trust](#vch-content-trust)
  - [Insecure Registry Access](#insecure-registry)
  - [Additional Registry Certificates](#registry-ca)
- [Examples](#examples)
  - [Authorize Access to a Whitelist of Secure and Insecure Registries](#whitelist)
  - [Authorize Access to Secure and Insecure Private Registry Servers](#secure-insecure)
- [What to Do Next](#whatnext)

## Options <a id="options"></a>

The following sections each correspond to an entry in the **Registry Access** page of the Create Virtual Container Host wizard. Each section also includes a description of the corresponding `vic-machine create` option. 

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### Whitelist Registry Mode <a id="whitelist-registry"></a>

You can restrict the registries to which a VCH allows access by setting the VCH in whitelist registry mode. You can allow VCHs to access multiple registries. In whitelist mode, users can only access those registries that you have specified. Users cannot access any registries that are not in the whitelist, even if they are public registries, such as Docker Hub. You can configure a VCH so that it includes both secure and insecure registries in its whitelist.

You can specify whitelisted registries in the following formats:
 
- IP addresses or FQDN to identify individual registry instances. During deployment, vSphere Integrated Containers Engine validates the IP address of the registry.
- CIDR formatted ranges, for example, 192.168.1.1/24. If you specify a CIDR range, the VCH adds to the whitelist any IP addresses within that subnet. Note that vSphere Integrated Containers Engine does not validate CIDR defined ranges during deployment.
- Wildcard domains, for example, *.example.com. If you specify a wildcard domain, the VCH adds to the whitelist any IP addresses or FQDNs that it can validate against that domain. A numeric IP address causes VCHs to perform a reverse DNS lookup to validate against that wild card domain. Note that vSphere Integrated Containers Engine does not validate wildcard domains during deployment. 

#### Whitelisting Secure Registries <a id="vch-whitelist-secure"></a>

VCHs include a base set of well-known certificates from public CAs. If a registry requires a certificate to authenticate access, and if that registry does not use one of the CAs that the VCH holds, you must provide the CA certificate for that registry to the VCH. If the VCH is running in whitelist mode, you must also add that registry to the whitelist.

- If you provide a registry certificate but you do not also specify that registry in the whitelist, the VCH does not allow access to that registry. 
- If you specify a registry in the whitelist, but you do not provide a certificate and the registry's CA is not in the set of well-known certificates in the VCH, the VCH does not allow access to that registry.
- If you specify a registry as insecure, it is added to the whitelist.

#### Whitelisting Insecure Registries <a id="vch-whitelist-insecure"></a>

You can add registries that you designate as insecure registries to the whitelist. If you designate a registry as an insecure registry, VCHs do not verify the certificate of that registry when they pull images. 

If you add a registry to the whitelist, but you do not specify that registry as an insecure registry, the VCH attempts to verify the registry by using certificates. If it does not find a certificate, the VCH does not allow access to that registry.

#### VCH Whitelists and Registry Lists in vSphere Integrated Containers Management Portal <a id="vch-whitelist-mp"></a>

If you intend to use a VCH with vSphere Integrated Containers Management Portal, the management portal allows you to provision containers from lists of registries that Management Portal administrators and DevOps administrators configure. However, if you deploy a VCH with whitelist mode enabled, and if the whitelist on the VCH is more restrictive than the global and project registry lists in management portal, you can only use management portal to provision containers from registries that the VCH permits in its whitelist, even if the VCH is included in a project that permits other registries. 

As a consequence of this, when using whitelist mode on VCHs that you intend to register with vSphere Integrated Containers Management Portal, you must consider the following points:

- If you enable whitelist mode on a VCH, the whitelist on the VCH should be broader in scope than the lists that Management Portal administrators and DevOps administrators configure in the management portal. For example, you can include a wildcard domain in the VCH whitelist, such as `*.example.com`, and then more finely grained domains in the project lists, such as `registry1.example.com`, `registry2.example.com`, and so on.
- If the whitelist on the VCH is more restrictive than the registry lists in management portal, users cannot provision containers from the registries that are not whitelisted by the VCH, even if they are present in the management portal lists.
- If the whitelist on the VCH is less restrictive than the registry lists configured in management portal, if users connect directly to the VCH, they will be able to pull images from registries that management portal would not permit.
- After you deploy a VCH and add it in a project in management portal, if you encounter a problem because the VCH whitelist is more restrictive than the management portal registry lists, you must redeploy the VCH with either no whitelist, a more permissive whitelist, or a whitelist that exactly matches the lists in management portal. You cannot modify a VCH whitelist after the initial deployment of the VCH.

#### VCH Whitelists and Content Trust <a id="vch-content-trust"></a>

If you register a VCH with a project in vSphere Integrated Containers Management Portal, and if content trust is enabled on that project, vSphere Integrated Containers automatically modifies the whitelist settings on the VCH in order to enforce content trust. 

- For general information about content trust, see [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/) in the Docker documentation. 
- For information about content trust in vSphere Integrated Containers, see [Enabling Content Trust in Projects](../vic_cloud_admin/content_trust.md) in *vSphere Integrated Containers Management Portal Administration*.

The following example describes how enabling content trust on a project affects a VCH that is not running in whitelist mode:

- Deploy a VCH without enabling whitelist mode.
- Register the VCH with a project in vSphere Integrated Containers Management Portal.
- If content trust is enabled on the project, or if you subsequently enable content trust after adding the VCH to the project, vSphere Integrated Containers automatically enables whitelist mode on the VCH. 
- vSphere Integrated Containers adds the project registry to the VCH whitelist.
- If the project includes more than one registry, only the registry instance that is running in the vSphere Integrated Containers appliance is added to the whitelist. 
- The VCH can now only pull signed and verified images from the registry instance that is running in the vSphere Integrated Containers appliance that includes the project.

The following example demonstrates how enabling content trust on a project affects a VCH that is already running in whitelist mode:

- Deploy a VCH with whitelist mode enabled, and with one or more registries in the whitelist.
- Register the VCH with a project in vSphere Integrated Containers Management Portal.
- If content trust is enabled on the project, or if you subsequently enable content trust after adding the VCH to the project, vSphere Integrated Containers automatically restricts the whitelist that you configured on the VCH.
- The VCH whitelist now includes only the registry instance that is running in the vSphere Integrated Containers appliance. 
- The VCH can now only pull signed and verified images from the registry instance that is running in the vSphere Integrated Containers appliance that includes the project.

If you subsequently disable content trust on a project, or remove a VCH from a project that implements content trust, the VCH reverts to the whitelist configuration with which it was deployed.

- If the VCH was not deployed with whitelist mode enabled, whitelist mode is disabled.
- If the VCH was deployed with a whitelist, this whitelist is restored.

If you delete the vSphere Integrated Containers appliance without removing the VCH from the project, the VCH remains paired with that non-existent project. You must run `vic-machine configure` on the VCH to restore the whitelist settings.

#### Create VCH Wizard

1. Set the **Whitelist registry mode** switch to the green ON position.
2. In the **Whitelist registries** text box, enter the IP address or FQDN and port number for the registry server, or enter a wildcard domain.
3. Select **Secure** or **Insecure** from the drop-down menu, to specify whether the registry requires a certificate for access.
4. Optionally click **+** to add more registries to the whitelist.

If you select **Secure** for a given registry, you must also provide a certificate for that registry. For information about providing certificates, see [Additional Registry Certificates](#registry-ca) below.

#### vic-machine Option 

`--whitelist-registry`, `--wr`

If you specify `--whitelist-registry` at least once when you run `vic-machine create`, the VCH runs in whitelist mode. 

You use `--whitelist-registry` in combination with the `--registry-ca`  or `--insecure-registry` options, to either provide the registry certificate or to allow insecure access to that registry. If you specify a registry as an insecure registry but you do not specify this registry in the whitelist, vSphere Integrated Containers Engine automatically adds the registry to the whitelist only if whitelist mode is activated by specifying at least one other registry in `--whitelist-registry`.

<pre>--whitelist-registry <i>registry_address</i> 
--registry-ca <i>path_to_ca_cert</i>
</pre>

<pre>--whitelist-registry <i>registry_address</i> 
--insecure-registry <i>registry_address</i>
</pre>

## Insecure Registry Access <a id="insecure-registry"></a>

If you designate a registry server as an insecure registry, the VCH does not verify the certificate of that registry when it pulls images. Insecure registries are not recommended in production environments.

If you authorize a VCH to connect to an insecure registry server, the VCH first attempts to access the registry server via HTTPS, then attempts to connect with HTTP if access via HTTPS fails. VCHs always use HTTPS when connecting to registry servers for which you have not authorized insecure access.

**NOTE**: You cannot designate vSphere Integrated Containers Registry instances as insecure registries. Connections to vSphere Integrated Containers Registry always require HTTPS and a certificate.

### Create VCH Wizard

1. Leave the **Whitelist registry mode** switch in the gray OFF position.

    If you are using the Create Virtual Container Host wizard and you activate whitelist registry mode, you designate registries as insecure when you add them to the whitelist.

2. In the **IP or FQDN** text box under **Insecure registry access**, enter the IP address or FQDN for the registry server to designate as insecure.
3. If the registry server listens on a specific port, add the port number in the **Port** text box.
3. Optionally click the **+** button to add more registries to the list of insecure registries to which this VCH can connect.

### vic-machine Option 

`--insecure-registry`, `--dir`

You can specify `--insecure-registry` multiple times if multiple insecure registries are permitted. If the registry server listens on a specific port, add the port number to the URL.

**Usage**: 

<pre>--insecure-registry <i>registry_URL_1</i>
--insecure-registry <i>registry_URL_2</i>:<i>port_number</i>
</pre>

## Additional Registry Certificates <a id="registry-ca"></a>

If the VCH is to connect to secure registries, you must provide a CA certificate that can validate the server certificate of that registry. You can specify multiple CA certificates for different registries to allow a VCH to connect to multiple secure registries. 

**IMPORTANT**: You must use this option to allow a VCH to connect to  a vSphere Integrated Containers Registry instance. vSphere Integrated Containers Registry does not permit insecure connections. For information about how to obtain the vSphere Integrated Containers Registry certificate as a vSphere administrator, see [Download the vSphere Integrated Containers Registry Certificate](../vic_cloud_admin/download_reg_cert_admin.md) in *vSphere Integrated Containers Management Portal Administration*.

### Create VCH Wizard

1. Under **Additional registry certificates**, click **Select** and navigate to an existing certificate file for a registry server instance.
2. Optionally click **Select** again to upload additional CAs.

### vic-machine Option 

`--registry-ca`, `--rc`

You can specify `--registry-ca` multiple times to allow a VCH to connect to multiple secure registries.

<pre>--registry-ca <i>path_to_ca_cert_1</i>
--registry-ca <i>path_to_ca_cert_2</i>
</pre>

# Examples <a id="examples"></a>

This section provides examples of the combinations of options to use in in the **Registry Access** page of the Create Virtual Container Host wizard and in `vic-machine create` commands.

- [Authorize Access to a Whitelist of Secure and Insecure Registries](#whitelist)
- [Authorize Access to Secure and Insecure Private Registries](#secure-insecure)

## Authorize Access to a Whitelist of Secure and Insecure Registries <a id="whitelist"></a>

This example deploys a VCH with the following configuration:

- Adds to the whitelist:
  - A single vSphere Integrated Containers Registry instance that is running at 10.2.40.40:443
  - All registries running in the range 10.2.2.1/24 
  - All registries in the domain *.example.com
  - A single instance of an insecure registry running at 192.168.100.207, that is not in the IP range or domain specified previously.
- Provides the CA certificate for the vSphere Integrated Containers Registry instance in the whitelist.

### Prerequisite

Follow the instructions in [Download the vSphere Integrated Containers Registry Certificate](../vic_cloud_admin/download_reg_cert_admin.md) in *vSphere Integrated Containers Management Portal Administration*  to obtain the certificate file for your vSphere Integrated Containers Registry instance.

### Create VCH Wizard

1. Set the **Whitelist registry mode** switch to the green ON position.
4. In the **Whitelist registries** text box, enter `10.2.40.40:443` to add the vSphere Integrated Containers Registry instance to the whitelist.
5. Leave the drop-down menu for this registry set to **Secure**.
6. Click the **+** button, and enter `10.2.2.1/24` to add all registries that are running in that range to the whitelist.
7. Select **Insecure** from the drop-down menu to designate all registries in that range as insecure.
8. Click the **+** button, enter `*.example.com` to add all registries that are running in that domain to the whitelist, and select **Insecure** to designate those registries as insecure.
10. Click the **+** button, enter `192.168.100.207` to add the standalone registry to the whitelist, and select **Insecure** to designate those registries as insecure.
12.  Under **Additional registry certificates**, click **Select** and navigate to the CA certificate file for the vSphere Integrated Containers Registry instance that is running at 10.2.40.40:443.

### `vic-machine` Command

This example `vic-machine create` command deploys a VCH that uses the `--whitelist-registry`, `--registry-ca`, and `--insecure-registry` options to add a range of registries to its whitelist.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--whitelist-registry 10.2.40.40:443 
--whitelist-registry 10.2.2.1/24 
--whitelist-registry=*.example.com
--registry-ca=/home/admin/mycerts/ca.crt
--insecure-registry=192.168.100.207  
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Result

The VCH can only access the registries in the IP ranges and domain specified, as well as the standalone insecure registry at 192.168.100.207 and the vSphere Integrated Containers Registry instance at 10.2.40.40:443. It cannot access any other registries, even public registries like Docker Hub.

## Authorize Access to Secure and Insecure Private Registries <a id="secure-insecure"></a>

This example deploys a VCH with the following configuration:

- Allows the VCH to pull images from the following insecure registries:
  - All registries in the domain *.example.com
  - A single instance of an insecure registry running at 192.168.100.207.
- Provides the CA certificate for a vSphere Integrated Containers Registry instance.

### Prerequisite

Follow the instructions in [Download the vSphere Integrated Containers Registry Certificate](../vic_cloud_admin/download_reg_cert_admin.md) in *vSphere Integrated Containers Management Portal Administration*. to obtain the certificate file for your vSphere Integrated Containers Registry instance.

### Create VCH Wizard

1. Leave the **Whitelist registry mode** switch in the gray OFF position.
4. Under **Insecure registry access**, enter `*.example.com` to allow the VCH to access all registries that are running in that domain.
5. Click the **+** button, and enter `192.168.100.207` to allow the VCH to access the standalone registry at that address.
6. Under **Additional registry certificates**, click **Select** and navigate to the CA certificate file for your vSphere Integrated Containers Registry instance.

### `vic-machine` Command

This example `vic-machine create` uses the `--registry-ca` and `--insecure-registry` options to allow access to secure and insecure  registries.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--insecure-registry *.example.com
--insecure-registry 192.168.100.207:5000</i>
--registry-ca /home/admin/mycerts/ca.crt
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Result

The VCH can access the insecure registries in the domain specified, as well as the standalone insecure registry at 192.168.100.207 and the vSphere Integrated Containers Registry instance. Because whitelist mode is not enabled, it can also access public registries like Docker Hub.

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to configure the [Operations User](set_up_ops_user.md).