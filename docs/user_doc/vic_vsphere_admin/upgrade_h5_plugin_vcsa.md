# Manually Upgrade the vSphere Client Plug-In on vCenter Server Appliance #

If you have upgraded to a version of vSphere Integrated Containers that pre-dates 1.4.3, you must upgrade the plug-in manually. This procedure describes how to upgrade an existing plug-in for a vCenter Server Appliance.

**NOTE**: This procedure is not relevant to vSphere Integrated Containers 1.4.3 or later. When upgrading to vSphere Integrated Containers 1.4.3 or later the plug-in is upgraded automatically.

**Prerequisites**

- You have upgraded the vSphere Integrated Containers appliance to a  version that pre-dates 1.4.3.
- You are upgrading the plug-in on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Manually Upgrade the  vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md).
- You deployed the vSphere Integrated Containers plug-in with vSphere Integrated Containers 1.2.x or 1.3.x. For information about installing the plug-in for the first time, see [Manually Install the vSphere Client Plug-In on a vCenter Server Appliance](plugins_vcsa.md). 
- You upgraded an existing vSphere Integrated Containers 1.4.x appliance to a newer 1.4.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).

    **IMPORTANT**: 
    
    - vSphere Integrated Containers 1.4.2 includes version 1.4.1 of the vSphere Integrated Containers plug-in for vSphere Client. If you are upgrading vSphere Integrated Containers from version 1.4.1 to 1.4.2, you must still upgrade the client plug-in after you upgrade the appliance. This is so that the plug-in registers correctly with the upgraded appliance. If you do not upgrade the plug-in after upgrading the appliance to 1.4.2, the vSphere Integrated Containers view does not appear in the vSphere Client.
    - If you use vSphere 6.7 update 1 or later, you must use vSphere Integrated Containers 1.4.3 or later. Due to significant changes in the HTML5 vSphere Client in version 6.7 update 1, previous versions of the vSphere Integrated Containers plug-in for the vSphere Client might not work with that version. Only version 1.4.3 and later releases have been verified with vSphere 6.7 update 1.
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.
- Obtain the vCenter Server certificate thumbprint. For information about how to obtain and verify the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).
- The system on which you run the script is running `awk`.

**IMPORTANT**: The upgrade script does not function if you have set the `VIC_MACHINE_THUMBPRINT` environment variable on the system on which you run the script. Delete the `VIC_MACHINE_THUMBPRINT` environment variable before running the script.

**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
2. Start bash.<pre>shell</i></pre>
2. Set the following environment variables:

    - vSphere Integrated Containers appliance address:<pre>export VIC_ADDRESS=<i>vic_appliance_address</i></pre>
    - vSphere Integrated Containers Engine bundle file, depending on the version that you are installing:
      - vSphere Integrated Containers 1.4.0: <pre>export VIC_BUNDLE=vic_v1.4.0.tar.gz</pre>
      - vSphere Integrated Containers 1.4.1 and 1.4.2: <pre>export VIC_BUNDLE=vic_v1.4.1.tar.gz</pre>

    **NOTE**: vSphere Integrated Containers 1.4.1 and 1.4.2 both use the `vic_v1.4.1.tar.gz` bundle. You can check which version of the bundle your installation uses by going to https://<i>vic_appliance_address</i>:9443/files/ in a browser. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, replace 9443 with the appropriate port.
4. Use `curl` to copy the new vSphere Integrated Containers Engine binaries from the file server in the upgraded vSphere Integrated Containers appliance to the vCenter Server Appliance.

    Copy and paste the following command as shown:<pre>curl -kL https://${VIC_ADDRESS}:9443/files/${VIC_BUNDLE} -o ${VIC_BUNDLE}</pre>If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, replace 9443 with the appropriate port.
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf ${VIC_BUNDLE}</pre>
6. Navigate to `/vic/ui/VCSA`, run the upgrade script, and follow the prompts.<pre>cd vic/ui/VCSA</pre><pre>./upgrade.sh</pre>
	1. Enter the FQDN or IP address of the vCenter Server instance.
	1. Enter the user name and password for the vCenter Server administrator account.
	2. Enter **yes** if the vCenter Server certificate thumbprint is legitimate, and wait for the install process to finish. 
	3. (Optional) If the version that you try to install is same or older than the one already installed, enter **yes** to force reinstall and wait for the process to finish.  
10. When the upgrade finishes, stop and restart the vSphere Client services.   

    <pre>service-control --stop vsphere-ui && service-control --start vsphere-ui && service-control --stop vsphere-client && service-control --start vsphere-client</pre>

**What to Do Next**

Log in to the HTML5 vSphere Client, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.
