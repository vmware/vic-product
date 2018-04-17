# Install the Client Plug-Ins on a vCenter Server Appliance #

You install the vSphere Client plug-ins for vSphere Integrated Containers by logging into the vCenter Server appliance and running a script.  The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.

The installer installs a basic plug-in for the Flex-based vSphere Web Client on vCenter Server 6.0, 6.5, or 6.7, and a plug-in with more complete functionality for the HTML5 vSphere Client on vCenter Server 6.5 and 6.7.

**Prerequisites**

- The HTML5 plug-in requires vCenter Server 6.7 or vCenter Server 6.5.0d or later. The HTML5 plug-in does not function with earlier versions of vCenter Server 6.5.0.
- You are installing the plug-ins on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Install the Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md).
- You have not installed a previous version of the plug-ins. To upgrade a previous installation, see [Upgrade the vSphere Client Plug-Ins on vCenter Server Appliance](upgrade_h5_plugin_vcsa.md).
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, log in as the appliance `root` user, then click **Access**, and make sure that SSH Login and Bash Shell are enabled.
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
- The system on which you run the script is running `awk`.

**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
4. Start bash.<pre>shell</i></pre>
5. Set the following environment variables:

    - vSphere Integrated Containers appliance address:<pre>export VIC_ADDRESS=<i>vic_appliance_address</i></pre>
    - vSphere Integrated Containers Engine bundle file:<pre>export VIC_BUNDLE=vic_v1.4.0.tar.gz</pre>

    If you have installed a different version of the appliance, update `1.4.0` to the appropriate version in the command above. You can see the correct version by going to https://<i>vic_appliance_address</i>:9443/files/ in a browser.
5. Use `curl` to copy the vSphere Integrated Containers Engine binaries from the vSphere Integrated Containers appliance file server to the vCenter Server Appliance.

    Copy and paste the following command as shown:<pre>curl -kL https://${VIC_ADDRESS}:9443/files/${VIC_BUNDLE} -o ${VIC_BUNDLE}</pre>
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf ${VIC_BUNDLE}</pre>
9. Run the installer script and follow the prompts.
	1. Navigate to the folder that contains the installer script.<pre>cd vic/ui/VCSA</pre>
	2. Run the script.<pre>./install.sh</pre>
	2. Enter the IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
10. When the installation finishes, stop and restart the services of your management clients.
	1. Restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui && service-control --start vsphere-ui</pre>
	2. Restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client && service-control --start vsphere-client</pre>
11. Delete the vSphere Integrated Containers Engine binaries from the vCenter Server Appliance and close the SSH connection.
	1. `cd ../../..`
	2. `rm *.tar.gz`
	3. `rm -R vic`
	4. `exit`

**What to Do Next**

If you see the error message `At least one plugin is already registered with the target VC`, see [Upgrade the vSphere Client Plug-Ins on vCenter Server Appliance](upgrade_h5_plugin_vcsa.md). 

To verify the deployment of the plug-ins, see [VCH Administration in the vSphere Client](vch_admin_client.md).
