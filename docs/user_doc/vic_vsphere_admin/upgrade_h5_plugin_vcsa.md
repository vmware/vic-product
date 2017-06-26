# Upgrade HTML5 vSphere Client Plug-In on a vCenter Server Appliance #

If you have a previous 1.1.x installation of the HTML5 vSphere Client plug-in for vSphere Integrated Containers, you must upgrade the HTML5 plug-in. This procedure describes how to upgrade an existing HTML5 plug-in for a vCenter Server Appliance.

**NOTE**: No new development work is planned for the plug-in for the Flex-based vSphere Web Client. In this and future releases, only the HTML5 vSphere Client will be updated. This release adds no new features to the Flex plug-in. If you installed the Flex plug-in with a previous release of vSphere Integrated Containers, there is no upgrade to perform. 

**Prerequisites**

- You are upgrading the HTML5 plug-in on a vCenter Server appliance instance. If you are running vCenter Server on Windows, see [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md).
- You deployed the vSphere Integrated Containers plug-in for the HTML5 vSphere Client with vSphere Integrated Containers 1.1.x. For information about installing the HTML5 plug-in for the first time, see [Install the Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md).
- You upgraded an existing vSphere Integrated Containers 1.2.x appliance to a newer 1.2.y version. For information about upgrading the vSphere Integrated Containers appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md).
- Go to the vCenter Server Appliance Management Interface (VAMI) at https://<i>vcsa_address</i>:5480, click **Access**, and make sure that Bash Shell is enabled.

**NOTE**: If the upgraded vSphere Integrated Containers appliance uses a different port for the file server, replace 9443 with the appropriate port in the procedure below.

**Procedure**

1. Connect as root user to the vCenter Server Appliance by using SSH.<pre>ssh root@<i>vcsa_address</i></pre>
4. Use `curl` to copy the new vSphere Integrated Containers Engine binaries from the file server in the upgraded vSphere Integrated Containers appliance to the vCenter Server Appliance.<pre>curl -k https://<i>upgraded_vic_appliance_address</i>:9443/vic_1.2.x.tar.gz -o vic_1.2.x.tar.gz</pre>**NOTE**: Update `vic_1.2.x` to the appropriate version in the command above and in the next step.
5. Unpack the vSphere Integrated Containers binaries.<pre>tar -zxf vic_1.2.x.tar.gz</pre>
5. Use a text editor to set the IPv4 address or FQDN of the vCenter Server instance in the `/vic/ui/VCSA/configs` file.<pre>VCENTER_IP="<i>vcsa_address</i>"</pre>

   Alternatively, you can use a utility such as `sed` to update the `configs` file:<pre>sed -i 's#^\(VCENTER_IP=\).*$#\1"<i>vcsa_address</i>"#' ~/vic/ui/*/configs</pre>
6. Set the address of the upgraded vSphere Integrated Containers appliance in the `/vic/ui/VCSA/configs` file.<pre>VIC_UI_HOST_URL="https://<i>upgraded_vic_appliance_address</i>:9443/"</pre>You must enter the full URL and include the closing forward slash (`/`) after the port number. 

   Alternatively, you can use `sed`:<pre>sed -i 's#^\(VIC_UI_HOST_URL=\).*$#\1"https://<i>upgraded_vic_appliance_address</i>:9443"#' ~/vic/ui/*/configs</pre>
7. Obtain the thumbprint of the upgraded vSphere Integrated Containers appliance file server certificate.<pre>echo | openssl s_client -connect <i>upgraded_vic_appliance_address</i>:9443 | openssl x509 -fingerprint -sha1 -noout</pre>Do not include the HTTPS prefix in <i>upgraded_vic_appliance_address</i>:9443.
8.  Set the certificate thumbprint in the `/vic/ui/VCSA/configs` file, replacing <i>thumbprint</i> with the output of the command from the preceding step.<pre>VIC_UI_HOST_THUMBPRINT="<i>thumbprint</i>"</pre>

   Alternatively, you can use `sed`:<pre>sed -i 's#^\(VIC_UI_HOST_THUMBPRINT=\).*$#\1"<i>thumbprint</i>"#' ~/vic/ui/*/configs</pre>
9. Navigate to `/vic/ui/VCSA`, and run the upgrade script, entering the user name and password for the vCenter Server administrator account when prompted.<pre>cd vic/ui/VCSA</pre><pre>./upgrade.sh</pre>
10. When the upgrade finishes, stop and restart the HTML5 vSphere Client service.<pre>service-control --stop vsphere-ui</pre><pre>service-control --start vsphere-ui</pre>

**What to Do Next**

Log in to the vSphere Client, go to the vSphere Integrated Containers view, and verify that the version number reflects the upgrade.