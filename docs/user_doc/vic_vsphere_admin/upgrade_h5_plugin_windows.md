# Upgrade the vSphere Client Plug-In on vCenter Server for Windows #

If you have upgraded to a version of vSphere Integrated Containers that pre-dates 1.4.3, you must upgrade the plug-in manually. This procedure describes how to upgrade existing plug-in for a vCenter Server running on Windows.

**NOTE**: This procedure is not relevant to vSphere Integrated Containers 1.4.3 or later. When upgrading to vSphere Integrated Containers 1.4.3 or later the plug-in is upgraded automatically.

**Prerequisites**

- You have upgraded the vSphere Integrated Containers appliance to a  version that pre-dates 1.4.3.
- You are upgrading the plug-in on a vCenter Server instance that runs on Windows. If you are running a vCenter Server appliance instance, see [Manually Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md).
- You deployed the vSphere Integrated Containers plug-in with vSphere Integrated Containers 1.2.x or 1.3.x. For information about installing the plug-in for the first time, see [Manually Install the Client Plug-In on vCenter Server for Windows](plugins_vc_windows.md).
- You upgraded an existing vSphere Integrated Containers 1.4.x appliance to a newer 1.4.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).

    **IMPORTANT**: 
    
    - vSphere Integrated Containers 1.4.2 includes version 1.4.1 of the vSphere Integrated Containers plug-in for vSphere Client. If you are upgrading vSphere Integrated Containers from version 1.4.1 to 1.4.2, you must still upgrade the client plug-in after you upgrade the appliance. This is so that the plug-in registers correctly with the upgraded appliance. If you do not upgrade the plug-in after upgrading the appliance to 1.4.2, the vSphere Integrated Containers view does not appear in the vSphere Client.
    - If you use vSphere 6.7 update 1 or later, you must use vSphere Integrated Containers 1.4.3 or later. Due to significant changes in the HTML5 vSphere Client in version 6.7 update 1, previous versions of the vSphere Integrated Containers plug-in for the vSphere Client might not work with that version. Only version 1.4.3 and later releases have been verified with vSphere 6.7 update 1.

- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.

    **IMPORTANT**: The upgrade script does not function if you have set the `VIC_MACHINE_THUMBPRINT` environment variable on the system on which you run the script. Delete the `VIC_MACHINE_THUMBPRINT` environment variable before running the script.
- Go to http://<i>upgraded_vic_appliance_address</i> in a Web browser, download the new version of the vSphere Integrated Containers Engine bundle and unpack it on the Desktop. 
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).

**Procedure**

1. Run the upgrade script and follow the prompts.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\upgrade.bat</pre>
	1. Enter the FQDN or IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
2. When the upgrade finishes, stop and restart the vSphere Client services.

    - HTML5 vSphere Client: <pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
    - Flex-based vSphere Web Client:<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

Log in to the HTML5 vSphere Client, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.
