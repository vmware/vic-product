# Install the Client Plug-Ins on vCenter Server for Windows #

You install the vSphere Client plug-ins for vSphere Integrated Containers by logging in to the Windows system on which vCenter Server runs and running a script. The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.

- You can install the the Flex-based vSphere Web Client plug-in on vCenter Server 6.0 or 6.5.
- You can install the the HTML5 vSphere Client plug-in on vCenter Server 6.5.

**Prerequisites**

- The vCenter Server instance on which to install the plug-in runs on Windows. If you are running a vCenter Server appliance instance, see [Install the Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md).
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.
- Go to https://<i>vic_appliance_address</i>:9443 in a Web browser, download the vSphere Integrated Containers Engine package, `vic_1.1.x.tar.gz`, and unpack it on the Desktop. 

**NOTE**: If the vSphere Integrated Containers appliance uses a different port for the file server, replace 9443 with the appropriate port in the prerequisites above and in the procedure below.

**Procedure**

1. Open a command prompt as Administrator and run the following command to obtain the SHA-1 thumprint of the file server that is running in the vSphere Integrated Containers appliance.<pre>echo | "%VMWARE_OPENSSL_BIN%" s_client -connect <i>vic_appliance_address</i>:9443 | "%VMWARE_OPENSSL_BIN%" x509 -fingerprint -sha1 -noout</pre>
2. Open the `\vic\ui\vCenterForWindows\configs` file in a text editor.<pre>notepad %USERPROFILE%\Desktop\vic\ui\vCenterForWindows\configs</pre>
3. Enter the IPv4 address or FQDN of the vCenter Server instance on which to install the plug-in.<pre>SET target_vcenter_ip=<i>vcenter_server_address</i></pre>
4. Enter the URL of the vSphere Integrated Containers appliance file server. <pre>SET vic_ui_host_url=https://<i>vic_appliance_address</i>:9443/</pre>You must enter the full URL and include the closing forward slash (`/`) after the port number. 
6. Copy the SHA-1 thumbprint of the file server that you obtained in step 1 and paste it into the `configs` file.<pre>SET vic_ui_host_thumbprint=<i>thumbprint</i></pre>**NOTE**: Use colon delimitation in the thumbprint. Do not use space delimitation. 
7. Save the `configs` file.
8. Open the `\vic\ui\vCenterForWindows\install.bat` file in a text editor.<pre>notepad %USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
9. Insert a missing `v` character before `%version%.zip` in the following line and save the `install.bat` file:

    - Before: `SET PLUGIN_URL=%vic_ui_host_url%%key%-%version%.zip`
    - After: `SET PLUGIN_URL=%vic_ui_host_url%%key%-v%version%.zip`
8. Run the installer, entering the user name and password for the vCenter Server administrator account when prompted.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>This first run of the script installs the HTML5 client.
9. When the installation finishes, stop and restart the HTML5 vSphere Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vsphere-ui</pre>
<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vsphere-ui</pre>
7. To install the plug-in for the Flex-based vSphere Web Client, reopen the `configs` file and set the target version to `6.0`.<pre>SET target_vc_version=6.0</pre>
6. Save and close the `configs` file.
7. Run the installer again, entering the user name and password for the vCenter Server administrator account when prompted.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\install.bat</pre>
9. When the installation finishes, stop and restart the vSphere Web Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vspherewebclientsvc</pre>
   <pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vspherewebclientsvc</pre>

**What to Do Next**

To verify the deployment of the plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md), [Find VCH Information in the vSphere Clients](vch_portlet_ui.md), and [Find Container Information in the vSphere Clients](container_portlet_ui.md).