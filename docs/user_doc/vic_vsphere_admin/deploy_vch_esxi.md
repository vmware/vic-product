# Deploy a Virtual Container Host to an ESXi Host with No vCenter Server #

This topic provides instructions for deploying a virtual container host (VCH) to an ESXi host that is not managed by vCenter Server. This is the most straightforward way to deploy a VCH, and is ideal for testing.

The ESXi host to which you deploy the VCH must match the specifications listed in the prerequisites. This example deploys a VCH by using the minimum `vic-machine create` options possible, for demonstration purposes.

**Prerequisites**

* Deploy the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
* In a Web browser, go to  http://<i>vic_appliance_address</i>, scroll down to Infrastructure Deployment Tools, click the link to **download the vSphere Integrated Containers Engine bundle**, and unpack it on your working machine.  
* Create or obtain an ESXi host with the following configuration:
  * One datastore
  * The VM Network is present
  * You can use a nested ESXi host for this example
* Verify that the ESXi host meets the requirements in [Environment Prerequisites for VCH Deployment](vic_installation_prereqs.md).
* Make sure that the correct firewall port is open on the ESXi host. For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).
* Obtain the ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
* Familiarize yourself with the vSphere Integrated Containers Engine binaries, as described in [Contents of the vSphere Integrated Containers Engine Binaries](contents_of_vic_binaries.md). 
* Familiarize yourself with the basic options of the `vic-machine create` command described in [Virtual Container Host Placement](vch_placement.md).

**Procedure**

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
- For simplicity, disables the verification of clients that connect to this VCH by specifying the `--no-tlsverify` option.
- Specifies the thumbprint of the ESXi host certificate by specifying the `--thumbprint` option.
   
Because the ESXi host only has only one datastore and uses the VM Network network, `vic-machine create` automatically detects and uses those resources. 

When deploying to an ESXi host, `vic-machine create` creates a standard virtual switch and a port group for use as the container bridge network, so you do not need to specify any network options if you do not have specific network requirements.

This example deploys a VCH with the default name `virtual-container-host`.

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