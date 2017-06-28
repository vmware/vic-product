# Deploy the vSphere Integrated Containers Appliance #

You install vSphere Integrated Containers by deploying a virtual appliance. The appliance runs vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal, and makes the download of the vSphere Integrated Containers Engine binaries available. 

**Prerequisites**

- You downloaded the OVA installer from the [official vSphere Integrated Containers downloads page on vmware.com](http://www.vmware.com/go/download-vic).
- Deploy the appliance to a vCenter Server instance. Deploying the appliance directly on an ESXi host is not supported.
- Deploy the appliance to a vCenter Server system that meets the minimum system requirements:

   - 2 vCPUs
   - 8GB RAM
   - 80GB free disk space on the datastore

**Procedure**

1. In the vSphere Web Client, right-click an object in the vCenter Server inventory, select **Deploy OVF template**, and navigate to the OVA file.
2. Follow the installer prompts to perform basic configuration of the appliance and to select the vSphere resources for it to use. 

    - Accept or modify the appliance name
    - Destination datacenter or folder
    - Destination host, cluster, or resource pool
    - Accept the end user license agreements (EULA)
    - Disk format and destination datastore
    - Network that the appliance connects to

3. On the **Customize template** page, under **Appliance Security**, set the root password for the appliance VM and optionally uncheck the **Permit Root Login** checkbox. 

    Setting the root password for the appliance is mandatory.

5. Expand **Networking Properties** and optionally configure a static IP address for the appliance VM. 

    Leave the networking properties blank to use DHCP.

    **IMPORTANT**: If you set a static IP address for the appliance, use spaces to separate DNS servers. Do not use comma separation for DNS servers.

6. Expand **Registry Configuration** to configure the deployment of vSphere Integrated Containers Registry. 

    - If you do not want to deploy vSphere Integrated Containers Registry, uncheck the **Deploy Registry** check box.
    - In the **Registry Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - In the **Notary Port** text box, optionally change the port on which to publish the Docker Notary service for vSphere Integrated Containers Registry.
    - In the **Registry Admin Password** text box, set the password for the vSphere Integrated Containers Registry admin account.
    - In the **Database Password** text box, set the password for the root user of the MySQL database that vSphere Integrated Containers Registry uses.
    - Optionally check the **Garbage Collection** check box to enable garbage collection when the appliance reboots. 
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Registry, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates. 

7. Expand **Management Portal Configuration** to configure the deployment of vSphere Integrated Containers Management Portal. 

    - If you do not want to deploy vSphere Integrated Containers Management Portal, uncheck the **Deploy Management Portal** check box.
    - In the **Management Portal Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Management Portal service.
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Management Portal, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates.
7. Expand **Fileserver Configuration** to configure the file server from which you download vSphere Integrated Containers Engine and which publishes the plug-in packages for the vSphere Client. 

   - In the **Fileserver Port** text box, optionally change the port on which the vSphere Integrated Containers Engine file server runs.
   - To use custom certificates to authenticate connections to the vSphere Integrated Containers Engine file server, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates.
8. Click **Next** and **Finish** to deploy the vSphere Integrated Containers appliance.
9. When the deployment completes, power on the appliance VM.

**What to Do Next**

- Go to the file server that runs in the vSphere Integrated Containers appliance at https://<i>vic_appliance_address</i>:9443. If the vSphere Integrated Containers appliance uses a different port for the vSphere Integrated Containers Engine file server, replace 9443 with the appropriate port. 
- Download the vSphere Integrated Containers Engine binaries bundle, `vic_1.2.x.tar.gz`, from the file server. Unpack the bundle and start deploying virtual container hosts (VCHs). For information about deploying VCHs, see [Using vic-machine to Deploy VCHs](deploy_vch.md). 
- Install the vSphere Client plug-ins for vSphere Integrated Containers.  

  **NOTE**: Do not download the client plug-in files, `com.vmware.vic-v1.2.x.zip` and `com.vmware.vic.ui-v1.2.x.zip`, directly from the file server. You install the vSphere Integrated Containers plug-ins by running a script that pulls these files from the file server. For information about installing the plug-ins, see [Installing the vSphere Client Plug-ins](install_vic_plugin.md).

- Log in to vSphere Integrated Containers Registry at https://<i>vic_appliance_address</i>:443. If the vSphere Integrated Containers appliance uses a different port for vSphere Integrated Containers Registry, replace 443 with the appropriate port. For information about how to use vSphere Integrated Containers Registry, see [Managing Images, Projects, and Users with vSphere Integrated Containers Registry](../vic_cloud_admin/using_registry.md).
- Log in to vSphere Integrated Containers Management Portal: https://<i>vic_appliance_address</i>:8282. If the vSphere Integrated Containers appliance uses a different port for vSphere Integrated Containers Management Portal, replace 8282 with the appropriate port. For information about how to use vSphere Integrated Containers Management Portal, see [View and Manage VCHs, Add Registries, and Provision Containers Through the Management Portal](../vic_cloud_admin/vchs_and_mgmt_portal.md).

   