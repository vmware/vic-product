#VCH Does Not Initialize Correctly#

A virtual container host (VCH) does not initialize correctly after editing in ESXi host client.

##Problem##

After you edit a VCH on the ESXi host client, it fails to initialize correctly. After you save and restart the endpointVM, the encryption key is lost and the endpointVM does not initialize correctly.

##Cause##

The `guestinfo.ovfEnv` key is used to store an encryption key for the vSphere credentials and server certificate private key. If you use an ESX host client to edit a running endpointVM, clicking on `Save` causes the `guestinfo.ovfEnv` key to convert to a volatile key, even if no changes were made to the VM config.

##Solution##

Do not use the ESXi host client to edit a running endpointVM directly. Instead, use the the vCenter client or power off the endpointVM before editing.