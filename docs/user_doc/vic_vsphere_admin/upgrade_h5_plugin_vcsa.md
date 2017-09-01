# Upgrade the Plug-Ins on vCenter Server Appliance #

If you have a previous 1.1.x installation of the plug-ins for vSphere Integrated Containers, you must upgrade them. This procedure describes how to upgrade an existing plug-ins for a vCenter Server Appliance.

**Prerequisites**

- You are upgrading the plug-ins on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md).
- You deployed the vSphere Integrated Containers plug-ins with vSphere Integrated Containers 1.1.x. For information about installing the plug-ins for the first time, see [Install the Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md).
- You upgraded an existing vSphere Integrated Containers 1.2.x appliance to a newer 1.2.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain the Certificate Thumbprint of vCenter Server or an ESXi Host](obtain_thumbprint.md).
- The system on which you run the script is running `awk`.

**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
4. Use `curl` to copy the new vSphere Integrated Containers Engine binaries from the file server in the upgraded vSphere Integrated Containers appliance to the vCenter Server Appliance.<pre>curl -k https://<i>upgraded_vic_appliance_address</i>:9443/files/vic_1.2.x.tar.gz -o vic_1.2.x.tar.gz</pre>**NOTE**: Update `vic_1.2.x` to the appropriate version in the command above and in the next step.
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf vic_1.2.x.tar.gz</pre>
6. Navigate to `/vic/ui/VCSA`, run the upgrade script, and follow the prompts.<pre>cd vic/ui/VCSA</pre><pre>./upgrade.sh</pre>
	1. Enter the IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
	3. (Optional) If the version that you try to install is same or older than the one already installed, enter **yes** to force reinstall and wait for the process to finish.  
10. When the installation finishes, stop and restart the services of your management clients.
	1. Restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
	2. Restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

Log in to the management clients, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.
