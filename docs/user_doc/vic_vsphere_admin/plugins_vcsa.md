# Install the Client Plug-Ins on a vCenter Server Appliance #

You install the vSphere Client plug-ins for vSphere Integrated Containers by logging into the vCenter Server appliance and running a script.  The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.

The installer installs a basic plug-in for the Flex-based vSphere Web Client on vCenter Server 6.0 or 6.5 and a plug-in with more complete functionality for the HTML5 vSphere Client on vCenter Server 6.5.

**Prerequisites**

- You are installing the plug-ins on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Install the Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md).
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
4. Use `curl` to copy the vSphere Integrated Containers Engine binaries from the vSphere Integrated Containers appliance file server to the vCenter Server Appliance.<pre>curl -k https://<i>vic_appliance_address</i>:9443/files/vic_1.2.x.tar.gz -o vic_1.2.x.tar.gz</pre>**NOTE**: Update `vic_1.2.x` to the appropriate version in the command above and in the next step.
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf vic_1.2.x.tar.gz</pre>
9. Navigate to `/vic/ui/VCSA`, run the installer script, and follow the prompts.<pre>cd vic/ui/VCSA</pre><pre>./install.sh</pre>
	1. Enter the IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** to confirm that you trust the host and wait for the install process to finish. 
10. When the installation finishes, stop and restart the services of your management clients.
	1. Restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
	2. Restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

To verify the deployment of the plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md), [Find VCH Information in the vSphere Clients](vch_portlet_ui.md), and [Find Container Information in the vSphere Clients](container_portlet_ui.md).
