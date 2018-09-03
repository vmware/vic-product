# Deploy the vSphere Integrated Containers Appliance #

You install vSphere Integrated Containers by deploying a virtual appliance. 

The following services run in the vSphere Integrated Containers appliance:

- vSphere Integrated Containers Registry service
- vSphere Integrated Containers Management Portal service
- The file server for vSphere Integrated Containers Engine downloads and installation of the vSphere Client plug-ins
- The `vic-machine-server` service, that powers the virtual container host deployment and management wizards in the HTML5 vSphere Client plug-in

You can deploy multiple vSphere Integrated Containers appliances to the same vCenter Server instance. Also, if a Platform Services Controller manages multiple vCenter Server instances, you can deploy multiple appliances to different vCenter Server instances that share that Platform Services Controller.

**Prerequisites**

- You downloaded an official build or an open-source build of the OVA installer. For information about where to download the installer, see [Download the vSphere Integrated Containers Installer](download_vic.md).
- Verify that the environment in which you are deploying the appliance meets the prerequisites described in [Deployment Prerequisites for vSphere Integrated Containers](vic_installation_prereqs.md).
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
- Use the Flex-based vSphere Web Client to deploy the appliance. You cannot deploy OVA files from the HTML5 vSphere Client or from the legacy Windows client. 

    **IMPORTANT**: In vSphere 6.7, the HTML5 client does not prevent you from deploying OVA files and deployment appears to succeed. However, the resulting appliance does not function correctly due to an issue with the vSphere 6.7 HTML5 client. Always use the Flex-based vSphere Web Client to deploy the appliance OVA, even if you are using vSphere 6.7.

**Procedure**

1. In the vSphere Web Client, right-click an object in the vCenter Server inventory, select **Deploy OVF template**, and navigate to the OVA file.
2. Follow the installer prompts to perform basic configuration of the appliance and to select the vSphere resources for it to use. 

    - Accept or modify the appliance name
    - Select the destination datacenter or folder
    - Select the destination host, cluster, or resource pool
    - Accept the end user license agreements (EULA)
    - Select the disk format and destination datastore
    - Select the network that the appliance connects to

3. On the **Customize template** page, expand **Appliance Configuration**.

    - Set the root password for the appliance VM. Setting the root password for the appliance is mandatory. 
    - Optionally uncheck the **Permit Root Login** checkbox.
  
        **IMPORTANT**: You require SSH access to the vSphere Integrated Containers appliance to perform upgrades. You can also use SSH access in exceptional cases that you cannot handle through standard remote management or CLI tools. Only use SSH to access the appliance when instructed to do so in the documentation, or under the guidance of VMware GSS.

4. Configure the appliance certificate, that is used by all of the services that run in the appliance to authenticate connections.<a id="step4"></a>
    - To use a custom certificate:
     - Paste the contents of the appropriate certificate in the **Appliance TLS Certificate** text box.
     - Paste the contents of the certificate key in the **Appliance TLS Certificate Key** text box. The appliance supports unencrypted PEM encoded PKCS#1 and unencrypted PEM encoded PKCS#8 formats for TLS private keys. 
     - Paste the contents of the Certificate Authority (CA) file in the **Certificate Authority Certificate** text box. 
    - To use a certificate that uses an intermediate CA, see [Use a Certificate with an Intermediate CA for the vSphere Integrated Containers Appliance](vic_cert_reference.md#intermediateca).
    - To use auto-generated certificates, leave the **Appliance TLS Certificate**, **Appliance TLS Certificate Key**, and **Certificate Authority Certificate** text boxes blank.
5. In the **Appliance Configuration Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Getting Started page.

5. Expand **Networking Properties** and optionally configure a static IP address and fully qualified domain name (FQDN) for the appliance VM. 

    To use DHCP, leave the networking properties blank. If you specify an FQDN, the appliance uses this FQDN to register with the Platform Services Controller and runs the Registry, Management Portal, and file server services at that FQDN.

    **IMPORTANT**: If you set a static IP address for the appliance, use spaces to separate DNS servers. Do not use comma separation for DNS servers. 

6. Expand **Registry Configuration** to configure the deployment of vSphere Integrated Containers Registry. 

    - In the **Registry Port** text box, optionally change the port on which to publish the vSphere Integrated Containers Registry service.
    - In the **Notary Port** text box, optionally change the port on which to publish the Docker Content Trust service for vSphere Integrated Containers Registry.
    - Optionally check the **Garbage Collection** check box to enable garbage collection on the registry when the appliance reboots. 

7. (Optional) Expand **Management Portal Configuration** and optionally change the port on which to publish the vSphere Integrated Containers Management Portal service.
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
    
11. In a browser, go to the vSphere Integrated Containers Getting Started page.

    You can specify the address in one of the following formats:

    - <i>vic_appliance_address</i>
    - http://<i>vic_appliance_address</i>
    - https://<i>vic_appliance_address</i>:9443

    The first two formats redirect automatically to https://<i>vic_appliance_address</i>:9443. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, the redirect uses the port specified during deployment. If you specify HTTPS, you must include the port number in the address. 

    Wait for a few minutes to allow the appliance services to start. During this time, you see the message `The VIC Appliance is initializing`. When the initialization finishes, the Complete VIC appliance installation panel appears automatically. If you see a page not found error during initialization, refresh your browser.

12. Enter the connection details for the vCenter Server instance on which you deployed the appliance.

     - The vCenter Server address and the Single Sign-on credentials for a vSphere administrator account.
     - If vCenter Server is managed by an external Platform Services Controller, enter the FQDN and administrator domain for the Platform Services Controller. If vCenter Server is managed by an embedded Platform Services Controller, leave the External PSC text boxes empty.

    **IMPORTANT**: The installation process requires administrator credentials to register vSphere Integrated Containers Management Portal and Registry with the Platform Services Controller and to tag the appliance VM for use in Docker content trust. Administrator credentials are not stored on the appliance VM after use in the installation process. The vSphere Integrated Containers Management Portal and Registry services cannot start if you do not complete this step.

12. To automatically install the vSphere Integrated Containers plug-in for vSphere Client, leave the **Install UI Plugin** check box selected.

    **NOTE**: The option to automatically install the  plug-in for the vSphere Client is available in vSphere Integrated Containers 1.4.3 and later. However, if you are already running other instances of the vSphere Integrated Containers appliance that are of a different version, deselect the **Install UI Plugin** check box. You can install or upgrade the plug-in manually later. If you are installing a version of vSphere Integrated Containers that pre-dates 1.4.3, you must install the plug-in manually.
13. Verify that the certificate thumbprint for vCenter Server is valid, and click **Continue** to initialize the appliance.

**Result**

You see the vSphere Integrated Containers Getting Started page. The Getting Started page includes the following links: 

- vSphere Integrated Containers Management Portal
- The download for the vSphere Integrated Containers Engine bundle
- Documentation

**What to Do Next**

- If you installed vSphere Integrated Containers 1.4.3 or later and selected **Install UI Plugin**, access the  vSphere Integrated Containers plug-in for vSphere Client:
   1. Log out of the HTML5 vSphere Client and log back in again. You should see a banner that states `There are plug-ins that were installed or updated`.
   2. Log out of the HTML5 vSphere Client a second time and log back in again.
   3. Click the **vSphere Client** logo in the top left corner. 
   4. Under Inventories, click **vSphere Integrated Containers** to access the vSphere Integrated Containers plug-in.
- If you deselected the **Install UI Plugin** check box, or if you installed a version of vSphere Integrated Containers that pre-dates 1.4.3, [Manually Install the vSphere Client Plug-ins](install_vic_plugin.md).
- [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md).
- Log in to vSphere Integrated Containers Management Portal. For information about the management portal, see [vSphere Integrated Containers Management Portal Administration](../vic_cloud_admin/).      
- If you need to deploy multiple appliances, you can use the initialization API to initialize appliances without manual intervention. For information about the initialization API, see [Initialize the Appliance by Using the Initialization API](ova_reg_api.md).

**Troubleshooting**

- For information about how to access the logs for the appliance, see [Access and Configure Appliance Logs](appliance_logs.md).
- If you do not see a green success banner at the top of the Getting Started page after initializing the appliance, the appliance has not initialized correctly. For more information, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md).
- If deployment of the appliance fails, see [Troubleshoot vSphere Integrated Containers Appliance Deployment](ts_deploy_appliance.md).
- If you see errors when attempting to connect to the Getting Started page or to vSphere Integrated Containers Management Portal, or when downloading the vSphere Integrated Containers Engine bundle, see [Troubleshoot Post-Deployment Operation](ts_post_deployment_op.md).
- To remove security warnings when you connect to the Getting Started page or management portal, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](obtain_appliance_certs.md) and [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).
- If necessary, you can reconfigure the appliance after deployment by editing the settings of the appliance VM. For information about reconfiguring the appliance and other post-installation management tasks, see [Manage the vSphere Integrated Containers Appliance](manage_appliance.md).