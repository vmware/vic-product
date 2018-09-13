# vSphere Client Plug-In Scripts Fail with No Error Message #

When you run the scripts to install or upgrade the vSphere Integrated Containers plug-in for the vSphere Client, the operation fails immediately.

## Problem ##

Running the `install`, `uninstall`, or `upgrade` scripts fails immediately after you enter the password for vCenter Server. The output of the script is `Error! Could not register plugin with vCenter Server. Please see the message above`. However, there is no error message above.

## Cause ##

You have set the `VIC_MACHINE_THUMBPRINT` environment variable on the system on which you are running the script. The presence of the `VIC_MACHINE_THUMBPRINT` environment variable causes the script to skip the verification of the vCenter Server certificate thumbprint. This causes the script to fail.

## Solution ##

Delete the `VIC_MACHINE_THUMBPRINT` environment variable, or run the script on a different system.
