# Deploy a Virtual Container Host for Use with `dch-photon` #

This version of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. 

The `dch-photon` image allows container developers to deploy a standard Docker container host that runs in a Photon OS container. Container developers can use this Docker engine to perform operations in standard Docker. For example, developers can use `dch-photon` containers to perform operations that virtual container hosts (VCHs) do not support in this version of vSphere Integrated Containers, such as `docker build` and `docker push`.

For container developers to be able to deploy containers from the `dch-photon` image, you must deploy VCHs with a specific configuration.

**Prerequisites**

- You downloaded the vSphere Integrated Containers Engine bundle from  http://<i>vic_appliance_address</i>.
- Obtain the vCenter Server or ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

**Procedure**

1. Log in to the vSphere Integrated Containers Management Portal with a vSphere administrator, Cloud Admin or DevOps admin user account.

    vSphere administrator accounts for the Platform Services Controller with which vSphere Integrated Containers is registered are automatically granted Cloud Admin access.
2. Go to **Administration** > **Configuration**, and click the link to download the **Registry Root Cert**.
3. Use `vic-machine create` to deploy a VCH.

    - The VCH must be able to pull the `dch-photon` image from the vSphere Integrated Containers Registry instance. You must specify the registry's CA certificate by using the [`--registry-ca`](vch_registry.md#registry-ca) option.
    - A `dch-photon` container creates an anonymous volume, and as such requires named `default`.

     For simplicity, this example deploys a VCH with the `--no-tls` flag, so that container application developers do not need to use a TLS certificate to connect a Docker client to the VCH. However, the connection between the VCH and the registry still requires certificate authentication.<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch-bridge
--name vch_dch_photon
--thumbprint <i>vcenter_server_certificate_thumbprint</i>
--no-tlsverify
--registry-ca <i>cert_path</i>/ca.crt
--volume-store <i>datastore_name</i>:default
</pre>

    You could also specify <code>--volume-store nfs://datastore_name/path_to_share_point:default</code> to designate an NFS share point as the default volume store.

**Result**

The VCH that you deployed can access vSphere Integrated Containers Registry, and has a volume store named `default`. It is ready for container developers to use with `dch-photon` containers.