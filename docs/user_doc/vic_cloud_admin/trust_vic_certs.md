# Verify and Trust vSphere Integrated Containers Appliance Certificate 

You can verify the self-signed certificate and trust the certificate authority (CA) for the vSphere Integrated Containers appliance welcome page and the vSphere Integrated Containers Management Portal. Trusting the CA prevents browsers from giving security warnings and potentially locking you out of vSphere Integrated Containers for security reasons.

## Prerequisites

To verify and trust the vSphere Integrated Containers appliance certificate, you must obtain the thumbprint and CA file either directly from the appliance, or from the vSphere administrator. For information about how to obtain certificate information, see [Obtain the Thumbprint and CA File of the vSphere Integrated Containers Appliance Certificate](../vic_vsphere_admin/obtain_appliance_certs.md).

## Procedure

1. In a browser, go to the appliance welcome page at https://<i>vic_appliance_address</i>:9443.

    If the vSphere Integrated Containers appliance was configured to expose the file server on a different port, replace 9443 with the appropriate port.
2. View the certificate details in the browser and locate the SHA-1 thumbprint.

    How you view the certificate details depends on the type of browser that you use.

5.  Compare the SHA-1 thumbprint in the browser to the thumbprint that you or the vSphere administrator obtained from the appliance.

    The thumbprints should be the same.
6.  Click the link to the vSphere Integrated Containers Management Portal in the appliance welcome page, log in, and repeat the procedure to verify the certificate thumbprint for the management portal.
7.  When you have verified both of the thumbprints, import the `ca.crt` files into the root certificate store on your local machine.

    How you import a CA file into the root certificate store depends on the operating system of your local machine. 

## Result

When you access the appliance welcome page and vSphere Integrated Containers Management Portal, your browser shows that the connection is secure.