# Deploy a Virtual Container Host to an ESXi Host with No vCenter Server #

This topic provides instructions for using `vic-machine` to deploy a virtual container host (VCH) to an ESXi host that is not managed by vCenter Server. This is the most straightforward way to deploy a VCH, and is ideal for testing. 

- [Example](#example)
- [Test the Deployment of the VCH](#test)

## Example <a id="example"></a>

The VCH in this example is very basic and results in a VCH with extremely limited capabilities. For an example of how to deploy a more advanced VCH to a vCenter Server cluster, see [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](deploy_vch_dchphoton.md).

The ESXi host to which you deploy the VCH must match the specifications listed in the prerequisites. The example `vic-machine create` command deploys a VCH by using the minimum `vic-machine create` options possible, for demonstration purposes. You cannot use the Create Virtual Container Host wizard in the vSphere Client to deploy a VCH directly on an ESXi host.

### Prerequisites

* Deploy the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
* Download the vSphere Integrated Containers Engine bundle from the appliance and unpack it on your usual working machine. For information about how to download the bundle, see [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md).  
* Create or obtain an ESXi host with one datastore. You can use a nested ESXi host for this example.
* Verify that the ESXi host meets the requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md). 

    **IMPORTANT**: Pay particular attention to the [Networking Requirements for VCH Deployment](vic_installation_prereqs.md#vchnetworkreqs).
* Make sure that the correct firewall port is open on the ESXi host. For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).
* Obtain the ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
* Familiarize yourself with the basic options of the `vic-machine create` command described in [Running vic-machine Commands](running_vicmachine_cmds.md).
* Install a Docker client so that you can test the deployment.

### Procedure

1. Open a terminal on the system on which you downloaded and unpacked the vSphere Integrated Containers Engine binary bundle.
2. Navigate to the directory that contains the `vic-machine` utility:
3. Run the `vic-machine create` command.

    In these examples, the password is wrapped in quotes because it contains `@`.

   - Linux OS:
        <pre>$ vic-machine-linux create
     --target <i>esxi_host_address</i>
     --user root
     --password '<i>esxi_host_p@ssword</i>'
     --no-tlsverify
     --thumbprint <i>esxi_certificate_thumbprint</i>
     </pre>  
   - Windows:
        <pre>$ vic-machine-windows create
     --target <i>esxi_host_address</i>
     --user root
     --password "<i>esxi_host_p@ssword</i>"
     --no-tlsverify
     --thumbprint <i>esxi_certificate_thumbprint</i>
     </pre> 
   - Mac OS:
        <pre>$ vic-machine-darwin create
     --target <i>esxi_host_address</i>
     --user root
     --password '<i>esxi_host_p@ssword</i>'
     --no-tlsverify
     --thumbprint <i>esxi_certificate_thumbprint</i>
     </pre> 

The `vic-machine create` command in this example specifies the minimum information required to deploy a VCH to an ESXi host:

- The address of the ESXi host on which to deploy the VCH, in the `--target` option. 
- The ESXi host `root` user and password in the `--user` and `--password` options. 
- For simplicity, disables the verification of client certificates by specifying the `--no-tlsverify` option.
- Specifies the thumbprint of the ESXi host certificate by specifying the `--thumbprint` option.
   
Because the ESXi host only has only one datastore and uses the VM Network network, `vic-machine create` automatically detects and uses those resources. 

When deploying to an ESXi host, `vic-machine create` creates a standard virtual switch and a port group for use as the container bridge network, so you do not need to specify any network options if you do not have specific network requirements.

This example `vic-machine create` command deploys a VCH with the default name `virtual-container-host`.

### Result

At the end of a successful deployment, `vic-machine` displays information about the new VCH:
   
<pre>Initialization of appliance successful
VCH ID: <i>vch_id</i>
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

#### Troubleshooting

If you see errors during deployment, see [Troubleshoot Virtual Container Host Deployment](ts_deploy_vch.md).

For information about how to access VCH logs, including the deployment log, see [Access Virtual Container Host Log Bundles](log_bundles.md).

## Test the Deployment of the VCH  <a id="test"></a>

1. In a browser, log in to the UI for the ESXi host at https://<i>esxi_address</i>/ui.
2. Select **Virtual Machines**.

     You should see the VCH endpoint VM.  

3. Select **Networking** > **Port groups**.

     You should see a port group that has the same name as the VCH endpoint VM. This is the port group that vSphere Integrated Containers created for use as the VCH bridge network.
4. In a Docker client, run the `docker info` command to confirm that you can connect to the VCH.<pre>docker -H <i>vch_address</i>:2376 --tls info</pre>

     You should see confirmation that the Storage Driver is ```vSphere Integrated Containers Backend Engine```.
4. In your Docker client, pull a Docker container image from Docker Hub into the VCH.

     For example, pull the `BusyBox` container image.<pre>docker -H <i>vch_address</i>:2376 --tls pull busybox</pre>
1. In the ESXi host UI, open the **Datastore browser** and select the datastore.

    You should see that vSphere Integrated Containers Engine has created a folder that has the same name as the VCH. This folder contains the VCH endpoint VM files and a folder named `VIC`, in which to store container image files.
  
1. Expand the `VIC` folder to navigate to the `images` folder.

    The `images` folder contains folders for each container image that you pull into the VCH. The folders contain the container image files.
  
1. In your Docker client, run the Docker container that you pulled into the VCH.<pre>docker -H <i>vch_address</i>:2376 --tls run --name test busybox</pre>

1. In the ESXi host UI, go to **Virtual Machines**.
 
    You should see a VM named <code>test-<i>container_id</i></code>. This is the container VM that you created from the `BusyBox` image.

1. In the ESXi host UI, open the **Datastore browser** and select the datastore. 
 
     At the top-level of the datastore, you should see a folder that uses the container ID as its name. The folder contains the  files for the container VM that you created.

