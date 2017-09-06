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

    If the password you used during OVA deployment is rejected, set a different password. For example, it might be rejected because it is based on dictionary words. In this case, you can chose a different, throwaway password to get past this step.

4. When you are logged in, reboot the appliance.<pre>$ reboot now</pre> 


**Result** 

After the reboot, the password is set to the one that you specified during OVA deployment, even if you had to specify a different, throwaway password in order to log in. When the initial password that you specified during OVA deployment expires, the next time that you log in you must set a new password that complies with the strength check.