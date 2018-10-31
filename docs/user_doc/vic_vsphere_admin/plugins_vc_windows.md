# Manually Install the vSphere Client Plug-In on vCenter Server for Windows #

If you installed a version of vSphere Integrated Containers that pre-dates 1.4.3, you must install the plug-in manually. You manually install the vSphere Client plug-in for vSphere Integrated Containers by logging into the vCenter Server system and running a script.  The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.

**Prerequisites**

- You are installing  a version of vSphere Integrated Containers that pre-dates 1.4.3. This procedure is not applicable to vSphere Integrated Containers 1.4.3 or later. In vSphere Integrated Containers 1.4.3 or later the plug-in is installed automatically.
- The HTML5 plug-in requires vCenter Server 6.7 or vCenter Server 6.5.0d or later. The HTML5 plug-in does not function with earlier versions of vCenter Server 6.5.0.

  **IMPORTANT**: If you use vSphere 6.7 update 1 or later, you must use vSphere Integrated Containers 1.4.3 or later. Due to significant changes in the HTML5 vSphere Client in version 6.7 update 1, previous versions of the vSphere Integrated Containers plug-in for the vSphere Client might not work with that version. Only version 1.4.3 and later releases have been verified with vSphere 6.7 update 1.
- The vCenter Server instance on which to install the plug-in runs on Windows. If you are running a vCenter Server appliance instance, see [Manually Install the Client Plug-In on a vCenter Server Appliance](plugins_vcsa.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.

    **IMPORTANT**: The upgrade script does not function if you have set the `VIC_MACHINE_THUMBPRINT` environment variable on the system on which you run the script. Delete the `VIC_MACHINE_THUMBPRINT` environment variable before running the script.
- Download the vSphere Integrated Containers Engine bundle. For information about downloading the bundle, see [Download the vSphere Integrated Containers Engine Bundle](vic_engine_bundle.md).
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

**Procedure**

1. In a command prompt terminal, run the install script and follow the prompts.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
	1. Enter the IP address of the vCenter Server instance.
	2. Enter the user name and password for the vCenter Server administrator account.
	3. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
2. When the installation finishes, stop and restart the services of your management clients.
	- Restart the HTML5 vSphere Client service on vSphere 6.5 and 6.7:<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
	- Restart the Flex-based vSphere Web Client service on vSphere 6.0:<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>
3. If this is not the machine on which you will run `vic-machine` commands, delete the vSphere Integrated Containers Engine binaries from the Windows host.

**What to Do Next**

To verify the deployment of the plug-in, see [VCH Administration in the vSphere Client](vch_admin_client.md).

**Troubleshooting**

If you see the error message `At least one plugin is already registered with the target VC`, see [Upgrade the vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md).

If you encounter other errors, or if the script runs successfully but the plug-in does not appear in the vSphere Client, see [Troubleshoot vSphere Client Plug-In Installation](ts_install_plugins.md).