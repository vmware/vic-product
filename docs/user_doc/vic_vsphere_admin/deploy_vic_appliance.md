# Deploy the vSphere Integrated Containers Appliance #

You install vSphere Integrated Containers by deploying a virtual appliance. 

The following services run in the vSphere Integrated Containers appliance:

- vSphere Integrated Containers Registry service
- vSphere Integrated Containers Management Portal service
- The file server for vSphere Integrated Containers Engine downloads and installation of the vSphere Client plug-ins
- The `vic-machine` server service, that powers the Create Virtual Container Host wizard in the HTML5 vSphere Client plug-in

You can deploy multiple vSphere Integrated Containers appliances to the same vCenter Server instance. Also, if a Platform Services Controller manages multiple vCenter Server instances, you can deploy multiple appliances to different vCenter Server instances that share that Platform Services Controller.

**Prerequisites**

- You downloaded an official build or an open-source build of the OVA installer. For information about where to download the installer, see [Download the vSphere Integrated Containers Installer](download_vic.md).
- Verify that the environment in which you are deploying the appliance meets the prerequisites described in [Deployment Prerequisites for vSphere Integrated Containers](vic_installation_prereqs.md).
- Use the Flex-based vSphere Web Client to deploy the appliance. You cannot deploy OVA files from the HTML5 vSphere Client or from the legacy Windows client.

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

    **IMPORTANT**: You require SSH access to the vSphere Integrated Containers appliance to perform upgrades. You can also use SSH access in exceptional cases that you cannot handle through standard remote management or CLI tools. Only use SSH to access the appliance when instructed to do so in the documentation, or under the guidance of VMware GSS.

5. Expand **Networking Properties** and optionally configure a static IP address and fully qualified domain name (FQDN) for the appliance VM. 

    To use DHCP, leave the networking properties blank. If you specify an FQDN, the appliance uses this FQDN to register with the Platform Services Controller and runs the Registry, Management Portal, and file server services at that FQDN.

    **IMPORTANT**: If you set a static IP address for the appliance, use spaces to separate DNS servers. Do not use comma separation for DNS servers. 

6. Expand **Registry Configuration** to configure the deployment of vSphere Integrated Containers Registry. 

    - In the **Registry Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - In the **Notary Port** text box, optionally change the port on which to publish the Docker Content Trust service for vSphere Integrated Containers Registry.
    - Optionally check the **Garbage Collection** check box to enable garbage collection on the registry when the appliance reboots. 

7. Expand **Management Portal Configuration** to configure the deployment of vSphere Integrated Containers Management Portal. 

    - In the **Management Portal Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Management Portal service.
    - To use custom certificates to authenticate connections to vSphere Integrated Containers Management Portal, optionally paste the content of the appropriate certificate, key, and Certificate Authority (CA) files in the **SSL Cert**, **SSL Cert Key**, and **CA Cert** text boxes. 

        **IMPORTANT**: Provide the TLS private key as a PEM-encoded PKCS#8-formatted file.

    - Leave the text boxes blank to use auto-generated certificates.
7. Expand **Fileserver Configuration** to configure the file server from which you download the vSphere Integrated Containers Engine binaries, and which publishes the plug-in packages for the vSphere Client. 

   - In the **Fileserver Port** text box, optionally change the port on which the vSphere Integrated Containers file server runs.
   - To use custom certificates to authenticate connections to the vSphere Integrated Containers file server, optionally paste the content of the appropriate certificate and key files in the **SSL Cert** and **SSL Cert Key** text boxes. The file server supports RSA format for TLS private keys. 
   - Leave the text boxes blank to use auto-generated certificates.    
8. Expand **Configure Example Users** to configure the ready-made  example user accounts that vSphere Integrated Containers creates by default in the Platform Services Controller.
    
     You can use these accounts to test the different user personas that can access vSphere Integrated Containers Management Portal and Registry.

    - Uncheck the **Create Example Users** checkbox if you do not want vSphere Integrated Containers to create user accounts in the Platform Services Controller.
    - In the **Username Prefix for Example Users** text box, optionally modify the prefix of the example user names from the default, `vic`. If you unchecked the **Create Example Users** checkbox, this option is ignored.
    - In the **Password for Example Users** text boxes, modify the password for the example user account from the default, `VicPro!23`. The new password must comply with the password policy for the Platform Services Controller, otherwise the creation of the example user accounts fails. If you unchecked the **Create Example Users** checkbox, this option is ignored. 

        **IMPORTANT**: If you did not uncheck the **Create Example Users** checkbox, it is strongly recommended that you change the default password for the example users.
8. Click **Next** and **Finish** to deploy the vSphere Integrated Containers appliance.
9. When the deployment completes, power on the appliance VM.

    If you deployed the appliance so that it obtains its address via DHCP, go to the **Summary** tab for the appliance VM and note the address.

10. (Optional) If you provided a static network configuration, view the network status of the appliance.

    1. In the **Summary** tab for the appliance VM, launch the VM console
    2. In the VM console, press the right arrow key. 

    The network status shows whether the network settings that you provided during the deployment match the settings with which the appliance is running. If there are mismatches, power off the appliance and select **Edit Settings** > **vApp Options** to correct the network settings.
    
11. Wait for a few minutes to allow the appliance services to start, then in a browser, go to http://<i>vic_appliance_address</i> and enter the connection details for the vCenter Server instance on which you deployed the appliance.

     - The address and single sign-on credentials of vCenter Server.
     - If vCenter Server is managed by an external Platform Services Controller, enter the FQDN and administrator domain for the Platform Services Controller. If vCenter Server is managed by an embedded Platform Services Controller, leave the External PSC text boxes empty.

    **IMPORTANT**: The installation process requires the single sign-on credentials to register vSphere Integrated Containers Management Portal and Registry with the Platform Services Controller and to tag the appliance VM for use in Docker content trust. The vSphere Integrated Containers Management Portal and Registry services cannot start if you do not complete this step.

12. Click **Continue** to initialize the appliance.

**Result**

You see the vSphere Integrated Containers Getting Started page at http://<i>vic_appliance_address</i>. The Getting Started page includes the following links: 

- vSphere Integrated Containers Management Portal
- The download for the vSphere Integrated Containers Engine bundle
- Documentation

**What to Do Next**

- [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md).
- [Install the vSphere Client Plug-ins](install_vic_plugin.md).
- Log in to vSphere Integrated Containers Management Portal. For information about the management portal, see [Configure and Manage vSphere Integrated Containers](../vic_cloud_admin/).      
- If necessary, you can reconfigure the appliance after deployment by editing the settings of the appliance VM. For information about reconfiguring the appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).   

**Troubleshooting**

- If you do not see a green success banner at the top of the Getting Started page after initializing the appliance, the appliance has not initialized correctly. For more information, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md). You should not reinitialize the appliance in any circumstances other than those described in that topic.
- To remove security warnings when you connect to the Getting Started page or management portal, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).
- If you see a certificate error when you attempt to go to http://<i>vic_appliance_address</i>, see [Browser Rejects Certificates with `ERR_CERT_INVALID` Error](ts_cert_error.md).
