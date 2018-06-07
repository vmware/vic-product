# Reinitialize the vSphere Integrated Containers Appliance

After you power on the vSphere Integrated Containers appliance for the first time, you are prompted to enter the vCenter Server credentials and Platform Services Controller settings. This allows the OVA installer to perform two tasks to initialize the appliance:

- Tag the appliance VM for content trust
- Register the appliance with the Platform Services Controller

After initialization, the vSphere Integrated Containers Getting Started page should display a success message at the top of the page. In this case, no action is necessary.

If you do not see the success message, the Getting Started Page includes a button labeled **Re-Initialize the  vSphere Integrated Containers Appliance**. 

**IMPORTANT**: Only reinitialize the appliance in the following circumstances:

* The initialization of the appliance did not succeed and the Getting Started page includes a red error alert instead of a green success alert. For example, you see the error `Failed to locate VIC Appliance. Please check the vCenter Server provided and try again`.
* You need to re-tag the appliance for Docker content trust. For more information, see [Re-Tag the vSphere Integrated Containers Appliance](retag_appliance.md).

**Procedure**:

1. In a browser, go to the vSphere Integrated Containers Getting Started page.

    You can specify the address in one of the following formats:

    - <i>vic_appliance_address</i>
    - http://<i>vic_appliance_address</i>
    - https://<i>vic_appliance_address</i>:9443

    The first two formats redirect automatically to https://<i>vic_appliance_address</i>:9443. If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, the redirect uses the port specified during deployment. If you specify HTTPS, you must include the port number in the address.
2. Click **Re-Initialize the  vSphere Integrated Containers Appliance**.
3. Enter the connection details for the vCenter Server instance on which you deployed the appliance.

     - The vCenter Server address and the Single Sign-on credentials for a vSphere administrator account.
     - If vCenter Server is managed by an external Platform Services Controller, enter the FQDN and administrator domain for the Platform Services Controller. If vCenter Server is managed by an embedded Platform Services Controller, leave the External PSC text boxes empty.
4. Click **Continue** to reinitialize the appliance.