# Install the Client Plug-Ins on vCenter Server for Windows #

To install the vSphere Client plug-ins for vSphere Integrated Containers, you log in to the Windows system on which vCenter Server runs and run a script. The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.

The installer installs a basic plug-in for the Flex-based vSphere Web Client on vCenter Server 6.0 or 6.5 and a plug-in with more complete functionality for the HTML5 vSphere Client on vCenter Server 6.5.

**Prerequisites**

- The HTML5 plug-in requires vCenter Server 6.5.0d or later. The HTML5 plug-in does not function with earlier versions of vCenter Server 6.5.0.
- The vCenter Server instance on which to install the plug-in runs on Windows. If you are running a vCenter Server appliance instance, see [Install the Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md).
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.

    **IMPORTANT**: The upgrade script does not function if you have set the `VIC_MACHINE_THUMBPRINT` environment variable on the system on which you run the script. Delete the `VIC_MACHINE_THUMBPRINT` environment variable before running the script.
- In a Web browser, go to  http://<i>vic_appliance_address</i>, scroll down to Infrastructure Deployment Tools, click the link to **download the vSphere Integrated Containers Engine bundle**, and unpack it on the Desktop.  
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

**Procedure**

3. Run the install script and follow the prompts.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
	1. Enter the IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
10. When the installation finishes, stop and restart the services of your management clients.
	1. Restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui && service-control --start vsphere-ui</pre>
	2. Restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client && service-control --start vsphere-client</pre>

**What to Do Next**

To verify the deployment of the plug-ins, see [VCH Administration in the vSphere Client](vch_admin_client.md).
