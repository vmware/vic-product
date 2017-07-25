# Deploy the vSphere Integrated Containers Appliance #

You install vSphere Integrated Containers by deploying a virtual appliance. The appliance runs the vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal services, and publishes the downloads of the vSphere Integrated Containers Engine and vSphere Container Cluster Manager binaries. 

**Prerequisites**

- You downloaded an official build or an open-source build of the OVA installer.

  - Download official builds from the [vSphere Integrated Containers downloads page on vmware.com](http://www.vmware.com/go/download-vic).
  - Download open-source builds from the [vSphere Integrated Containers repository on Google Cloud Platform](https://console.cloud.google.com/storage/browser/vic-product-ova-builds/).
- Deploy the appliance to a vCenter Server instance. Deploying the appliance directly on an ESXi host is not supported.
- Deploy the appliance to a vCenter Server system that meets the minimum system requirements:

   - 2 vCPUs
   - 8GB RAM
   - 80GB free disk space on the datastore

**Procedure**

1. In the vSphere Web Client, right-click an object in the vCenter Server inventory, select **Deploy OVF template**, and navigate to the OVA file.
2. Follow the installer prompts to perform basic configuration of the appliance and to select the vSphere resources for it to use. 

    - Accept or modify the appliance name
    - Select the destination datacenter or folder
    - Select the destination host, cluster, or resource pool
    - Accept the end user license agreements (EULA)
    - Select the disk format and destination datastore
    - Select the network that the appliance connects to

3. On the **Customize template** page, under **Appliance Security**, set the root password for the appliance VM and optionally uncheck the **Permit Root Login** checkbox. 

    Setting the root password for the appliance is mandatory.

5. Expand **Networking Properties** and optionally configure a static IP address for the appliance VM. 

    To use DHCP, leave the networking properties blank.

    **IMPORTANT**: If you set a static IP address for the appliance, use spaces to separate DNS servers. Do not use comma separation for DNS servers.

6. Expand **Registry Configuration** to configure the deployment of vSphere Integrated Containers Registry. 

    - If you do not want to enable vSphere Integrated Containers Registry, uncheck the **Deploy Registry** check box.
    - In the **Registry Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - In the **Notary Port** text box, optionally change the port on which to publish the Docker Notary service for vSphere Integrated Containers Registry.
    - In the **Registry Admin Password** text box, set a password for the vSphere Integrated Containers Registry admin account.
    - In the **Database Password** text box, set a password for the root user of the MySQL database that vSphere Integrated Containers Registry uses.
    - Optionally check the **Garbage Collection** check box to enable garbage collection on the registry when the appliance reboots. 
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Registry, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates. 

7. Expand **Management Portal Configuration** to configure the deployment of vSphere Integrated Containers Management Portal. 

    - If you do not want to enable vSphere Integrated Containers Management Portal, uncheck the **Deploy Management Portal** check box.
    - In the **Management Portal Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Management Portal service.
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Management Portal, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates.
7. Expand **Fileserver Configuration** to configure the file server from which you download the vSphere Integrated Containers Engine and vSphere Container Cluster binaries, and which publishes the plug-in packages for the vSphere Client. 

   - In the **Fileserver Port** text box, optionally change the port on which the vSphere Integrated Containers Engine file server runs.
   - To use custom certificates to authenticate connections to the vSphere Integrated Containers Engine file server, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates.

7. Expand **VIC Engine Install Wizard Configuration** to optionally change the port on which the interactive web installer for virtual container hosts (VCHs) runs.
8. Expand **vSphere Container Cluster Manager Configuration** to configure the deployment of vSphere Container Cluster Manager.

    - If you do not want to enable vSphere Container Cluster Manager, uncheck the **Deploy vSphere Container Cluster Manager** check box.
    - In the **Admin username** text box, optionally specify a user name for an account for vSphere Container Cluster Manager to use when accessing the Kubernetes API . 
    
      If not specified, the installer creates an account named `admin`.
    - To use custom certificates to authenticate connections to vSphere Container Cluster Manager, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. Leave the text boxes blank to use auto-generated certificates.
8. Click **Next** and **Finish** to deploy the vSphere Integrated Containers appliance.
9. When the deployment completes, power on the appliance VM.
10. Go to https://<i>vic_appliance_address</i>:9443 and enter the address and single sign-on credentials of the vCenter Server instance on which you deployed the appliance.

    The installation process requires the single sign-on credentials to set up vSphere Integrated Containers Management Portal and Registry. If you configured the vSphere Integrated Containers appliance to use a different port for the vSphere Integrated Containers file server, replace 9443 with the appropriate port. 

**What to Do Next**

Access the different vSphere Integrated Containers components and start using them.

- Go to the file server that runs in the vSphere Integrated Containers appliance at https://<i>vic_appliance_address</i>:9443/files and download and unpack the vSphere Integrated Containers Engine binaries bundle, `vic_1.2.x.tar.gz`.
- Install the vSphere Client plug-ins for vSphere Integrated Containers. For information about installing the plug-ins, see [Installing the vSphere Client Plug-ins](install_vic_plugin.md). 
- Configure the firewalls on all ESXi hosts to permit VCH deployment. For information about how to configure the firewalls on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.html).
- Go to the interactive VCH installer at https://<i>vic_appliance_address</i>:1337 and deploy a demo VCH. For information about how to use the interactive VCH installer, see [Deploy a Virtual Container Host Interactively](deploy_demo_vch.html).
- Use `vic-machine` to deploy production VCHs. For information about deploying VCHs with `vic-machine`, see [Deploying Virtual Container Hosts with `vic-machine`](deploy_vch.md).
- Download the vSphere Container Cluster Manager binaries bundle, `vic-adm-platform-dev.tar.gz`, from the file server. Unpack the bundle and start deploying container clusters. For information about deploying container clusters, see [Deploy a Kubernetes Cluster](deploy_kubernetes_cluster.html).
- Log in to vSphere Integrated Containers Management Portal at https://<i>vic_appliance_address</i>:8282. For information about how to use vSphere Integrated Containers Management Portal, see [View and Manage VCHs, Add Registries, and Provision Containers Through the Management Portal](../vic_cloud_admin/vchs_and_mgmt_portal.md).

**NOTE** If, during the OVA deployment, you configured the vSphere Integrated Containers appliance to use different ports for the vSphere Integrated Containers services, replace the port numbers in the URLs below with the appropriate ports.


   