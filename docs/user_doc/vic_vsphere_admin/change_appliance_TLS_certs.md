# Change vSphere Integrated Containers Appliance TLS Certificates

If you do not provide TLS certificates during vSphere Integrated Containers appliance deployment, the OVA installer uses auto-generated certificates. You can reconfigure the appliance settings to change the TLS certificates after you have deployed it.

## Prerequisites

Log in to the vSphere Client:

- If you use vCenter Server 6.7 update 1 or later, you can use the HTML5 vSphere Client to reconfigure the appliance.
- If you use a version of vCenter Server that pre-dates 6.7 update 1, you must use the Flex-based vSphere Web Client. You cannot reconfigure the appliance in the HTML5 vSphere Client.

## Procedure

1. Shut down the vSphere Integrated Containers appliance by selecting **Shut Down Guest OS**.

	**IMPORTANT**: Do not select **Power Off**.

4. Modify the TLS certificates:

	  In the Flex-based vSphere Web Client, stay in the Edit Settings window and select **vApp Options**. 
	  
	  In the HTML5 vSphere Client (vCenter Server 6.7 update 1 and later), you access the **vApp Options** as follows:
	  
	1. Exit the **Edit Settings** window.
	1. Select the appliance VM and select the **Configure** tab.
	1. Select **vApp Options** and scroll to the Properties section.
	1. Click **Category** to sort the settings into the order in which they appear in the OVA installer.
	1. For each setting that you want to change, select the corresponding row and click **Set Value**.

	 You can modify the following settings in the **Appliance Configuration** section:
	- In the **Appliance TLS Certificate** text box, paste the contents of the server certificate PEM file.
	- In the **Appliance TLS Certificate Key** text box, paste the contents of  certificate key.
	- In the **Certificate Authority Certificate** text box, paste the contents of the Certificate Authority (CA) file. To use a certificate that uses a chain of intermediate CAs, paste the contents of a certificate chain PEM file. The PEM file must include a chain of the intermediate CAs all the way down to the root CA.

## Result

When you power the appliance back on, the TLS certificates are automatically applied.