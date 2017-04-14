# Upgrade the HTML5 vSphere Client Plug-In #

If you have a previous installation of the HTML5 vSphere Client plug-in for vSphere Integrated Containers and you download a new version of vSphere Integrated Containers Engine, you must upgrade the HTML5 plug-in.

**NOTE**: No new development work is planned for the plug-in for the Flex-based vSphere Web Client. In this and future releases, only the HTML5 vSphere Client will be updated. This release adds no new features to the Flex plug-in. If you installed the Flex plug-in with vSphere Integrated Containers 1.0, there is no upgrade to perform. 

The plug-in for the HTML5 vSphere Client is new in vSphere Integrated Containers 1.1. This procedure describes how to upgrade the HTML5 plug-in from version 1.1 to a later 1.x release. For information about installing the HTML5 plug-in for the first time, see [Install the HTML5 Plug-In on a vCenter Server Appliance](plugin_h5_vcsa.md) or [Install the HTML5 Plug-In on vCenter Server for Windows by Using a Web Server](plugin_h5_vc_web.md).

**Prerequisites**

- You deployed an older version of the vSphere Integrated Containers plug-in for the HTML5 vSphere Client.
- You downloaded a new version of vSphere Integrated Containers Engine.
- For information about how to update the `configs` and `install.sh` files, see [Install the HTML5 Plug-In on a vCenter Server Appliance](plugin_h5_vcsa.md) or [Install the HTML5 Plug-In on vCenter Server for Windows by Using a Web Server](plugin_h5_vc_web.md).

**Procedure**

1. If you run vCenter Server on Windows, copy the new version of the <code>com.vmware.vic-<i>version</i>.zip</code> file to the appropriate location on your Web server.
2. Update the new version of the `configs` file.

   - vCenter Server Appliance: `vic/ui/HTML5Client/configs`
   - vCenter Server on Windows: `vic/ui/vCenterForWindows/configs`
3. (Optional) If you are upgrading the plug-in on a vCenter Server Appliance and you are working on a Windows system, update the `vic/ui/HTML5Client/install.sh` file to point `PLUGIN_MANAGER_BIN` to the Windows UI executable. 
4. Run the `vic/ui/HTML5Client/upgrade.sh` or `vic/ui/vCenterForWindows/upgrade.bat` script. 
4. When the upgrade finishes, if you are logged into the vSphere Client, log out then log back in again.