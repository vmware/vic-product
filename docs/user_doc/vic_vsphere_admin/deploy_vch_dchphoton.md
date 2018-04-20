# Deploy a Virtual Container Host for Use with `dch-photon` #

This version of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. 

The `dch-photon` image allows container developers to deploy a standard Docker container host that runs in a Photon OS container. Container developers can use this Docker engine to perform operations in standard Docker. For example, developers can use `dch-photon` containers to perform operations that virtual container hosts (VCHs) do not support in this version of vSphere Integrated Containers, such as `docker build` and `docker push`.

For container developers to be able to deploy containers from the `dch-photon` image, you must deploy VCHs with a specific minimum configuration:

- The VCH must be able to pull the `dch-photon` image from the vSphere Integrated Containers Registry instance. You must provide the registry's CA certificate to the VCH so that it can connect to the registry.
- A `dch-photon` container creates an anonymous volume, and as such requires a volume store named `default`.

## Example

This example shows how to use both the Create Virtual Container Host wizard and `vic-machine` to create a VCH with the minimum configuration required to deploy a `dch-photon` container.

### Prerequisites

1. Log in to the vSphere Integrated Containers Management Portal with a vSphere administrator, Cloud Admin, or DevOps admin user account.
2. Go to **Administration** > **Configuration**, and click the link to download the **Registry Root Cert**.

### Create VCH Wizard

1. Log in the HTML5 vSphere Client and go to the **vSphere Integrated Containers** view.
3. Click **vSphere Integrated Containers** in the main panel, select the **Virtual Container Hosts** tab, and click **+ New Virtual Container Host**.
4. On the General Settings page, enter a name for the VCH, for example, `vch_dch_photon`, and click **Next**.
5. On the Compute Capacity page, expand the **Compute resource** inventory hierarchy and select a standalone host, cluster, or resource pool to which to deploy the VCH, and click **Next**.
6. On the Storage Capacity page, select a datastore to use as the Image Datastore.
7. Remain on the Storage Capacity page and configure the volume datastore. 
   1. Set the **Enable anonymous volumes** switch to the green ON position.
   2. Select a datastore to use as a volume datastore.
   3. Optionally provide the path to a folder in that datastore.
   4. Click **Next**. 
7. On the Configure Networks page, select existing port groups for use as the bridge and public networks, and click **Next**.
8. On the Security page, for simplicity, leave the default options for automatic server certificate generation, and set the **Client Certificates** switch to the gray OFF position to disable client certificate verification.
9. Remain on the Security page, click Registry Access, and under Additional registry certificates, click **Select** to upload the certificate for vSphere Integrated Containers Registry, then click **Next**.
10. On the Operations User page, enter the user name and password for an existing vSphere account, select the **Grant this user any necessary permissions** check box, and click **Next**.
11. On the Summary page, click **Finish**.
 
### vic-machine Command

For simplicity, this example `vic-machine create` command deploys a VCH with the `--no-tlsverify` flag, so that container application developers do not need to use a TLS certificate to connect a Docker client to the VCH. However, the connection between the VCH and the registry still requires certificate authentication.

<pre>vic-machine-<i>operating_system</i> create
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

### Result ##

The VCH that you deployed can access vSphere Integrated Containers Registry, and has a volume store named `default`. It is ready for container developers to use with `dch-photon` containers.

**Troubleshooting**

If you see errors during deployment, see [Troubleshoot Virtual Container Host Deployment](ts_deploy_vch.md).

For information about how to access VCH logs, including the deployment log, see [Access Virtual Container Host Log Bundles](log_bundles.md).