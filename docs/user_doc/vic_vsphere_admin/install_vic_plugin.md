# Manually Install the vSphere Client Plug-In #

vSphere Integrated Containers provides a plug-in for the HTML5 vSphere Client on vCenter Server 6.5 and 6.7. The HTML5 plug-in allows you to to deploy and interact with virtual container hosts (VCHs) directly in the vSphere Client.

vSphere Integrated Containers also provides a basic informational plug-in for the Flex-based vSphere Web Client on vCenter Server 6.0.  

For information about the Flex-based vSphere Web Client and the HTML5 vSphere Client, see [Introduction to the vSphere Client](https://pubs.vmware.com/vsphere-65/topic/com.vmware.wcsdk.pg.doc/GUID-3379D310-7802-4B62-8292-D11D928459FC.html) in the vSphere documentation.

**IMPORTANT**: If you installed a version of vSphere Integrated Containers that pre-dates 1.4.3, you must install the plug-in manually.  You can manually deploy the plug-in on a vCenter Server instance that runs on Windows, or on a vCenter Server Appliance.

* [Manually Install the vSphere Client Plug-In on vCenter Server for Windows](plugins_vc_windows.md)
* [Manually Install the vSphere Client Plug-In on a vCenter Server Appliance](plugins_vcsa.md)

If you installed vSphere Integrated Containers 1.4.3 or later, by default the plug-in is installed automatically with no user action required. If you deselected the option to install the plug-in when you deployed the vSphere Integrated Containers appliance, you can subsequently install the plug-in by reinitializing the appliance. For information, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md).

**IMPORTANT**: If you use vSphere 6.7 update 1 or later, you must use vSphere Integrated Containers 1.4.3 or later. Due to significant changes in the HTML5 vSphere Client in version 6.7 update 1, previous versions of the vSphere Integrated Containers plug-in for the vSphere Client might not work with that version. Only version 1.4.3 has been verified with vSphere 6.7 update 1.