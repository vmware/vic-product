# Add Virtual Container Hosts with Full TLS Authentication to the Management Portal #

If the vSphere administrator deployed a virtual container host (VCH)  that implements verification of both server and client certificates, you must provide the details of the client certificate when you add the VCH to a project in the management portal. Connections to the VCH use HTTPS.

**IMPORTANT**: If you have deployed multiple instances of the vSphere Integrated Containers appliance, you can only register a virtual container host (VCH) with one instance of the management portal at a time.

**Prerequisite**

Obtain the client private key, `key.pem`, and client public key, `cert.pem`, for the VCH from the vSphere administrator.

**Procedure**

2. In the management portal, navigate to **Administration** > **Identity Management** and click **Credentials** to configure the certificates to be used for authentication against the host.
	1. Click **+Credential** to add new entry.
	2. In the **New Credential** dialog box, enter name and click the **Certificate** radio button.
	3. In the **Public certificate** text box, enter the content of the `cert.pem` file.
	4. In the **Private certificate** text box, enter the content of the `key.pem` file.
	5. Click **Save**.
1. Go to the **Home** view, click the **Project**  drop-down menu, and select the project to which to add the VCH.
2. Navigate to **Infrastructure** > **Container Hosts** and click **+New**.
3. On the New Container Host page, configure the host settings.
	1. Enter name for the host.
	2. Select **VCH** as Host type.
	2. Enter the endpoint for the VCH as URL.

	    For example, *https://*hostname*:2376*.

    3. As Credentials, select the certificates that you configured for that host and click **Save**.

**Result**

The VCH appears on the Container Hosts page for the selected project. You can also see the VCHs that you added to a project by navigating to **Administration** > **Projects** > *project* > **Infrastructure**.