# vSphere Integrated Containers Plug-In Not Deploying Correctly #

After you have installed the plug-in for vSphere Integrated Containers, the HTML5 vSphere Client plug-in appears but is empty, or the plug-in does not appear at all in one or both of the HTML5 vSphere Client or the Flex-based vSphere Web Client.

**IMPORTANT**: If you use vSphere 6.7 update 1 or later, you must use vSphere Integrated Containers 1.4.3 or later. Due to significant changes in the HTML5 vSphere Client in version 6.7 update 1, previous versions of the vSphere Integrated Containers plug-in for the vSphere Client do not work with that version.

## Problem ##

The UI plug-in installer reported success, but you experience one of the following problems:

- The HTML5 plug-in appears in the vSphere Client, but the vSphere Integrated Containers Summary, Virtual Container Hosts, and Containers tabs are empty. 
- The plug-in does not appear in the client at all.

Logging out of the client and logging back in again does not resolve the problem.

## Causes ##

If the vSphere Integrated Containers plug-in appears in the HTML5 client but the tabs are empty, you are not running the correct version of vCenter Server 6.5.0. The vSphere Integrated Containers HTML5 plug-in requires vCenter Server 6.5.0d or later. 

If the plug-in does not appear at all: 

- A previous attempt at installing the vSphere Integrated Containers plug-in failed, and the failed installation state was retained in the client cache.
- You installed a new version of the vSphere Integrated Containers plug-in that has the same version number as the previous version, for example a hot patch.
- You might be encountering an SSL certificate mismatch issue. This can occur if the root CA on the vCenter Server Virtual Appliance is updated, either by upgrading to a newer build of vSphere or by running the VMCA Certificate Manager.

## Solutions ##

- If the vSphere Integrated Containers plug-in appears in the HTML5 client but the tabs are empty, upgrade vCenter Server to version 6.5.0d or later.
- If the plug-in does not appear at all, see the section below to restart the vSphere Client services.
- If the plug-in still does not appear after restarting the vSphere Client services, see https://kb.vmware.com/kb/52540. 

## Restart the vSphere Client Services <a id="restart-client"></a>

You restart the Flex-based vSphere Web Client or the HTML5 vSphere Client in different ways.

### Restart the HTML5 Client from the Flex-based vSphere Web Client 

1. Log into the Flex-based vSphere Web Client.
2. Go to **Administration** > **System Configuration** > **Services**. 
3. Right-click **VMware vSphere Client** and select **Restart**.

You cannot restart the Flex-based vSphere Web Client from the Flex-based client or from the HTML5 vSphere Client.


### Restart the HTML5 Client on vCenter Server on Windows ###

1. Log into the Windows system on which vCenter Server is running.
2. Open a command prompt as Administrator.
3. Use the `service-control` command-line utility to stop and then restart the vSphere Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vsphere-ui</pre><pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vsphere-ui</pre>

### Restart the Flex Client on vCenter Server on Windows ###

1. Log into the Windows system on which vCenter Server is running.
2. Open a command prompt as Administrator.
3. Use the `service-control` command-line utility to stop and then restart the vSphere Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vsphere-client</pre><pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vsphere-client</pre>

### Restart the HTML5 Client on a vCenter Server Appliance ###

1. Use SSH to log in to the vCenter Server Appliance as `root`.
2. Use the `service-control` command-line utility to restart the vSphere Client service.<pre>service-control --stop vsphere-ui && service-control --start vsphere-ui</pre>

### Restart the Flex Client on a vCenter Server Appliance ###

1. Use SSH to log in to the vCenter Server Appliance as `root`.
2. Use the `service-control` command-line utility to stop the vSphere Web Client service.<pre>service-control --stop vsphere-client && service-control --start vsphere-client</pre>