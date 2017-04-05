# Install the Client Plug-Ins on vCenter Server for Windows #

You install the vSphere Client plug-ins for vSphere Integrated Containers by using the Web server that runs in the vSphere Integrated Containers appliance.

- You can install the the Flex-based vSphere Web Client plug-in on vCenter Server 6.0 or 6.5.
- You can install the the HTML5 vSphere Client plug-in on vCenter Server 6.5.

**Prerequisites**

- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Open a Web browser on a Windows system, go to https://<i>vic_appliance_address</i>:9443, and download and unpack the vSphere Integrated Containers Engine package. You must use a Windows system to run the script to install the plug-in on a vCenter Server instance that runs on Windows. For example, download the package to the Windows system on which vCenter Server is running. If you configured the vSphere Integrated Containers appliance to use a different port for the vSphere Integrated Containers Engine file server, replace 9443 with the appropriate port.
- Copy the thumbprint of the Communications Server certificate from https://<i>vic_appliance_address</i>:<i>port</i>. For information about how to view the certificate thumbprint, see the documentation for your type of browser.

**Procedure**

1. On the Windows system on which you have downloaded and unpacked vSphere Integrated Containers Engine, open the `\vic\ui\vCenterForWindows\configs` file in a text editor.
3. Enter the IPv4 address or FQDN of the vCenter Server instance on which to install the plug-in.<pre>SET target_vcenter_ip=<i>vcenter_server_address</i></pre>
4. Enter the URL on which the vSphere Integrated Containers appliance publishes the client plug-in bundle. <pre>SET vic_ui_host_url=https://<i>vic_appliance_address</i>:<i>port</i></pre>
6. Provide the SHA-1 thumbprint of the Web server.<pre>SET vic_ui_host_thumbprint=<i>thumbprint</i></pre>**NOTE**: Use colon delimitation in the thumbprint. Do not use space delimitation. 
7. Specify the version of the plug-in to install.
  - To install the plug-in for the HTML5 vSphere Client, leave the vCenter Server version set to `6.5`.
  - To install the plug-in for the Flex-based vSphere Web Client, set the vCenter Server version to `6.0`.<pre>SET target_vc_version=6.0</pre>**NOTE**: When installing the Flex-based plug-in, you must set the version to `6.0` even if you are running vCenter Server 6.5.
6. Save and close the `configs` file.
7. Open a Windows command prompt, navigate to `\vic\ui\vCenterForWindows`, and run the installer.<pre>install.bat</pre>
9. Enter the user name and password for the vCenter Server administrator account.
10. When installation finishes, if you are logged into the vSphere Web Client, log out then log back in again.

**What to Do Next**

Verify the deployment of the plug-in.

- If you installed the HTML5 plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md).
- If you installed the Flex plug-in, see [Find VCH Information in the vSphere Clients](vch_portlet_ui.md).

If the vSphere Integrated Containers plug-in does not appear, restart the vSphere Client service. For instructions about how to restart the vSphere Client service, see [vSphere Integrated Containers Plug-In Does Not Appear](ts_ui_not_appearing.md).