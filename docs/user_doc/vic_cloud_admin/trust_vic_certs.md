# Verify and Trust vSphere Integrated Containers Appliance Certificates 

You can verify the self-signed certificates and trust the certificate authority (CA) for the vSphere Integrated Containers Getting Started page and the vSphere Integrated Containers Management Portal. Trusting the CA  prevents browsers from giving security warnings and potentially locking you out of vSphere Integrated Containers for security reasons.

**Prerequisites**

To verify and trust the vSphere Integrated Containers appliance certificates, you must obtain the thumbprints and CA files either directly from the appliance, or from the vSphere administrator. For information about how to obtain certificate information, see [Obtain the Thumbprints and CA Files of the vSphere Integrated Containers Appliance Certificates](../vic_vsphere_admin/obtain_appliance_certs.md).

**Procedure**

1. In a browser, go to the Getting Started Page at http://<i>vic_appliance_address</i>.
2. View the certificate details in the browser and locate the SHA-1 thumbprint.

    How you view the certificate details depends on the type of browser that you use.

5.  Compare the SHA-1 thumbprint in the browser to the thumbprint that you or the vSphere administrator obtained from the appliance.

    The thumbprints should be the same.
6.  Click the link to the vSphere Integrated Containers Management Portal in the Getting Started page, log in, and repeat the procedure to verify the certificate thumbprint for the management portal.
7.  When you have verified both of the thumbprints, import the `ca.crt` files into the root certificate store on your local machine.

    How you import a CA file into the root certificate store depends on the operating system of your local machine. 

**Result**

When you access the Getting Started page and vSphere Integrated Containers Management Portal, your browser shows that the connection is secure.