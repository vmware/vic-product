# Upgrade the vSphere Client Plug-Ins on vCenter Server for Windows #

If you have previous installations of the vSphere Client plug-ins for vSphere Integrated Containers, you must upgrade them. This procedure describes how to upgrade existing plug-ins for a vCenter Server running on Windows.

**Prerequisites**

- You are upgrading the plug-ins on a vCenter Server instance that runs on Windows. If you are running a vCenter Server appliance instance, see [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md).
- You deployed the vSphere Integrated Containers plug-ins with vSphere Integrated Containers 1.2.x. For information about installing the plug-ins for the first time, see [Install the Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md).
- You upgraded an existing vSphere Integrated Containers 1.3.x appliance to a newer 1.3.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).
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

     **NOTE**: The Flex-based plug-in has no new features in this release. However, the upgrade script updates the metadata for the Flex-based client. Consequently, you must restart both of the HTML5 and Flex-based clients.

    - HTML5 vSphere Client: <pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
    - Flex-based vSphere Web Client:<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

Log in to the HTML5 vSphere Client, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.
