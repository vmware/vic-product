# Access to Management Portal Fails # 

After successfully registering with the Platform Services Controller (PSC), access to the vSphere Integrated Containers Management Portal fails.

## Problem ##

The vSphere Integrated Containers Management Portal logs contain stack traces with any of the following errors:

- <pre>PscSettings : java.net.UnknownHostException: xyz 
 java.lang.IllegalArgumentException: PscSettings : xyz 
[redirectToSamlSso][Could not generate redirect URL: java.lang.IllegalStateException: SsoManager has not been initialized
    ...</pre>

- <pre>PscSettings : java.net.SocketTimeoutException: connect timed out
java.lang.IllegalArgumentException: PscSettings : connect timed out
[redirectToSamlSso][Could not generate redirect URL: java.lang.IllegalStateException: SsoManager has not been initialized
...</pre>

To access the logs for vSphere Integrated Containers Management Portal, navigate to `/storage/log/admiral/`.

## Causes ##

The errors could occur because of any of the following reasons:

- Some of the parameters provided while registering with the PSC might be wrong
- The parameters that were valid during the PSC registration process or from the appliance are no longer valid now.
- The parameters are not valid from any of the containers running within the appliance, for example, from the vSphere Integrated Containers Management Portal or the vSphere Integrated Containers Registry.

## Solution ##

1. Verify that the PSC registration was successful and that the logs do not have error messages. If the registration was not sucessful, try the process again. For more information see [Registration with Platform Service Controller Fails](ts_psc_registration_error.md).
2. Make sure that the registered PSC instance is accessible from the deployed appliance and from all the containers running within the appliance.
3. If the Management Portal was running during the PSC registration, restart the Management Portal and the vSphere Integrated Containers Registry after the registration process is complete. 

    For more information about restarting services, see [Restart the vSphere Integrated Containers Services](restart_services.md).
