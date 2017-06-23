# Install the Client Plug-Ins on a vCenter Server Appliance #

You install the vSphere Client plug-ins for vSphere Integrated Containers by logging into the vCenter Server appliance and running a script.  The script registers an extension with vCenter Server, and instructs vCenter Server to download the plug-in files from the file server in the vSphere Integrated Containers appliance.
- You can install the the Flex-based vSphere Web Client plug-in on vCenter Server 6.0 or 6.5.
- You can install the the HTML5 vSphere Client plug-in on vCenter Server 6.5.

**Prerequisites**

- You are installing the plug-ins on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Install the Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md).
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.
- You deployed the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

**NOTE**: If the vSphere Integrated Containers appliance uses a different port for the file server, replace 9443 with the appropriate port in the procedure below.


**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
4. Use `curl` to copy the vSphere Integrated Containers Engine binaries from the vSphere Integrated Containers appliance file server to the vCenter Server Appliance.<pre>curl -k https://<i>vic_appliance_address</i>:9443/vic_1.2.x.tar.gz -o vic_1.2.x.tar.gz</pre>**NOTE**: Update `vic_1.2.x` to the appropriate version in the command above and in the next step.
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf vic_1.2.x.tar.gz</pre>
5. Set the IPv4 address or FQDN of the vCenter Server instance in the `/vic/ui/VCSA/configs` file.<pre>VCENTER_IP="<i>vcsa_address</i>"</pre>

   Alternatively, you can use a utility such as `sed` to update the `configs` file:<pre>sed -i 's#^\(VCENTER_IP=\).*$#\1"<i>vcsa_address</i>"#' ~/vic/ui/*/configs</pre>
6. Set the URL of the vSphere Integrated Containers appliance file server in the `/vic/ui/VCSA/configs` file.<pre>VIC_UI_HOST_URL="https://<i>vic_appliance_address</i>:9443/"</pre>You must enter the full URL and include the closing forward slash (`/`) after the port number. 

   Alternatively, you can use `sed`:<pre>sed -i 's#^\(VIC_UI_HOST_URL=\).*$#\1"https://<i>vic_appliance_address</i>:9443"#' ~/vic/ui/*/configs</pre>
7. Obtain the thumbprint of the vSphere Integrated Containers appliance file server certificate.<pre>echo | openssl s_client -connect <i>vic_appliance_address</i>:9443 | openssl x509 -fingerprint -sha1 -noout</pre>Do not include the HTTPS prefix in <i>vic_appliance_address</i>:9443.
8.  Set the certificate thumbprint in the `/vic/ui/VCSA/configs` file, replacing <i>thumbprint</i> with the output of the command from the preceding step.<pre>VIC_UI_HOST_THUMBPRINT="<i>thumbprint</i>"</pre>

   Alternatively, you can use `sed`:<pre>sed -i 's#^\(VIC_UI_HOST_THUMBPRINT=\).*$#\1"<i>thumbprint</i>"#' ~/vic/ui/*/configs</pre>
9. Navigate to `/vic/ui/VCSA`, and run the installer script, entering the user name and password for the vCenter Server administrator account when prompted.<pre>cd vic/ui/VCSA</pre><pre>./install.sh</pre>This first run of the script installs the HTML5 client.
10. When the installation finishes, stop and restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>
10. To install the plug-in for the Flex-based vSphere Web Client, edit `/vic/ui/VCSA/configs` again and set the plug-in type to `flex`.<pre>PLUGIN_TYPE="flex"</pre>

   Alternatively, you can use `sed`:<pre>sed -i 's#^\(PLUGIN_TYPE=\).*$#\1"flex"#' ~/vic/ui/*/configs</pre>
11. Run the installer script, entering the user name and password for the vCenter Server administrator account when prompted.<pre>cd vic/ui/VCSA</pre><pre>./install.sh</pre>
10. When the installation finishes, stop and restart the Flex-based vSphere Web Client service.<pre>service-control --stop vsphere-client</pre><pre>service-control --start vsphere-client</pre>

**What to Do Next**

To verify the deployment of the plug-in, see [Access the vSphere Integrated Containers View in the HTML5 vSphere Client](access_h5_ui.md), [Find VCH Information in the vSphere Clients](vch_portlet_ui.md), and [Find Container Information in the vSphere Clients](container_portlet_ui.md).