# Install the Client Plug-Ins on vCenter Server for Windows #

To install the vSphere Client plug-ins for vSphere Integrated Containers, you log in to the Windows system on which vCenter Server runs and run a script. The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.

The installer installs a basic plug-in for the Flex-based vSphere Web Client on vCenter Server 6.0 or 6.5 and a plug-in with more complete functionality for the HTML5 vSphere Client on vCenter Server 6.5.

**Prerequisites**

- The vCenter Server instance on which to install the plug-in runs on Windows. If you are running a vCenter Server appliance instance, see [Install the Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md).
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.
- Go to https://<i>vic_appliance_address</i>:9443/files in a Web browser, download the vSphere Integrated Containers Engine package, `vic_1.2.x.tar.gz`, and unpack it on the Desktop. Do not download the client plug-in files, `com.vmware.vic-v1.2.x.zip` and `com.vmware.vic.ui-v1.2.x.zip`, directly from the file server. The plug-in installation script pulls these files from the file server.

**Procedure**

3. Run the install script and follow the prompts.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
	1. Enter the IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** to confirm that you trust the host and wait for the install process to finish. 
10. When the installation finishes, stop and restart the services of your management clients.
	1. Restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
	2. Restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

To verify the deployment of the plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md), [Find VCH Information in the vSphere Clients](vch_portlet_ui.md), and [Find Container Information in the vSphere Clients](container_portlet_ui.md).
