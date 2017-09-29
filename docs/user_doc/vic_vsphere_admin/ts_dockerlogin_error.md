# Logging in to vSphere Integrated Containers Registry from Docker Fails  #
 
When you run `docker login vic_registry_address` to log in to vSphere Integrated Containers Registry from the Docker client, you see a `401 Unauthorized` error.

## Problem ##

This error occurs even though you have correctly configured the Docker client with the registry certificate and you have successfully logged in to this registry instance before. 
 
## Cause ##

This issue can occur if the vSphere Integrated Containers appliance has experienced a hard reboot rather than a soft reboot of the guest OS.

## Solution ##

 In the vSphere Client, restart the vSphere Integrated Containers appliance by selecting **Power** > **Restart Guest OS**. 