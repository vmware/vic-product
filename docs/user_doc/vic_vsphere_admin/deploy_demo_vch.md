# Deploy Virtual Container Hosts Interactively

The vSphere Integrated Containers appliance provides an interactive web installer from which you can deploy a basic virtual container host (VCH). This VCH has limited cabilities and is for demonstration purposes only, to allow you to start experimenting with vSphere Integrated Containers. 

The demo VCH has the minimum configuration that deployment to vCenter Server requires. Only the bridge network, public network, image store, and compute resource options are currently supported. 

**IMPORTANT**: The demo VCH does not implement any TLS authentication options, and as such is completely unsecured. Do not use the demo VCH in production environments. To deploy VCHs for use in production environments, use the `vic-machine` command line utility. 

**Prerequisites** 

- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.html).
- You opened port 2377 for outgoing connections on all ESXi hosts in your vCenter Server environment. For information about opening port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.html).
- You must create two distributed port groups, one each for the bridge and public networks, on the vCenter Server instance on which to deploy the VCH. For information about how to create a distributed virtual switch and a port group, see [Create a vSphere Distributed Switch](https://pubs.vmware.com/vsphere-65/topic/com.vmware.vsphere.networking.doc/GUID-D21B3241-0AC9-437C-80B1-0C8043CC1D7D.html) and [Add Hosts to a vSphere Distributed Switch](https://pubs.vmware.com/vsphere-65/topic/com.vmware.vsphere.networking.doc/GUID-E90C1B0D-82CB-4A3D-BE1B-0FDCD6575725.html) in the vSphere documentation.   

**NOTE**: When using `vic-machine` to deploy VCHs, if you do not specify a network or port group for the public network, the VCH uses the VM Network by default. However, because the VM Network might not be present, the demo VCH requires that you create a port group for the public network. 


**Procedure**

1. In a Web browser, go to  http://<i>vic_appliance_address</i>, scroll down to Infrastructure Deployment Tools, click the link **Go to the web installer to deploy a demo VCH**, and trust the certificate. 
2. Enter the IP address and administrator credentials of the vCenter Server instance on which the vSphere Integrated Containers appliance is running and click **Login**. 
4. Use the drop-down menus to select the appropriate resources for each of the required resources.

     <table border="1">
  <tr>
    <th scope="col">Option</th>
    <th scope="col">Description</th>
  </tr>
  <tr>
    <td>Bridge Network</td>
    <td>Select an existing distributed port group for container VMs use to communicate with each other.</td>
  </tr>
  <tr>
    <td>Public Network</td>
    <td>Select a different distributed port group for container VMs use to connect to the internet.</td>
  </tr>
  <tr>
    <td>Image Store</td>
    <td>Select a datastore in which to store container images that you pull into the VCH.</td>
  </tr>
    <tr>
    <td>Compute Resource</td>
    <td>Select the host, cluster, or resource pool in which to deploy the VCH.</td>
  </tr>
</table>
5. (Optional) Modify the name of the VCH to create.
6. Leave **Thumbprint** empty and click **Execute**. 

     The deployment of the VCH fails, but the certificate thumbprint of the target vCenter Server appears under **Execution Output**.
7. Copy and paste the certificate thumbprint into **Thumbprint** and click **Execute** again.

    You can monitor the progress of the VCH deployment under **Execution Output**. Stay on the Installer page until the command finishes. Logs might stop streaming if you switch to other tabs or windows. 

**Result**

At the end of a successful deployment, **Execution Output** displays information about the new VCH.  


**What to Do Next**

- Connect a Docker client to the VCH and run Docker commands against it. For information about running Docker commands against a VCH, see [Verify the Deployment of a VCH](verify_vch_deployment.md).
- Copy the generated command output under **Create Command** and use it as a template for use with `vic-machine` to create production VCHs. For information about how to deploy production VCHs, see [Using `vic-machine` to Deploy Virtual Container Hosts](deploy_vch.html).
- Go to the at vSphere Integrated Containers Management Portal at https://<i>vic_appliance_address</i>:8282. After creating a VCH, the web installer adds the VCH to the management portal instance that is running in the appliance. 
