# Browser Rejects Certificates with `ERR_CERT_INVALID` Error #

Attempts to connect to vSphere Integrated Containers web interfaces fail with certificate errors in Google Chrome browsers.

## Problem ##

When you attempt to access the vSphere Integrated Containers Getting Started page, vSphere Integrated Containers Management Portal, or the administration portal for a virtual container host (VCH), Google Chrome rejects the connection with an `ERR_CERT_INVALID` error and a warning similar to the following:

<pre><i>Web_address</i> normally uses encryption to protect your information. When Google Chrome tried to connect to <i>web_address</i> this time, the website sent back unusual and incorrect credentials...

You cannot visit <i>web_address</i> right now because the website sent scrambled credentials that Google Chrome cannot process...</pre>

This issue only affects Google Chrome. Other browsers do not report certificate errors.

## Cause ##

You have already accepted a client certificate or a generated Certificate Authority (CA) for a previous instance of the vSphere Integrated Containers appliance or for a VCH that had the same FQDN or IP address as the new instance.

## Solution ##

1. Search the keychain on the system where the browser is running for client certificates or CAs that are issued to the FQDN or IP address of the vSphere Integrated Containers appliance or VCH. 

    Auto-generated vSphere Integrated Containers appliance and VCH certificates are issued by **Self-signed by VMware, Inc**.

2. Delete any client certificates or CAs for older instances of vSphere Integrated Containers appliances or VCHs.
3. Clear the browser history, close, and restart Chrome.
4. Connect to the vSphere Integrated Containers Getting Started page, vSphere Integrated Containers Management Portal, or VCH Administration portal again, verify the certificate, and trust it if it is valid.

For information about how to verify certificates for the vSphere Integrated Containers appliance, see [Verify and Trust vSphere Integrated Containers Appliance Certificates](../vic_cloud_admin/trust_vic_certs.md).