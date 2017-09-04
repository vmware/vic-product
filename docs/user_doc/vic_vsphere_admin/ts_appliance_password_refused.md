# vSphere Integrated Containers Appliance VM Password Refused

After successfully deploying the vSphere Integrated Containers appliance OVA, you cannot use SSH to log in to the vSphere Integrated Containers appliance VM.

## Problem

The root password that you specified during the OVA deployment is refused when you attempt to log in to the appliance by using SSH or the virtual machine console. 

## Cause

A startup process failed on the first boot of the appliance. This caused the appliance password that you specified during deployment of the OVA not to be set.

## Solution

1. Use SSH or the VM console to log in to the appliance VM as `root`. <pre>$ ssh root@<i>vic_appliance_address</i></pre>
2. When prompted, enter the default password.<pre>2RQrZ83i79N6szpvZNX6</pre>
3. When prompted to change the root password, set it to the same password that you set during the OVA deployment. 

    If the password you used during OVA deployment is not accepted, set a different password. 

4. When you are logged, reboot the appliance.<pre>$ reboot now</pre> 

After reboot, you can use this password to log in to the appliance VM.  By default, the password expires after 90 days.