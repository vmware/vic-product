# Install the Client Plug-Ins on a vCenter Server Appliance #

You install the vSphere Client plug-ins for vSphere Integrated Containers by using the Web server that runs in the vSphere Integrated Containers appliance.

- You can install the the Flex-based vSphere Web Client plug-in on vCenter Server 6.0 or 6.5.
- You can install the the HTML5 vSphere Client plug-in on vCenter Server 6.5.

**Prerequisites**

- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).
- Go to https://<i>vic_appliance_address</i>:9443 and download and unpack the vSphere Integrated Containers Engine package. If you configured the vSphere Integrated Containers appliance to use a different port for the vSphere Integrated Containers Engine file server, replace 9443 with the appropriate port.
- Copy the thumbprint of the Communications Server certificate from https://<i>vic_appliance_address</i>:<i>port</i>. For information about how to view the certificate thumbprint, see the documentation for your type of browser.

**Procedure**

1. On the system on which you have downloaded and unpacked vSphere Integrated Containers Engine, open the appropriate configuration file in a text editor.

  - For the HTML5 plug-in, open `/vic/ui/HTML5Client/configs`.
  - For the Flex plug-in, open `/vic/ui/VCSA/configs`.
4. Enter the IPv4 address or FQDN of the vCenter Server Appliance on which to install the plug-in. <pre>VCENTER_IP="<i>vcenter_server_address</i>"</pre>
5. Enter the URL on which the vSphere Integrated Containers appliance publishes the client plug-in bundle. <pre>SET VIC_UI_HOST_URL="https://<i>vic_appliance_address</i>:<i>port</i>"</pre>
6. Provide the SHA-1 thumbprint of the Web server.<pre>VIC_UI_HOST_THUMBPRINT="<i>thumbprint</i>"</pre>**NOTE**: Use colon delimitation in the thumbprint. Do not use space delimitation.
6. Save and close the `configs` file.
7. (Optional) If you unpacked vSphere Integrated Containers Engine on a Windows system, open  the `/vic/ui/HTML5Client/install.sh` file in a text editor and point `PLUGIN_MANAGER_BIN` to the Windows UI executable.

   Before:
     <pre>if [[ $(echo $OS | grep -i "darwin") ]] ; then
       PLUGIN_MANAGER_BIN="../../vic-ui-darwin"
     else
       PLUGIN_MANAGER_BIN="../../vic-ui-linux"</pre>
   After:
      <pre>if [[ $(echo $OS | grep -i "darwin") ]] ; then
       PLUGIN_MANAGER_BIN="../../vic-ui-darwin"
      else
       PLUGIN_MANAGER_BIN="../../vic-ui-windows"</pre>

7. Open a command prompt, navigate to `/vic/ui/VCSA`, and run the installer.
   <pre>./install.sh</pre>

    Make sure that `install.sh` is executable by running `chmod` before you run it.
  
9. Enter the user name and password for the vCenter Server administrator account.
10. When installation finishes, if you are logged into the vSphere Client or vSphere Web Client, log out then log back in again.

**What to Do Next**

Verify the deployment of the plug-in.

- If you installed the HTML5 plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md).
- If you installed the Flex plug-in, see [Find VCH Information in the vSphere Clients](vch_portlet_ui.md).

If the vSphere Integrated Containers plug-in does not appear, restart the vSphere Client service. For instructions about how to restart the vSphere Client service, see [vSphere Integrated Containers Plug-In Does Not Appear](ts_ui_not_appearing.md).