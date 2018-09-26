# Registration with Platform Service Controller Fails #

When you deploy the vSphere Integrated Containers appliance and register it with the Platform Services Controller (PSC), the registration process fails. 

## Problem ##

The PSC registration causes errors during setup and the registration logs contain one of the following errors:

- `Exception in thread "main" com.vmware.admiral.auth.idm.psc.saml.sso.admin.SsoAdminClientException: Can not retrieve the SSO SSL certificate chain. Caused by: java.net.UnknownHostException: xyz`
- `Exception in thread "main" com.vmware.admiral.auth.idm.psc.saml.sso.admin.SsoAdminClientException: General SSO failure. Invalid host, port or tenant.`
- `Exception in thread "main" com.vmware.admiral.auth.idm.psc.saml.sso.admin.SsoAdminClientException: Provided credentials are not valid.`
- `Exception in thread "main" com.vmware.xenon.common.LocalizableValidationException: 'xyz' is required`

To access the PSC logs, log into the appliance VM and run the `journalctl -u fileserver` command.

## Cause ##

Some of the parameters provided during PSC registration might be wrong or missing.

## Solution ##

Perform the following steps to register the appliance with the PSC:

1. Verify that you have provided all required parameters and that they are correct.
2. Make sure that the registered PSC instance is accessible from the deployed OVA.
3. Try the registration process again.
4. After a successful registration, verify if the list of solution users for the PSC instance contains three new solution users similar to the following:
	
  - Solution User for `admiral`: `admiral-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

  - Solution User for `engine`: `engine-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

  - Solution User for `harbor`: `harbor-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

For an external PSC, you can see the users by logging into `https://psc_address/psc`.

**Note**: In case of multiple successful registrations, the solution users that are in use are the newest ones. You can remove the older ones from the PSC instance and from the folliowing configuration files of the three components:

- `admiral`: `/etc/vmware/psc/admiral/psc-config.properties`
- `engine`: `/etc/vmware/psc/engine/psc-config.properties`
- `harbor`: `/etc/vmware/psc/harbor/psc-config.properties`