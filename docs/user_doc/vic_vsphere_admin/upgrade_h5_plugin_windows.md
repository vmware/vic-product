# Upgrade the Plug-Ins on vCenter Server for Windows #

If you have a previous 1.1.x installation of the plug-ins for vSphere Integrated Containers, you must upgrade them. This procedure describes how to upgrade an existing plug-ins for vCenter Server on Windows.

**Prerequisites**

- You are upgrading the HTML5 plug-in on a vCenter Server instance that runs on Windows. If you are running a vCenter Server appliance instance, see [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md).
- You deployed the vSphere Integrated Containers plug-ins with vSphere Integrated Containers 1.1.x. For information about installing the plug-ins for the first time, see [Install the Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md).
- You upgraded an existing vSphere Integrated Containers 1.2.x appliance to a newer 1.2.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.
- Go to https://<i>upgraded_vic_appliance_address</i>:9443 in a Web browser, download the new version of the vSphere Integrated Containers Engine package, `vic_1.2.y.tar.gz`, and unpack it on the Desktop. 

**NOTE**: If the upgraded vSphere Integrated Containers appliance uses a different port for the file server, replace 9443 with the appropriate port in the prerequisites above and in the procedure below.

**Procedure**

3. Run the upgrade script and follow the prompts.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\upgrade.bat</pre>
	1. Enter the IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** to confirm that you trust the host and wait for the install process to finish. 
10. When the installation finishes, stop and restart the services of your management clients.
	1. Restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
	2. Restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

Log in to the management clients, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.
