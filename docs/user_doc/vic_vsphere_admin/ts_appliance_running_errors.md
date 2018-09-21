# Appliance Running Errors #

If you have reached the appliance running stage, it means that you have successfully initialized the appliance and can see the green success alert on the appliance welcome page. After the vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry start, you can access the vSphere Integrated Containers Management Portal.

This section helps you to troubleshoot appliance running problems that you might encounter or to provide information about running failures to VMware support. 

For running failures that are related to vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry functionality, see [Troubleshoot Post-Deployment Operation](ts_post_deployment_op.md).

To aid in initialization errors, provide the following information to VMware Support:

1. If you are using appliance version 1.3.1 or later and are able to connect to the appliance using SSH, obtain an appliance support bundle. 

	For more information, see [Access and Configure Appliance Logs](appliance_logs.md)

2. Run the following commands to verify if the vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry are running and provide the output to VMware Support:

	- `systemctl status admiral`
	- `journalctl -u admiral`
	- `systemctl status harbor`
	- `journalctl -u harbor`
	- If the version is 1.3.1 or a previous version, run the `journalctl -u admiral_startup` and `journalctl -u harbor_startup` commands.


3. If vSphere Integrated Containers Management Portall is not running and `systemctl status get_token` shows that the service failed, run the `journalctl -u get_token` command to see the error logs. 

	If the logs show errors related to Platform Services Controller (PSC) token Errors clock skew, there might be clock skew between the appliance and the PSC. 

	For more information see [Connections Fail with Certificate or Platform Services Controller Token Errors](ts_clock_skew.md)
	
	The appliance recieves NTP configuration from DHCP by default. If DHCP is not used, set time synchronization by one of following methods:

	- Synchronize time in guests deployed from OVF templates. To synchronize time, perform the following steps: 
	
		1. Open the vSphere Client and connect to vCenter Server.
		
		2. Right-click the virtual machine you deployed from OVF and click **Edit Settings** > **Options** > **VMware Tools**.
		
		3. Under Advanced, select **Synchronize guest time with host** and click **OK**.
		
		4. Right-click the appliance VM and select **Power** > **Shut Down Guest OS**.
		
		5. Power on the appliance. 
		
		**Note**: Do not reboot the appliance.
	
	- Configure NTP directly in the appliance VM.

		1. Use SSH to connect to the vSphere Integrated Containers appliance as root user.
			
			`ssh root@vic_appliance_address`
		
		2. Enable NTP in the appliance. 
		
			`timedatectl set-ntp true`

		3.  Optionally, customize the NTP servers by editing the `/etc/systemd/timesyncd.conf` file.

4. If the vSphere Integrated Containers Management Portal interface displays the `SsoManager has not been initialized at runtime`, see [Access to Management Portal Fails](ts_admiral_access_error.md)
5.  If the vSphere Integrated Containers Management Portal is not running, verify if you provided custom TLS certificates during deployment. 
	- If you have provided custom TLS certificates, verify if the format of the certificate is correct. For more information, see [vSphere Integrated Containers Certificate Reference](vic_cert_reference.md).
	- Run the `journalctl -u admiraland` command and provide the output to VMware Support.
	- If the version is 1.3.1 or a previous version, run the `journalctl -u admiral_startup` command and provide output to VMware Support.