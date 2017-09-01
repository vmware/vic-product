# Deploy the vSphere Integrated Containers Appliance #

You install vSphere Integrated Containers by deploying a virtual appliance. The appliance runs the vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal services, and publishes the downloads of the vSphere Integrated Containers Engine binaries. 


**Prerequisites**

- You downloaded an official build or an open-source build of the OVA installer.

  - Download official builds from the [vSphere Integrated Containers downloads page on vmware.com](http://www.vmware.com/go/download-vic).
  - Download open-source builds from the [vSphere Integrated Containers repository on Google Cloud Platform](https://console.cloud.google.com/storage/browser/vic-product-ova-builds/).
- Deploy the appliance to a vCenter Server instance. Deploying the appliance directly on an ESXi host is not supported.
- Deploy the appliance to a vCenter Server system that meets the minimum system requirements:

   - 2 vCPUs
   - 8GB RAM
   - 80GB free disk space on the datastore
- Ensure that all vCenter Server instances and ESXi hosts in the environment in which you are deploying the appliance have network time protocol (NTP) running. Running NTP prevents problems arising from clock skew between the vSphere Integrated Containers appliance, virtual container hosts, and the vSphere infrastructure.

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

    - In the **Registry Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - In the **Notary Port** text box, optionally change the port on which to publish the Docker Notary service for vSphere Integrated Containers Registry.
    - Optionally check the **Garbage Collection** check box to enable garbage collection on the registry when the appliance reboots. 

7. Expand **Management Portal Configuration** to configure the deployment of vSphere Integrated Containers Management Portal. 

    - In the **Management Portal Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Management Portal service.
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Management Portal, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. 

        **IMPORTANT**: vSphere Integrated Containers Management Portal does not support RSA format for TLS private keys. You must specify TLS private keys in PKCS8 format. Make sure there is no whitespace at the end of the key. To convert an RSA key to PKCS8 format, run the following command: <pre>$ openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in <i>key_name</i>.pem -out <i>key_name</i>.pkcs8.pem</pre>

    - Leave the text boxes blank to use auto-generated certificates.
7. Expand **Fileserver Configuration** to configure the file server from which you download the vSphere Integrated Containers Engine binaries, and which publishes the plug-in packages for the vSphere Client. 

   - In the **Fileserver Port** text box, optionally change the port on which the vSphere Integrated Containers Engine file server runs.
   - To use custom certificates to authenticate connections to the vSphere Integrated Containers Engine file server, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. The file server supports RSA format for TLS private keys. 
   - Leave the text boxes blank to use auto-generated certificates.    

7. Expand **Demo VCH Installer Wizard Configuration** to optionally change the port on which the interactive web installer for virtual container hosts (VCHs) runs.
8. Expand **Configure Example Users** to configure ready-made vSphere Integrated Containers user accounts in the Platform Services Controller.
    
     You can use these accounts to test the different user personas that can access vSphere Integrated Containers Management Portal and Registry.

    - Optionally uncheck the **Create Example Users** checkbox to disable the creation of example user accounts.
    - In the **Username Prefix for Example Users** text box, optionally modify the prefix of the example user names from the default, `vic`. 
    - In the **Password for Example Users** text boxes, optionally modify the password for the example user account from the default, `VicPro!23`.
8. Click **Next** and **Finish** to deploy the vSphere Integrated Containers appliance.
9. When the deployment completes, power on the appliance VM.

    If you deployed the appliance so that it obtains its address via DHCP, go to the **Summary** tab for the appliance VM and note the address.

10. (Optional) If you provided a static network configuration, view the network status of the appliance.

    1. In the **Summary** tab for the appliance VM, launch the VM console
    2. In the VM console, press the right arrow key. 

    The network status shows whether the network settings that you provided during the deployment match the settings with which the appliance is running. If there are mismatches, power off the appliance and select **Edit Settings** > **vApp Options** to correct the network settings.
    
11. In a browser, go to  http://<i>vic_appliance_address</i> and enter the address and single sign-on credentials of the vCenter Server instance on which you deployed the appliance.

    **IMPORTANT**: The installation process requires the single sign-on credentials to register vSphere Integrated Containers Management Portal and Registry with the Platform Services Controller. The vSphere Integrated Containers Management Portal and Registry services cannot start if you do not complete this step.

You can reconfigure the appliance after deployment by editing the settings of the appliance VM. For information about reconfiguring the appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).

**What to Do Next**

Access the different vSphere Integrated Containers components from the  vSphere Integrated Containers Getting Started page at  http://<i>vic_appliance_address</i>.

- Click the link to go to the **vSphere Integrated Containers Management Portal**. For information about how to use vSphere Integrated Containers Management Portal, see [View and Manage VCHs, Add Registries, and Provision Containers Through the Management Portal](../vic_cloud_admin/vchs_and_mgmt_portal.md).
- Scroll down to **Infrastructure deployment tools** and click the link to go to the **Demo VCH Installer Wizard**. For information about how to use the interactive VCH installer, see [Deploy a Virtual Container Host Interactively](deploy_demo_vch.md).
- Scroll down to **Infrastructure deployment tools** and click the link to **download the vSphere Integrated Containers Engine bundle**. The vSphere Integrated Containers Engine bundle allows you to perform the following tasks:

   - Use `vic-machine` to configure the firewalls on all ESXi hosts to permit VCH deployment. For information about how to configure the firewalls on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).
   - Install the vSphere Client plug-ins for vSphere Integrated Containers. For information about installing the plug-ins, see [Installing the vSphere Client Plug-ins](install_vic_plugin.md).       
   - Use `vic-machine` to deploy production VCHs. For information about deploying VCHs with `vic-machine`, see [Deploy Virtual Container Hosts with `vic-machine`](deploy_vch.md).
      
      




   
