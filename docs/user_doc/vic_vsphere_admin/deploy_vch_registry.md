# Deploy a VCH for Use with vSphere Integrated Containers Registry

To use vSphere Integrated Containers Engine with vSphere Integrated Containers Registry, you must obtain the registry certificate and pass it to a virtual container host (VCH) when you create that VCH.

When you deployed the vSphere Integrated Containers appliance, vSphere Integrated Containers Registry auto-generated a Certificate Authority (CA) certificate. You can download the registry CA certificate from the vSphere Integrated Containers Management Portal.

**Prerequisites**

- You downloaded the vSphere Integrated Containers Engine bundle from  http://<i>vic_appliance_address</i>.
- Obtain the vCenter Server or ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md).

**Procedure**

1. Log in to the vSphere Integrated Containers Management Portal with a vSphere administrator, Cloud Admin or DevOps admin user account.

    vSphere administrator accounts for the Platform Service Controller with which vSphere Integrated Containers is registered are automatically granted Cloud Admin access.
2. Go to **Administration** > **Configuration**, and click the link to download the **Registry Root Cert**.
3. Use `vic-machine create` to deploy a VCH, specifying the registry's CA certificate by using the [`--registry-ca`](vch_installer_options.md#registry-ca) option. 

    You can configure the VCH to connect to multiple registries by specifying `--registry-ca` multiple times.

    For simplicity, this example deploys a VCH with the `--no-tls` flag, so that container application developers do not need to use a TLS certificate to connect a Docker client to the VCH. However, the connection between the VCH and the registry still requires certificate authentication.<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch_registry
--thumbprint <i>vcenter_server_certificate_thumbprint</i>
--no-tlsverify
--registry-ca=<i>cert_path</i>/ca.crt
</pre>

    Optionally, you can use the [`--whitelist-registry`](vch_installer_options.md#whitelist-registry) option to limit this VCH so that it can only access certain registries. This example limits access to registries in your company's domain, but you could specify the address of a specific registry, or a CIDR range of addresses.<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch_registry
--thumbprint <i>vcenter_server_certificate_thumbprint</i>
--no-tlsverify
--registry-ca=<i>cert_path</i>/ca.crt
--whitelist-registry *.mycompany.com
</pre>
     

**Result**

The VCH has a copy of the registry certificate and can connect to this vSphere Integrated Containers Registry instance.