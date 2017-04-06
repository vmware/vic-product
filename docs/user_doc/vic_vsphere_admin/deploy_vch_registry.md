# Deploy a VCH for Use with vSphere Integrated Containers Registry

To use vSphere Integrated Containers Engine with vSphere Integrated Containers Registry, you must obtain the registry certificate and pass it to a virtual container host (VCH) when you create that VCH.

If you did not provide a custom server certificate and private key for the registry to the OVA installer when you deployed the vSphere Integrated Containers appliance, vSphere Integrated Containers Registry auto-generates a Certificate Authority (CA) certificate, a server certificate, and a server private key. You can download the auto-generated CA certificates from the vSphere Integrated Containers Registry interface.

**Prerequisites**

- You selected the option to deploy vSphere Integrated Containers Registry when you deployed the vSphere Integrated Containers appliance.
- You downloaded the vSphere Integrated Containers Engine bundle from the appliance.

**Procedure**

1. Obtain the CA certificate of the registry instance or instances to use with this VCH.

   - If you deployed the registry with custom certificates, obtain the certificate from your certificate manager. 
   - If you deployed the registry with auto-generated certificates, log in to the vSphere Integrated Containers Registry interface as `admin` user, select **admin** > **About**, and click the link to download the certificate.
   - You can also obtain the certificate by using SCP to copy the certificate file from `/data/harbor/cert` in the vSphere Integrated Containers appliance VM.<pre>scp root@<i>vic_appliance_address</i>:/data/harbor/cert/ca.crt ./<i>destination_path</i></pre>
2. Use `vic-machine create` to deploy a VCH, specifying the registry's CA certificate by using the [`--registry-ca`](vch_installer_options.md#registry-ca) option. 

    You can configure the VCH to connect to multiple registries by specifying `--registry-ca` multiple times.

    For simplicity, this example installs a VCH with the `--no-tls` flag, so that container application developers do not need to use a TLS certificate to connect a Docker client to the VCH. However, the connection between the VCH and the registry still requires certificate authentication.<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch_registry
--force
--no-tlsverify
--registry-ca=<i>cert_path</i>/ca.crt
</pre>
     

**Result**

The VCH has a copy of the registry certificate and can connect to this vSphere Integrated Containers Registry instance.