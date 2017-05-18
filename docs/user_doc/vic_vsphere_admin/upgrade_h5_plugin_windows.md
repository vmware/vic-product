# Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows #

If you have a previous 1.1.x installation of the HTML5 vSphere Client plug-in for vSphere Integrated Containers and you download a newer 1.1.y version of vSphere Integrated Containers, you must upgrade the HTML5 plug-in. This procedure describes how to upgrade an existing HTML5 plug-in for vCenter Server on Windows.

**NOTE**: No new development work is planned for the plug-in for the Flex-based vSphere Web Client. In this and future releases, only the HTML5 vSphere Client will be updated. This release adds no new features to the Flex plug-in. If you installed the Flex plug-in with a previous release of vSphere Integrated Containers, there is no upgrade to perform. 

**Prerequisites**

- You are upgrading the HTML5 plug-in on a vCenter Server instance that runs on Windows. If you are running a vCenter Server appliance instance, see [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md).
- You deployed an older version of the vSphere Integrated Containers plug-in for the HTML5 vSphere Client with a previous version of vSphere Integrated Containers 1.1.x. For information about installing the HTML5 plug-in for the first time, see [Install the Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md).
- You upgraded an existing vSphere Integrated Containers 1.1.x appliance to a newer 1.1.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).
- Log in to the Windows system on which vCenter Server is running. You must perform all of the steps in this procedure on this Windows system.
- Go to https://<i>upgraded_vic_appliance_address</i>:9443 in a Web browser, download the new version of the vSphere Integrated Containers Engine package, `vic_1.1.y.tar.gz`, and unpack it on the Desktop. 

**NOTE**: If the upgraded vSphere Integrated Containers appliance uses a different port for the file server, replace 9443 with the appropriate port in the prerequisites above and in the procedure below.

**Procedure**

1. Open a command prompt as Administrator and run the following command to obtain the SHA-1 thumprint of the file server that is running in the  upgraded vSphere Integrated Containers appliance.<pre>echo | "%VMWARE_OPENSSL_BIN%" s_client -connect <i>upgraded_vic_appliance_address</i>:9443 | "%VMWARE_OPENSSL_BIN%" x509 -fingerprint -sha1 -noout</pre>
2. Open the new version of the `\vic\ui\vCenterForWindows\configs` file in a text editor.<pre>notepad %USERPROFILE%\Desktop\vic\ui\vCenterForWindows\configs</pre>
3. Enter the IPv4 address or FQDN of the vCenter Server instance on which to upgrade the plug-in.<pre>SET target_vcenter_ip=<i>vcenter_server_address</i></pre>
4. Enter the URL of the file server in the upgraded vSphere Integrated Containers appliance. <pre>SET vic_ui_host_url=https://<i>upgraded_vic_appliance_address</i>:9443/</pre>
6. Copy the SHA-1 thumbprint of the file server that you obtained in step 1 and paste it into the `configs` file.<pre>SET vic_ui_host_thumbprint=<i>thumbprint</i></pre>**NOTE**: Use colon delimitation in the thumbprint. Do not use space delimitation. 
7. Save the `configs` file.
8. Run the upgrade script, entering the user name and password for the vCenter Server administrator account when prompted.<pre>%USERPROFILE%\Desktop\vic\ui\vCenterForWindows\upgrade.bat</pre>
9. When the upgrade finishes, stop and restart the HTML5 vSphere Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vsphere-ui</pre>
<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vsphere-ui</pre>

**What to Do Next**

Log in to the vSphere Client, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.