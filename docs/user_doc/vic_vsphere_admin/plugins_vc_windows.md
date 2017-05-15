# Install the Client Plug-Ins on vCenter Server for Windows #

You install the vSphere Client plug-ins for vSphere Integrated Containers by using the file server that runs in the vSphere Integrated Containers appliance.

- You can install the the Flex-based vSphere Web Client plug-in on vCenter Server 6.0 or 6.5.
- You can install the the HTML5 vSphere Client plug-in on vCenter Server 6.5.

**Prerequisites**

- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.
- Go to https://<i>vic_appliance_address</i>:9443 in a Web browser, and download the vSphere Integrated Containers Engine package, `vic_1.1.x.tar.gz`, and unpack it on the Desktop. 

**NOTE**: If the vSphere Integrated Containers appliance uses a different port for the file server, replace 9443 with the appropriate port in the prerequisites above and in the procedure below.

**Procedure**

1. Open a command prompt and run the following command to obtain the SHA-1 thumprint of the file server that is running in the vSphere Integrated Containers appliance.<pre>echo | "%VMWARE_OPENSSL_BIN%" s_client -connect <i>vic_appliance_address</i>:9443 | "%VMWARE_OPENSSL_BIN%" x509 -fingerprint -sha1 -noout</pre>
2. Open the `\vic\ui\vCenterForWindows\configs` file in a text editor.<pre>notepad %USERPROFILE%\Desktop\vic\ui\vCenterForWindows\configs</pre>
3. Enter the IPv4 address or FQDN of the vCenter Server instance on which to install the plug-in.<pre>SET target_vcenter_ip=<i>vcenter_server_address</i></pre>
4. Enter the URL of the vSphere Integrated Containers appliance file server. <pre>SET vic_ui_host_url=https://<i>vic_appliance_address</i>:9443/</pre>
6. Copy and paste the SHA-1 thumbprint of the file server into the `\vic\ui\vCenterForWindows\configs` file.<pre>SET vic_ui_host_thumbprint=<i>thumbprint</i></pre>**NOTE**: Use colon delimitation in the thumbprint. Do not use space delimitation. 
7. Save the `configs` file.
8. Run the installer, entering the user name and password for the vCenter Server administrator account when prompted.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
7. To also install the plug-in for the Flex-based vSphere Web Client, reopen the `\vic\ui\vCenterForWindows\configs` file and set the target version to `6.0`.<pre>SET target_vc_version=6.0</pre>
6. Save and close the `configs` file.
7. Run the installer again, entering the user name and password for the vCenter Server administrator account when prompted.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
10. When installation finishes, if you are logged into the vSphere Web Client, log out then log back in again.

**What to Do Next**

Verify the deployment of the plug-in.

- If you installed the HTML5 plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md).
- If you installed the Flex plug-in, see [Find VCH Information in the vSphere Clients](vch_portlet_ui.md).

If the vSphere Integrated Containers plug-in does not appear, restart the vSphere Client service. For instructions about how to restart the vSphere Client service, see [vSphere Integrated Containers Plug-In Does Not Appear](ts_ui_not_appearing.md).