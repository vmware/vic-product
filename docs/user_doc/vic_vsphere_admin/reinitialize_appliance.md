# Reinitialize the vSphere Integrated Containers Appliance

After you power on the vSphere Integrated Containers appliance for the first time, you are prompted to enter the vCenter Server credentials and Platform Services Controller settings. This allows the OVA installer to perform the tasks that initialize the appliance:

- Tag the appliance VM for Docker content trust
- Register the appliance with the Platform Services Controller
- In 1.4.3 and later, automatically install or upgrade the vSphere Integrated Containers plug-in for the vSphere Client.

After initialization, the vSphere Integrated Containers appliance welcome page should display a success message at the top of the page. In this case, no action is necessary.

If you do not see the success message, you can reinitialize the appliance. The appliance welcome page includes a button labeled **Re-Initialize the vSphere Integrated Containers Appliance**. 

You should reinitialize the appliance in the following circumstances:

* The initialization of the appliance did not succeed and the appliance welcome page includes a red error alert instead of a green success alert. For example, you see the error `Failed to locate VIC Appliance. Please check the vCenter Server provided and try again`.
* You need to re-tag the appliance for Docker content trust. For more information, see [Re-Tag the vSphere Integrated Containers Appliance](retag_appliance.md).
* You need to update the details for the Platform Services Controller.
* You chose not to install or upgrade the vSphere Client plug-in when you installed or upgraded the appliance, and you now wish to do so. The automatic installation or upgrade of the plug-in is available in vSphere Integrated Containers 1.4.3 and later.

**Procedure**:

1. In a browser, go to the vSphere Integrated Containers appliance welcome page.

    You can specify the address in one of the following formats:

    - <i>vic_appliance_address</i>
    - http://<i>vic_appliance_address</i>
    - https://<i>vic_appliance_address</i>:9443

    The first two formats redirect automatically to https://<i>vic_appliance_address</i>:9443. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, the redirect uses the port specified during deployment. If you specify HTTPS, you must include the port number in the address.
2. Scroll to the bottom of the page and click **Re-Initialize the  vSphere Integrated Containers Appliance**.
3. Enter the vCenter Server address and the Single Sign-on credentials of a vSphere administrator account for the vCenter Server instance on which you deployed the appliance.
4. If vCenter Server is managed by an external Platform Services Controller, enter the FQDN and administrator domain for the Platform Services Controller. 

    - If vCenter Server is managed by an embedded Platform Services Controller, leave the External PSC text boxes empty.
    - If the Platform Services Controller has changed since deployment, provide the new FQDN and administrator domain.
4. To install or upgrade the vSphere Client plug-in, leave the **Install UI Plugun** checkbox selected, and click **Continue**.

    The option to automatically install the  plug-in for the vSphere Client is available in vSphere Integrated Containers 1.4.3 and later.
6. Verify that the certificate thumbprint for vCenter Server is valid, and click **Continue** to initialize the appliance.

    Thumbprint verification occurs in vSphere Integrated Containers 1.4.3 and later.

**Result**

You see a green success message on the vSphere Integrated Containers appliance welcome page. The reinitialization has performed some or all of the following tasks:

- Retagged the appliance VM for Docker content trust
- Updated the Platform Services Controller registration
- In 1.4.3 and later, automatically installed or upgraded the plug-in 