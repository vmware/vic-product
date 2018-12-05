# Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access #

It is possible deploy a very basic virtual container host (VCH) with a minimal configuration for testing purposes. For example, configuring access to an image registry or designating a volume store is not mandatory when you deploy a VCH. For an example of the most minimal possible deployment, without registry access or a volume store, see [Deploy a VCH to an ESXi Host with No vCenter Server](deploy_vch_esxi.md).

However, in real-world deployments, you usually need to access private registries, and commonly used container images very often need to create volumes. Consequently, to create a useful test VCH, you should configure it for private registry access and add at least one volume store. In environments in which DHCP is not available, you must also configure a static IP address for the VCH endpoint VM on at least the public network. 

- [Example](#example)
- [Test the Deployment of the VCH](#test)

## Example <a id="example"></a>

This example shows how to use both the Create Virtual Container Host wizard and `vic-machine` to create a VCH with the following configuration:

- A static IP address for the VCH endpoint VM on the public network.
- A volume store named `default`, in which containers can create  anonymous volumes.
- Access to a vSphere Integrated Containers Registry instance, from which to pull images.

For simplicity, this example deploys a VCH without client certificate verification, so that container application developers do not need to use a TLS certificate to connect a Docker client to the VCH. However, the connection between the VCH and the registry still requires certificate authentication, so you must download the root certificate for vSphere Integrated Containers Registry and upload it to the VCH.

**NOTE**: If this is the first time that you are deploying a VCH, it is recommended to use the Create Virtual Container Host wizard rather than `vic-machine`.

### Prerequisites

* Deploy the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
* Download the vSphere Integrated Containers Engine bundle from the appliance and unpack it on your usual working machine. For information about how to download the bundle, see [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md). 
* If you did not do so when deploying the appliance, install the vSphere Client plug-in. For information, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md). By default, the plug-in is installed automatically. 
* Create or obtain a vCenter Server instance with the following configuration:
  * At least one datacenter
  * At least one cluster with at least two ESXi hosts. You can use nested ESXi hosts for this example. VMware recommends that you enable VMware vSphere Distributed Resource Scheduler (DRS) on clusters whenever possible.
  * At least one shared datastore, that is accessible by both of the ESXi hosts.
  * One VMware vSphere Distributed Switch with two port groups named `vic-bridge` and `vic-public`.
* Verify that your vCenter Server instance and all of the ESXi hosts in the cluster meet the requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md).

    **IMPORTANT**: Pay particular attention to the [Networking Requirements for VCH Deployment](vic_installation_prereqs.md#vchnetworkreqs).
* Make sure that the correct firewall ports are open on the ESXi hosts. For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).
* Obtain the vCenter Server certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
* If you intend to use the CLI utility to deploy the VCH, familiarize yourself with the basic options of the `vic-machine create` command described in [Running vic-machine Commands](running_vicmachine_cmds.md).
* Familiarize yourself with the bridge network, public network, image store, and volume store as described in [Configure Bridge Networks](bridge_network.md), [Configure the Public Network](public_network.md), and [Virtual Container Host Storage Capacity](vch_storage.md).
* Obtain the root certificate for vSphere Integrated Containers Registry. For information about how to obtain the certificate, see [Obtain the vSphere Integrated Containers Registry Certificate](vch_registry.md#regcert).
* If you intend to use the Create Virtual Container Host wizard in the vSphere Client, create a vSphere user account for the operations user. For information about creating the operations user account, see [Create the Operations User Account](create_ops_user.md).
* Install a Docker client so that you can test the deployment.

### Create VCH Wizard

1. Log in to the HTML5 vSphere Client, click the vSphere Client logo in the top left corner, and click **vSphere Integrated Containers**.
3. Click **vSphere Integrated Containers** in the main panel, select the **Virtual Container Hosts** tab, and click **+ New Virtual Container Host**.
4. On the General Settings page, enter a name for the VCH, for example, `test_vch`, and click **Next**.
5. On the Compute Capacity page, expand the **Compute resource** inventory hierarchy, select the cluster on to which to deploy the VCH, and click **Next**.
6. On the Storage Capacity page, select a datastore to use as the Image Datastore.
7. Remain on the Storage Capacity page and configure the volume datastore. 
   1. Set the **Enable anonymous volumes** switch to the green ON position.
   2. Select a datastore to use as a volume datastore. This does not have to be the same datastore as you used for the image store.
   3. Optionally provide the path to a folder in that datastore.
   4. Click **Next**. 
7. On the Configure Networks page, select the existing `vic-bridge` and `vic-public` port groups for use as the bridge and public networks.
8. Remain on the Configure Networks page and configure a static IP address for the VCH endpoint VM on the public network.
   1. Select the **Static** radio button.
   2. Enter an IP address with a network mask in the **IP Address** text box, for example `192.168.1.10/24`.
   3. Enter the IP address of the gateway in the **Gateway** text box, for example `192.168.0.1`.
   4. Enter a comma-separated list of DNS server addresses in the **DNS server** text box, for example `192.168.10.10,192.168.10.11`.
   5. Click **Next**.
8. On the Security page, for simplicity, set the **Client Certificates** switch to the gray OFF position to disable client certificate verification, leave the default options for automatic server certificate generation, and click **Next**.
9. On the Registry Access page, under Additional registry certificates, click **Select** to upload the certificate for vSphere Integrated Containers Registry, then click **Next**.
10. On the Operations User page, enter the user name and password for an existing vSphere account, select the **Grant this user any necessary permissions** check box, and click **Next**.
11. On the Summary page, scroll down to view the generated `vic-machine create` command, and optionally copy it for future use.
12. Click **Finish**.


**Result**

At the end of a successful deployment, the Virtual Container Hosts tab displays connection information for the new VCH.
 
### vic-machine Command

1. Open a terminal on the system on which you downloaded and unpacked the vSphere Integrated Containers Engine binary bundle.
2. Navigate to the directory that contains the `vic-machine` utility:
3. Run the `vic-machine create` command that corresponds to your working system.

    In these examples, the user name is wrapped in quotes because it contains `@`. The password is also wrapped in quotes because passwords usually contain special characters. Note that you use single quotes on Linux and Mac OS, and double quotes on Windows.

 - Linux:<pre>vic-machine-linux create \
--target <i>vcenter_server_address</i>/dc1 \
--user 'Administrator@vsphere.local' \
--password 'p@ssword123!' \
--compute-resource cluster1 \
--image-store datastore1 \
--bridge-network vch-bridge \
--public-network vic-public \
--public-network-ip 192.168.1.10/24 \
--public-network-gateway 192.168.0.1 \
--dns-server 192.168.10.10 \
--dns-server 192.168.10.11 \
--name test_vch \
--thumbprint <i>vcenter_server_certificate_thumbprint</i> \
--no-tlsverify \
--registry-ca <i>cert_path</i>/ca.crt \
--volume-store datastore2:default
</pre>
 - Windows:<pre>vic-machine-windows create ^
--target <i>vcenter_server_address</i>/dc1 ^ 
--user "Administrator@vsphere.local" ^ 
--password "p@ssword123!" ^ 
--compute-resource cluster1 ^
--image-store datastore1 ^
--bridge-network vch-bridge ^
--public-network vic-public ^
--public-network-ip 192.168.1.10/24 ^
--public-network-gateway 192.168.0.1 ^
--dns-server 192.168.10.10 ^
--dns-server 192.168.10.11 ^
--name test_vch ^
--thumbprint <i>vcenter_server_certificate_thumbprint</i> ^
--no-tlsverify ^
--registry-ca <i>cert_path</i>/ca.crt ^
--volume-store datastore2:default
</pre>
 - Mac OS:<pre>vic-machine-darwin create \
--target <i>vcenter_server_address</i>/dc1 \
--user 'Administrator@vsphere.local' \
--password 'p@ssword123!' \
--compute-resource cluster1
--image-store datastore1
--bridge-network vch-bridge
--public-network vic-public
--public-network-ip 192.168.1.10/24 \
--public-network-gateway 192.168.0.1 \
--dns-server 192.168.10.10 \
--dns-server 192.168.10.11 \
--name test_vch \
--thumbprint <i>vcenter_server_certificate_thumbprint</i> \
--no-tlsverify \
--registry-ca <i>cert_path</i>/ca.crt \
--volume-store datastore2:default
</pre>

The `vic-machine create` command in this example specifies the following options: 

- The address of the vCenter Server instance on which to deploy the VCH and datacenter `dc1` in the `--target` option.
- The vCenter Single Sign-On user and password for a vSphere administrator account in the `--user` and `--password` options. 
- The cluster `cluster1`, as the location in the vCenter Server inventory in which to deploy the VCH. 
- The port group named `vic-bridge`, for use as the container bridge network. 
- The port group named `vic-public`, for use as the public network.
- A static IP address with a network mask for the VCH endpoint VM on the public network in the `--public-network-ip` option, along with the addresses for the gateway and two DNS servers in the `--public-network-gateway` and `--dns-server` options.
- The shared datastore named `datastore1`, for use as the image store, in which to store container images, in the `--image-store` option.
- For simplicity, disables the verification of client certificates by specifying the `--no-tlsverify` option.
- Names the VCH `test_vch` in the `--name` option.
- The thumbprint of the vCenter Server host certificate by specifying the `--thumbprint` option.
- The path to the certificate for vSphere Integrated Containers Registry in the `--registry-ca` option
- A volume store named `default` in the `--volume-store` option. In this example, the datastore to use as the volume store is `datastore2` that is not the same datastore as is used for the image store. 

You could also specify <code>--volume-store nfs://<i>nfs_server</i>/path_to_share_point:default</code> to designate an NFS share point as the default volume store.

**Result**

At the end of a successful deployment, `vic-machine` displays information about the new VCH:
   
<pre>Initialization of appliance successful
VCH ID: <i>vch_id</i>
VCH Admin Portal:
https://<i>vch_address</i>:2378
Published ports can be reached at:
<i>vch_address</i>
Docker environment variables:
DOCKER_HOST=<i>vch_address</i>:2376
Environment saved in test_vch/test_vch.env
Connect to docker:
docker -H <i>vch_address</i>:2376 --tls info
Installer completed successfully</pre>

Now you can [Test the Deployment of the VCH](#test).

### Troubleshooting

If you see errors during deployment, see [Troubleshoot Virtual Container Host Deployment](ts_deploy_vch.md).

For information about how to access VCH logs, including the deployment log, see [Access Virtual Container Host Log Bundles](log_bundles.md).

## Test the Deployment of the VCH <a id="test"></a>

After you deploy a VCH, you can pull container images from a public repository, such as Docker Hub, and deploy container VMs from them in the VCH. In this way, you can see how deploying and running container VMs affects your vSphere environment. 

You can also use vSphere Integrated Containers Management Portal and Registry to test your VCH. This version of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image requires that the VCHs on which it is deployed have a specific minimum configuration:

- The VCH must be able to pull the `dch-photon` image from the vSphere Integrated Containers Registry instance. You must provide the registry's CA certificate to the VCH so that it can connect to the registry.
- A `dch-photon` container creates an anonymous volume, and as such requires a volume store named `default`.

The VCH that you deployed in the [Example](#example) above meets these requirements, so you can use the `dch-photon` image to test it.

This example uses the `dch-photon` image for demonstration purposes only. For information about how container developers can actually use `dch-photon`, see [Building and Pushing Images with the dch-photon Docker Engine](../vic_app_dev/build_push_images.md) in *Developing Applications with vSphere Integrated Containers*.

vSphere Integrated Containers 1.4.x supports `dch-photon` version 1.13.

### Procedure

1. Log in to the vSphere Client, go to **Hosts and Clusters**, and select the cluster on which you deployed the VCH. 

    You should see a resource pool with the name that you set for the VCH. The resource pool contains the VCH endpoint VM.   
3.  In a Docker client, run the `docker info` command to confirm that you can connect to the VCH.<pre>docker -H <i>vch_address</i>:2376 --tls info</pre>

     You should see confirmation that the Storage Driver is ``` vSphere Integrated Containers Backend Engine```.
1.  In your Docker client terminal, pull a Docker container image from Docker Hub into the VCH. 

     For example, pull the `BusyBox` container image.<pre>docker -H <i>vch_address</i>:2376 --tls pull busybox</pre>
1. In the vSphere Client, go to **Storage**, right-click the datastore that you designated as the image store, and select **Browse Files**. 

     You should see that vSphere Integrated Containers Engine has created a folder that has the same name as the VCH. This folder contains the VCH endpoint VM files and a folder named `VIC`. Expand this folder and navigate to the `images` folder. The `images` folder contains folders for each container image that you pull into the VCH. The folders contain the container image files.
  
2. In your Docker client terminal, run the container that you pulled into the VCH.<pre>docker -H <i>vch_address</i>:2376 --tls run --name test busybox</pre>
1. In the vSphere Client, go to **Hosts and Clusters** and expand the VCH resource pool.
 
    You should see a VM named <code>test-<i>container_id</i></code>. This is the container VM that you created from the `BusyBox` image.
1. In the vSphere Client, go to **Storage** and select the datastore that you designated as the image store. 
 
    At the top-level of the datastore, you should see a folder that uses the container ID as its name. The folder contains the files for the container VM that you just created.
8. In a browser, log in to the vSphere Integrated Containers Management Portal at https://vic_appliance_address with a vSphere administrator, Management Portal administrator, or DevOps administrator user account.
9. Select **Home** and make sure that the **Project** drop-down menu is set to `default-project`. 
10. Under **Infrastructure**, select **Container Hosts** and click **+Container Host** to register the VCH with the management portal.

   1. Enter a name for the VCH, for example, `test-vch`.
   2. Leave **Type** set to `VCH`.
   3. For **URL**, enter the address of the VCH in the format https://<i>vch_ip_address</i>:2376, click **Save**, and click **Yes** to accept the VCH certificate. 
11. Under **Deployments**, select **Containers** and click **+Container**.  
   1. Type `dch` in the **Image** search box and select the `dch-photon` image that is pre-loaded in vSphere Integrated Containers Registry:<pre><i>vic_appliance_address</i>:443/default-project/dch-photon</pre>
   2. Click in the **Search for tags** box and select **1.13**.
   3. Enter a name for the container VM, for example `dch-photon-test`, and click **Provision**.

    If the `dch-photon-test` container deploys correctly, it shows up as running in the **Containers** view, alongside the stopped `test` container that you ran in the VCH from the Docker client.
12. Go back to the vSphere Client, navigate to the vSphere Integrated Containers view, and select the **Containers** tab.
 
    You should see the `dch-photon-test` container in the list of container VMs that are running in this vCenter Server instance.
13. Go to **Hosts and Clusters** and expand the resource pool for the `test_vch` VCH.
 
    You should see the `dch-photon-test` container VM running in the resource pool.
13. Go back to **Storage**, right-click the datastore that you designated as the volume store, and select **Browse Files**. 

     You should see that vSphere Integrated Containers Engine has created a folder named `VIC` at the top level of the datastore. This folder contains a subfolder named `volumes`, that contains folders for the volumes created by the `dch-photon` container VM. These folders contain the VDMK files for those volumes.

### What to Do Next

The VCH and the `dch-photon` container VM are ready for container developers to use. For information about how developers connect to vSphere Integrated Containers Registry from Docker clients, and how  they can use `dch-photon`, see the following topics in *Developing Applications with vSphere Integrated Containers*:

 - [Configure the Docker Client for Use with vSphere Integrated Containers](../vic_app_dev/configure_docker_client.md)
 - [Building and Pushing Images with the dch-photon Docker Engine](../vic_app_dev/build_push_images.md)