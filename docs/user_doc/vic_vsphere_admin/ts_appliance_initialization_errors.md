# Appliance Initialization Errors #
 
If you have reached the appliance initialization stage, it means that you can successfully view the appliance welcome page at `https://vic_appliance_address:9443`. The VIC appliance is ready to accept initialization information.

Failures during initialization are most often related to Platform Services Controller (PSC) authentication and networking. It is important to determine whether PSC registration completed successfully.

This section helps you to troubleshoot initialization problems that you might encounter or to provide information about initialization failures to VMware Support.

To aid in initialization errors, verify the following:

1.  Verify if you see can the page at `https://vic_appliance_address`:
 -  If you are able to see the page after providing the initialization information, verify if you can see the green success alert
	 - If yes, then the appliance has initialized.
	 - If you are able to see the page with a red error alert instead of a green success alert, note the error message.
     
			If the error message is `Failed to register with PSC. Please check the PSC settings provided and try again`, verify the PSC settings and use the `Re-initialize` button to try again.

			Check the clock skew between the appliance and the PSC that you have provided.

			Provide the error message to VMware Support and continue with the [SSH verification](#ssh-verification).
 
 - If you are not able to see the page, verify the following:
	 - Verify if the vSphere client can connect to the VIC appliance and is not blocked by network policy or architecture.
	 - If there are TLS handshake errors, check for clock skew between the client and VIC appliance and if you are using a browser that supports modern TLS ciphers

 -  If you are using vSphere Integrated Containers appliance version 1.4.0 or later, verify if you provided custom TLS certificates.
	 -  If you have provided custom TLS certificates, check whether the VM console displays the correct SHA1 fingerprint for the certificate. If you have provided the correct values, then continue with the [SSH verification](#ssh-verification).
	 If the VM Console does not display the correct fingerprint, then verify if you provided correct formatting and values for the fields in the customer certificates.Continue with the [SSH verification](#ssh-verification). 
	 -  If you have not provided custom TLS certificates, continue with [SSH verification](#ssh-verification).


2. Verify if you tried to initialize the vSphere Integrated Containers appliance by entering information in the welcome page?

 - If yes, verify if you can see the green success alert.
	 - If you can see the green success alert, continue with the [SSH verification](#ssh-verification).
	 - If you cannot see the message, then the initialization has not been completed. If repeated attempts do not display a green success alert, continue with [SSH verification](#ssh-verification).
  - If you have not entered information in the welcome page, enter the appropriate information when prompted. Make sure that the green success alert appears at the top of the vSphere Integrated Containers welcome page. 


3. If you tried to initialize the VIC appliance by using the initialization API, provide the following information to VMware Support:

  - The `curl` command that you ran.
  - The response that you received while executing the command.


4. <a id="ssh-verification"></a> Verify if you are able to use SSH to access the appliance.

  - If you are not able to access the appliance, see [Network Errors](ts_appliance_boot_errors.md#networkerrors).
  - If you are able to access the appliance, perform the following steps depending on the appliance version:
     - Version 1.3.1 or later: Obtain an appliance support bundle. For more information, see [Access and Configure Appliance Logs](appliance_logs.md).
     - Version previous to 1.3.0: Run the `journalctl -u fileserver` command and provide the entire output to VMware Support.
  - Run the `systemctl status fileserver` command. If this operation is running and you are not able to view the webserver in your browser, perform the following checks:
	  	- Check the network configuration between the VIC appliance and the client. Verify if the client or appliance using a 172.16.0.0/16 IP address. 
 	 	- Run the `journalctl -u fileserver` command. 
 	 	
			You should be able to see the webserver logs from your client's requests to the welcome page.

			If there are TLS handshake errors, check for clock skew between the client and appliance and verify that you are using a browser that supports modern TLS ciphers.


5. If you have PSC registration errors, see [Registration with Platform Service Controller Fails](ts_psc_registration_error.md)