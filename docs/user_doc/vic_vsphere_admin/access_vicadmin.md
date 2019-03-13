# Access the VCH Administration Portal #

Each virtual container host (VCH) has a Web-based administration portal, called VCH Administration portal. The VCH Administration portal provides status information about the VCH and access to the VCH logs.

The vSphere Integrated Containers plug-in for the vSphere Client provides the link to the VCH Administration portal for each VCH instance. You can also see the URL for the VCH Administration portal in the output of the `vic-machine create` or `vic-machine inspect` commands.

## Prerequisites

- You deployed a VCH and at least one container VM.
- The vSphere Integrated Containers plug-in for the HTML5 vSphere Client plug-in is available for vSphere 6.5 and 6.7.
- The vSphere Integrated Containers plug-in for the Flex-based vSphere Web Client is available for vSphere 6.0.

## Procedure

1. Log in to the vSphere Client.
2. Navigate to your VCHs. 

    - In the HTML5 vSphere Client for vSphere 6.5 and 6.7, you can access the VCH Administration portal links in two ways:
     - Go to **Home** > **vSphere Integrated Containers** > **vSphere Integrated Containers** > **Virtual Container Hosts** and click the link to the VCH Admin portal. 
     - Go to **Hosts and Clusters**, select a VCH endpoint VM, and click the link to the VCH Admin portal in the **Summary** tab.
  
    - In the Flex-based vSphere Web Client for vSphere 6.0, go to **Hosts and Clusters**, select a VCH endpoint VM, and click the link to the VCH Admin portal in the **Summary** tab. 
  
3. Use vSphere administrator credentials to log in to the VCH Admin portal.

**NOTE**: If you used `vic-machine` to deploy the VCH and you enabled verification of client certificates, or if you specifyied a static IP address on the client network, you can use the generated `*.pfx` certificate to authenticate with the VCH Admin portal. For information about using the `*.pfx` certificate to log into VCH admin, see [Browser-Based Certificate Login](browser_login.md) and [Command Line Certificate Login](cmdline_login.md).

## Result

After you log in, the VCH Admin portal displays information about the VCH and the environment in which is running:

- Status information about the VCH, registry and Internet connections,  firewall configuration, and license. For information about these statuses and how to remedy error states, see the [VCH Status Reference](vicadmin_status_ref.md).
- The address of the Docker endpoint.
- The system time of the VCH. This is useful to know because clock skews between VCHs and client systems can cause TLS authentication to fail. For information about clock skews, see [Connections Fail with Certificate or Platform Services Controller Token Errors](ts_clock_skew.md). 
- The remaining capacity of the datastore that you designated as the image store. If the VCH is unable to connect to vSphere, the datastore information is not displayed.
- Live logs and log bundles for different aspects of the VCH. For information about the logs, see [Access vSphere Integrated Containers Engine Log Bundles](log_bundles.md).

## Troubleshooting

If you see a certificate error when you attempt to log in to the VCH Administration Portal, see [Browser Rejects Certificates with `ERR_CERT_INVALID` Error](ts_cert_error.md).
