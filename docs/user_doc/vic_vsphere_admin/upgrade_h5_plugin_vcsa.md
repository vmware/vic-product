# Upgrade the vSphere Client Plug-Ins on vCenter Server Appliance #

If you have previous installations of the vSphere Client plug-ins for vSphere Integrated Containers, you must upgrade them. This procedure describes how to upgrade existing plug-ins for a vCenter Server Appliance.

**Prerequisites**

- You are upgrading the plug-ins on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md).
- You deployed the vSphere Integrated Containers plug-ins with vSphere Integrated Containers 1.2.x. For information about installing the plug-ins for the first time, see [Install the Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md).
- You upgraded an existing vSphere Integrated Containers 1.3.x appliance to a newer 1.3.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
- The system on which you run the script is running `awk`.

**IMPORTANT**: The upgrade script does not function if you have set the `VIC_MACHINE_THUMBPRINT` environment variable on the system on which you run the script. Delete the `VIC_MACHINE_THUMBPRINT` environment variable before running the script.

**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
4. Use `curl` to copy the new vSphere Integrated Containers Engine binaries from the file server in the upgraded vSphere Integrated Containers appliance to the vCenter Server Appliance.<pre>curl -k https://<i>upgraded_vic_appliance_address</i>:9443/files/vic_<i>version</i>.tar.gz -o vic_<i>version</i>.tar.gz</pre>**NOTE**: Update `vic_version` to the appropriate version in the command above and in the next step.
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf vic_<i>version</i>.tar.gz</pre>
6. Navigate to `/vic/ui/VCSA`, run the upgrade script, and follow the prompts.<pre>cd vic/ui/VCSA</pre><pre>./upgrade.sh</pre>
	1. Enter the FQDN or IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
	3. (Optional) If the version that you try to install is same or older than the one already installed, enter **yes** to force reinstall and wait for the process to finish.  
10. When the upgrade finishes, stop and restart the vSphere Client services.

     **NOTE**: The Flex-based plug-in has no new features in this release. However, the upgrade script updates the metadata for the Flex-based client. Consequently, you must restart both of the HTML5 and Flex-based clients.    

    - HTML5 vSphere Client: <pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
    - Flex-based vSphere Web Client:<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

Log in to the HTML5 vSphere Client, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.
