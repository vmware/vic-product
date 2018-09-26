# Appliance Boot Errors #

After you deploy the vSphere Integrated Containers appliance, you power it on and it boots. When it boots, the appliance uses user provided configuration and starts an SSH server and certain services. 

Failures during the operating system boot are rare. The most common boot failure occurs because of changes to attached hard disks, especially during upgrade operations. Failures that occur after the OS is booted but before the Initialization stage are usually related to user customizations.

This section helps you to troubleshoot common network and console problems that you might encounter, or to provide information about boot failures to VMware support.

## Network Errors <a id="networkerrors"></a> ##

To aid with network errors, you can verify the following:

- Verify if the VM console of the deployed  appliance shows an IP address and if the address contains the expected value based on DHCP or provided static IP settings.
- Verify if you have a route to the deployed appliance's IP address:  

    `ping <vic_appliance_address>`
  -  If ping is successful, but SSH is not, check network firewall settings.
  -  If ping is not successful, check network settings and continue with troubleshooting [console errors](#consoleerrors). 

## Console Errors <a id="consoleerrors"></a> ##

To troubleshoot console errors, you should able to access the appliance using SSH and obtain debugging information.

Access the vSphere console for the appliance. Press `ALT + ->` to access the login prompt.

1. Log in as `root` user with the credentials that you provided in the OVA deployment customizations. If the deployment has failed to set your credentials, the default password is `VMw@re!23`.

2. Verify if any startup components failed to start by running the `systemctl list-units --state=failed` command.
   
    If there are any failed units, provide the output of the following commands to VMware Support:

  - `systemctl list-units --state=failed`  For each failed unit, run the command `journalctl -u <unit name>`.

   - `ip addr show`
   - `ip route show`

3. Verify if the IP address contains the expected value based on DHCP or provided static IP settings by running the `ip addr show` command.
4. Verify if the default route is valid by running the `ip route show` command. 
5. Verify if you can access the default gateway by pinging the default gateway.
	
	`ping <default gateway IP>`

	Obtain the default gateway IP from the `ip route show` command output.

  - If you cannot access the default gateway, check your network settings. Attach the appliance to a network that has a valid route between your client and the appliance.
  - If  you can access the default gateway, verify the routing configuration between the client that is unable to use SSH to access the appliance.
 
6.  If you are still unable to access the appliance, provide the output of the following commands to VMware Support:
   - `systemctl list-units --state=failed`  For each failed unit: `journalctl -u <unit name>`

   - `ip addr show`
   - `ip route show`

## Support Information ##

Provide the following information to VMware Support if you encounter problems during the boot stage:

- Specify if the deployment of the appliance is a new one or an upgrade. If it is an upgrade, specify the previous verision of the appliance.
- Specify if you made any changes to the disk configuration of the appliance and what those changes are.
- Verify if you see the page at `https://vic_appliance_address:9443`.
	- If you are not able to see the page, verify if you provided custom TLS certificates during deployment. 
	- If you are able to see the page, verify if the format of the certificate is correct. For more information, see [vSphere Integrated Containers Certificate Reference](vic_cert_reference.md).
	
        Run the `journalctl -u fileserver` and provide the output to VMware Support.
- Verify if you are able to use SSH to access the appliance. 
  - If you are not able to access the appliance, see [Network Errors](#networkerrors).
  - If you are able to access the appliance, obtain an appliance support bundle. For more information, see [Access and Configure Appliance Logs](appliance_logs.md).