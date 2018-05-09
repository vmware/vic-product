# Verify the Deployment of a VCH #

After you have deployed a virtual container host (VCH), you can verify the deployment by connecting a Docker client to the VCH and running Docker operations. You can check the results in the vSphere Client.

**IMPORTANT**: Do not perform operations on virtual container hosts (VCHs) or container VMs in the vSphere Client inventory views. Specifically, using the vSphere Client inventory views to power off, power on, or delete the VCH endpoint VM, or to modify the VCH resource pool or folder, can cause vSphere Integrated Containers Engine to not function correctly. Always use the vSphere Integrated Containers plug-in for the HTML5 vSphere Client or `vic-machine` to perform operations on VCHs. The vSphere Client does not allow you to delete container VMs, but do not use the vSphere Client to power container VMs on or off. Always use Docker commands or vSphere Integrated Containers Management Portal to perform operations on containers.

**Prerequisites**

- You followed the instructions in [Deploy a Virtual Container Host with vSphere Integrated Containers Registry Access and a Volume Store](deploy_vch_dchphoton.md) or [Deploy a VCH to an ESXi Host with No vCenter Server](deploy_vch_esxi.md), specifying the `--no-tlsverify` option.
- You have installed a Docker client.
- If you deployed the VCH to vCenter Server, connect a vSphere Client to that vCenter Server instance.
- If you deployed the VCH to an ESXi host, log in to the UI for that host.

**Procedure**    

1. View the VCH in the vSphere Client.
 
   - vCenter Server: Go to **Hosts and Clusters** and select the cluster or host on which you deployed the VCH. You should see a resource pool with the name that you set for the VCH.
   - ESXi host: Go to **Virtual Machines**. You should see a resource pool with the name that you set for the VCH.

    The resource pool contains the VCH endpoint VM.   

3.  In a Docker client, run the `docker info` command to confirm that you can connect to the VCH.<pre>docker -H <i>vch_address</i>:2376 --tls info</pre>

     You should see confirmation that the Storage Driver is ``` vSphere Integrated Containers Backend Engine```.

1.  Pull a Docker container image into the VCH, for example, the `BusyBox` container.<pre>docker -H <i>vch_address</i>:2376 --tls pull busybox</pre>
1. View the container image files in the vSphere Client.

    - vCenter Server: Go to **Storage**, right-click the datastore that you designated as the image store, and select **Browse Files**. 
    - ESXi host: Right-click the datastore that you designated as the image store, and select **Browse Datastore**. 

    vSphere Integrated Containers Engine creates a folder that has the same name as the VCH, that contains a folder named `VIC` in which to store container image files.
  
1. Expand the `VIC` folder to navigate to the `images` folder.  The `images` folder contains a folder for every container image that you pull into the VCH. The folders contain the container image files.
  
1. In your Docker client, run the Docker container that you pulled into the VCH.<pre>docker -H <i>vch_address</i>:2376 --tls run --name test busybox</pre>

1. View the container VM in the vSphere Client.

    - vCenter Server: 
       - Go to **Hosts and Clusters** and expand the VCH resource pool.
       - Go to **VMs and Templates** and select the VM folder that has the same name as the VCH.
    - ESXi host: Go to **Virtual Machines**.
 
    You should see a VM for every container that you run, including a VM named <code>test-<i>container_id</i></code>.

1. View the container VM files in the vSphere Client.

    - vCenter Server: Go to **Storage** and select the datastore that you designated as the image store. 
    - ESXi host: Right-click the datastore that you designated as the image store, and select **Browse Datastore**. 
 
     At the top-level of the datastore, you should see a folder that uses the container ID as its name, for every container that you run. The folders contain the container VM files.

**What to Do Next**

If you deployed the HTML5 plug-in for the vSphere Client, you can see information about VCHs and containers in the Virtual Container Hosts view of the plug-in. For information about how to access the plug-in, see [View All VCH and Container Information in the HTML5 vSphere Client](access_h5_ui.md).