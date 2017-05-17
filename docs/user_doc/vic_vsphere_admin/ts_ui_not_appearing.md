# vSphere Integrated Containers Plug-In Does Not Appear #

After you have installed either of the HTML5 or Flex-based plug-ins for vSphere Integrated Containers, the plug-ins do not appear in the HTML5 vSphere Client or the Flex-based vSphere Web Client.

## Problem ##

The UI plug-in installer reported success, but the plug-ins do not appear in the client. Logging out of the client and logging back in again does not resolve the issue.

## Cause ##

- If a previous attempt at installing the vSphere Integrated Containers plug-ins failed, the failed installation state is retained in the client cache.
- You installed a new version of the vSphere Integrated Containers plug-ins that has the same version number as the previous version, for example a hot patch.

## Solution ##

Restart the client service.

### Restart the HTML5 Client on vCenter Server on Windows ###

1. Log into the Windows system on which vCenter Server is running.
2. Open a command prompt as Administrator.
3. Use the `service-control` command-line utility to stop and then restart the vSphere Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vsphere-ui</pre><pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vsphere-ui</pre>

### Restart the Flex Client on vCenter Server on Windows ###

1. Log into the Windows system on which vCenter Server is running.
2. Open a command prompt as Administrator.
3. Use the `service-control` command-line utility to stop and then restart the vSphere Client service.<pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --stop vspherewebclientsvc</pre><pre>"C:\Program Files\VMware\vCenter Server\bin\service-control" --start vspherewebclientsvc</pre>

### Restart the HTML5 Client on a vCenter Server Appliance ###

1. Use SSH to log in to the vCenter Server Appliance as `root`.
2. Use the `service-control` command-line utility to stop the vSphere Client service.<pre>service-control --stop vsphere-ui</pre>
3. Restart the vSphere Client service.<pre>service-control --start vsphere-ui</pre>

### Restart the Flex Client on a vCenter Server Appliance ###

1. Use SSH to log in to the vCenter Server Appliance as `root`.
2. Use the `service-control` command-line utility to stop the vSphere Web Client service.<pre>service vsphere-client stop</pre>
3. Restart the vSphere Web Client service.<pre>service-control --start vsphere-client</pre>