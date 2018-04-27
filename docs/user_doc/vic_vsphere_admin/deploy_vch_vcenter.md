# Deploy a VCH to a Basic vCenter Server Cluster

This topic provides instructions for using `vic-machine` to deploy a virtual container host (VCH) in a very basic vCenter Server environment. This basic deployment allows you to test vSphere Integrated Containers Engine with vCenter Server before attempting a more complex deployment that corresponds to your real vSphere environment.

The vCenter Server instance to which you deploy the VCH must match the specifications listed in the prerequisites. This example `vic-machine create` command deploys a VCH by using the minimum `vic-machine create` options possible, for demonstration purposes.

**Prerequisites**

* Deploy the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
* Download the vSphere Integrated Containers Engine bundle from the appliance and unpack it on your usual working machine. For information about how to download the bundle, see [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md). 
* Create or obtain a vCenter Server instance with the following configuration:
  * One datacenter
  * One cluster with two ESXi hosts. You can use nested ESXi hosts for this example. VMware recommends that you enable VMware vSphere Distributed Resource Scheduler (DRS) on clusters whenever possible.
  * A shared datastore, that is accessible by both of the ESXi hosts.
  * The VM Network is present
  * One VMware vSphere Distributed Switches with two port groups named `vic-bridge` and `vic-public`.
* Verify that your vCenter Server instance and both of the ESXi hosts in the cluster meet the requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md). 

    **IMPORTANT**: Pay particular attention to the [Networking Requirements for VCH Deployment](vic_installation_prereqs.md#vchnetworkreqs).
* Make sure that the correct firewall ports are open on the ESXi hosts. For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).
* Obtain the vCenter Server certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
* Familiarize yourself with the vSphere Integrated Containers Engine binaries, as described in [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md). 
* Familiarize yourself with the basic options of the `vic-machine create` command described in [Using the `vic-machine` CLI Utility](using_vicmachine.md).
* Familiarize yourself with the bridge network and image store, as described in [Configure Bridge Networks](bridge_network.md) and [Specify the Image Store](image_store.md).
 

**Procedure**

1. Open a terminal on the system on which you downloaded and unpacked the vSphere Integrated Containers Engine binary bundle.
2. Navigate to the directory that contains the `vic-machine` utility:
3. Run the `vic-machine create` command.

   In these examples, the user name is wrapped in quotes because it contains `@`.

   - Linux OS:
      <pre>$ vic-machine-linux create
     --target <i>vcenter_server_address</i>
     --user 'Administrator@vsphere.local'
     --password <i>vcenter_server_password</i>
     --bridge-network vic-bridge
     --public-network vic-public
     --image-store <i>shared_datastore_name</i>
     --no-tlsverify
     --thumbprint <i>vcenter_server_certificate_thumbprint</i>
     </pre>  
   - Windows:
      <pre>$ vic-machine-windows create
     --target <i>vcenter_server_address</i>
     --user "Administrator@vsphere.local"
     --password <i>vcenter_server_password</i>
     --bridge-network vic-bridge
     --public-network vic-public
     --image-store <i>shared_datastore_name</i>
     --no-tlsverify
     --thumbprint <i>vcenter_server_certificate_thumbprint</i>
     </pre> 
   - Mac OS:
       <pre>$ vic-machine-darwin create
     --target <i>vcenter_server_address</i>
     --user 'Administrator@vsphere.local'
     --password <i>vcenter_server_password</i>
     --bridge-network vic-bridge
     --public-network vic-public
     --image-store <i>shared_datastore_name</i>
     --no-tlsverify
     --thumbprint <i>vcenter_server_certificate_thumbprint</i>
     </pre> 

The `vic-machine create` command in this example specifies the minimum information required to deploy a VCH to vCenter Server:

- The address of the vCenter Server instance on which to deploy the VCH, in the `--target` option.  
- A vCenter Single Sign-On user and password for a vSphere administrator account, in the `--user` and `--password` options. 
- The port group named `vic-bridge`, for use as the container bridge network. 
- The port group named `vic-public`, for use as the public network. 
- The name of the shared datastore to use as the image store, in which to store container images.
- For simplicity, disables the verification of client certificates by specifying the `--no-tlsverify` option.
- Specifies the thumbprint of the vCenter Server host certificate by specifying the `--thumbprint` option.
   
Because the vCenter Server instance only has one datacenter and one cluster, and uses the VM Network network, `vic-machine create` automatically detects and uses these resources.

This example `vic-machine create` command deploys a VCH with the default name `virtual-container-host`.

**Result**

At the end of a successful deployment, `vic-machine` displays information about the new VCH:
   
<pre>Initialization of appliance successful
VCH Admin Portal:
https://<i>vch_address</i>:2378
Published ports can be reached at:
<i>vch_address</i>
Docker environment variables:
DOCKER_HOST=<i>vch_address</i>:2376
Environment saved in virtual-container-host/virtual-container-host.env
Connect to docker:
docker -H <i>vch_address</i>:2376 --tls info
Installer completed successfully</pre>

**What to Do Next** 

To test your VCH, see [Verify the Deployment of a VCH](verify_vch_deployment.md).

**Troubleshooting**

If you see errors during deployment, see [Troubleshoot Virtual Container Host Deployment](ts_deploy_vch.md).

For information about how to access VCH logs, including the deployment log, see [Access Virtual Container Host Log Bundles](log_bundles.md).
