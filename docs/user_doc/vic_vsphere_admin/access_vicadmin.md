# VCH Administration Portal #

vSphere Integrated Containers Engine provides a Web-based administration portal for virtual container hosts (VCHs), called VCH Admin.

If you deployed the VCH with `--no-tls` or `--no-tlsverify`, you log in to VCH Admin by specifying the username and password of the ESXi host or vCenter Server on which you deployed the VCH. If you deployed the VCH with client and server authentication by using `--tls-cname` or by specifying a static IP address on the client network, you can use the generated `*.pfx` certificate to authenticate with the VCH Admin portal. For information about using the `*.pfx` certificate to log into VCH admin, see [Browser-Based Certificate Login](browser_login.md) and [Command Line Certificate Login](cmdline_login.md).

You access the VCH Admin portal in the following places:
 
  - In the HTML5 vSphere Client, go to **Home** > **vSphere Integrated Containers** > **vSphere Integrated Containers** > **Virtual Container Hosts**  and click the link to the VCH Admin portal.
  - In the HTML5 vSphere Client or Flex-based vSphere Web Client, got to **Hosts and Clusters**, select a VCH endpoint VM, and click the link to the VCH Admin portal in the **Summary** tab.
  - Copy the address of the VCH Admin portal from the output of `vic-machine create` or `vic-machine inspect`.

After you log in, the VCH Admin portal displays information about the VCH and the environment in which is running:

- Status information about the VCH, registry and Internet connections,  firewall configuration, and license. For information about these statuses and how to remedy error states, see the [VCH Status Reference](vicadmin_status_ref.md).
- The address of the Docker endpoint.
- The system time of the VCH. This is useful to know because clock skews between VCHs and client systems can cause TLS authentication to fail. For information about clock skews, see [Connections Fail with Certificate Errors when Using Full TLS Authentication with Trusted Certificates](ts_clock_skew.md). 
- The remaining capacity of the datastore that you designated as the image store. If the VCH is unable to connect to vSphere, the datastore information is not displayed.
- Live logs and log bundles for different aspects of the VCH. For information about the logs, see [Access vSphere Integrated Containers Engine Log Bundles](log_bundles.md).

If you see a certificate error when you attempt to log in to the VCH Administration Portal, see [Browser Rejects Certificates with `ERR_CERT_INVALID` Error](ts_cert_error.md).
