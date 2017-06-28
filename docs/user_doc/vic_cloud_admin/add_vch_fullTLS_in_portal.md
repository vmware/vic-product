# Add Hosts with Full TLS Authentication to the Management Portal #

Connect hosts that require full TLS authentication over HTTPS by using certificate to authenticate against the host.

**Prerequisite**

Obtain the client private key (*key.pem*) and client public key (*cert.pem*) for authentication against the VCH.

**Procedure**

1. In the management portal, navigate to **Resources** > **Hosts** and click **Add a host**.
2. On the Add Host page, configure the certificates to be used for authentication against the host.
	1. On the right, click **Credentials** and click **Add**.
	2. In the **New Credential** dialog box, enter name and click the **Certificate** radio button.
	3. In the **Public certificate** text box, enter the content of the *cert.pem* file.
	4. In the **Private certificate** text box, enter the content of the *key.pem* file.
3. On the Add Host page, configure the host settings.
	1. Enter the endpoint for the VCH as Address.

	For example, *https://*hostname*:2376*.
	2. Select **VCH** as Host type.
	3. As Login credential, select the certificates that you configured for that host and click **Verify**.
3.	After successful verification, click **Add**.

**Result**

The VCH appears on the Hosts page and can be managed.