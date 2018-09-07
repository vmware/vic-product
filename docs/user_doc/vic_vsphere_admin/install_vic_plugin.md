# Manually Install the vSphere Client Plug-Ins #

vSphere Integrated Containers provides a basic plug-in for the Flex-based vSphere Web Client on vCenter Server 6.0, 6.5, and 6.7. vSphere Integrated Containers provides a plug-in with more complete functionality for the HTML5 vSphere Client. The HTML5 vSphere Client is available with vSphere 6.5 and 6.7. 

If you installed a version of vSphere Integrated Containers that pre-dates 1.4.3, you must install the plug-ins manually. 

**IMPORTANT**: If you installed vSphere Integrated Containers 1.4.3 or later, by default the plug-ins are installed automatically with no user action required. If you deselected the option to install the plug-ins when you deployed the vSphere Integrated Containers appliance, you can subsequently install the plug-ins by reinitializing the appliance. For information, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md).

For information about the Flex-based vSphere Web Client and the HTML5 vSphere Client for vSphere 6.5 and 6.7, see [Introduction to the vSphere Client](https://pubs.vmware.com/vsphere-65/topic/com.vmware.wcsdk.pg.doc/GUID-3379D310-7802-4B62-8292-D11D928459FC.html) in the vSphere documentation.

You can deploy the plug-ins on a vCenter Server instance that runs on Windows, or on a vCenter Server Appliance.

* [Manually Install the vSphere Client Plug-Ins on vCenter Server for Windows](plugins_vc_windows.md)
* [Manually Install the vSphere Client Plug-Ins on a vCenter Server Appliance](plugins_vcsa.md)