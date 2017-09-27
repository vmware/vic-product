# Reinitialize the vSphere Integrated Containers Appliance

After you power on the vSphere Integrated Containers appliance for the first time, you are prompted to enter the vCenter Server credentials and Platform Services Controller settings. This allows the OVA installer to perform two tasks to initialize the appliance:

- Tag the appliance VM for content trust
- Register the appliance with the Platform Services Controller

After initialization, the vSphere Integrated Containers Getting Started page should display a success message at the top of the page. In this case, no action is necessary.

The Getting Started Page includes a button labeled **Re-Initialize the  vSphere Integrated Containers Appliance**. 

**CAUTION**: Clicking the reinitialize button when the appliance is functioning correctly can result in data loss. You must only reinitialize the appliance in the following circumstances:

* The initialization of the appliance did not succeed and the Getting Started page includes a red error alert instead of a green success alert. For example, you see the error `Failed to locate VIC Appliance. Please check the vCenter Server provided and try again`.
* You need to register the appliance with a different Platform Services Controller. For more information, see [Register the vSphere Integrated Containers Appliance with a Different Platform Services Controller](register_different_psc.md).
* You need to re-tag the appliance for Docker content trust. For more information, see [Re-Tag the vSphere Integrated Containers Appliance](retag_appliance.md).
