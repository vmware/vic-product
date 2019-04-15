# Custom Certificates are Not Copied During Upgrade

After upgrading the vSphere Integrated Containers appliance, the new version of the appliance does not use custom certificates that you used with the previous version.

## Problem ##

If you deployed a previous version of the vSphere Integrated Containers appliance with custom certificates, these certificates are not automatically copied to the new version of the appliance. 

## Cause ##

Previously, the documentation stated erroneously that the certificates are copied from the old appliance to the new. In fact, you must provide the same certificates when you deploy the new version of the appliance, otherwise self-signed certificates are generated. 

## Solution ##

Provide the custom certificate information in the OVA deployment wizard when you deploy the new version of the appliance. Use the same certificates as you used with the older version.

If you have already upgraded the appliance and you did not provide the custom certificate during deployment of the new version, you can reconfigure the new version of the appliance after deployment. For information about how to reconfigure the appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).