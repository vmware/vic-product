# vSphere Integrated Containers Plug-Ins Not Deploying Correctly #

After you have installed the plug-ins for vSphere Integrated Containers, the HTML5 vSphere Client plug-in appears but is empty, or the plug-ins do not appear at all in one or both of the HTML5 vSphere Client or the Flex-based vSphere Web Client.

## Problem ##

The UI plug-in installer reported success, but you experience one of the following problems:

- The HTML5 plug-in appears in the vSphere Client, but the vSphere Integrated Containers Summary, Virtual Container Hosts, and Containers tabs are empty. 
- The plug-ins do not appear in the client at all.

Logging out of the client and logging back in again does not resolve the problem.

## Causes ##

If the vSphere Integrated Containers plug-in appears in the HTML5 client but the tabs are empty, you are not running the correct version of vCenter Server 6.5.0. The vSphere Integrated Containers HTML5 plug-in requires vCenter Server 6.5.0d or later. 

If the plug-ins do not appear at all: 

- A previous attempt at installing the vSphere Integrated Containers plug-ins failed, and the failed installation state was retained in the client cache.
- You installed a new version of the vSphere Integrated Containers plug-ins that has the same version number as the previous version, for example a hot patch.

## Solutions ##

If the vSphere Integrated Containers plug-in appears in the HTML5 client but the tabs are empty, upgrade vCenter Server to version 6.5.0d or later.

If the plug-ins do not appear at all, restart the vSphere Client services.

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
2. Use the `service-control` command-line utility to stop the vSphere Client service.<pre>service-control --stop vsphere-ui</pre>
3. Restart the vSphere Client service.<pre>service-control --start vsphere-ui</pre>

### Restart the Flex Client on a vCenter Server Appliance ###

1. Use SSH to log in to the vCenter Server Appliance as `root`.
2. Use the `service-control` command-line utility to stop the vSphere Web Client service.<pre>service-control --stop vsphere-client</pre>
3. Restart the vSphere Web Client service.<pre>service-control --start vsphere-client</pre>