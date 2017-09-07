# Deploy a VCH for Use with vSphere Integrated Containers Registry

To use vSphere Integrated Containers Engine with vSphere Integrated Containers Registry, you must obtain the registry certificate and pass it to a virtual container host (VCH) when you create that VCH.

If you did not provide a custom server certificate and private key for the registry to the OVA installer when you deployed the vSphere Integrated Containers appliance, vSphere Integrated Containers Registry auto-generates a Certificate Authority (CA) certificate, a server certificate, and a server private key. You can download the auto-generated CA certificates from the vSphere Integrated Containers Management Portal.

**Prerequisites**

- You selected the option to deploy vSphere Integrated Containers Registry when you deployed the vSphere Integrated Containers appliance.
- You downloaded the vSphere Integrated Containers Engine bundle from  http://<i>vic_appliance_address</i>.
- Obtain the vCenter Server or ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md).

**Procedure**

1. Obtain the CA certificate of the registry instance or instances to use with this VCH.

      1. Log in to the vSphere Integrated Containers Management Portal with a vSphere administrator, Cloud Admin or DevOps admin user account, go to **Administration** > **Configuration**, and click the link to download the **Registry Root Cert**.

         vSphere administrator accounts for the Platform Service Controller with which vSphere Integrated Containers is registered are automatically granted Cloud Admin access.
  
2. Use `vic-machine create` to deploy a VCH, specifying the registry's CA certificate by using the [`--registry-ca`](vch_installer_options.md#registry-ca) option. 

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

    Optionally, you can use the `--whitelist-registry` option to limit this VCH so that it can only access registries in your company's domain.<pre>vic-machine-<i>operating_system</i> create
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