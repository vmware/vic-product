# Add Hosts with Server-Side TLS Authentication to the Management Portal #

Connect hosts that require server-side TLS authentication only over HTTP with no credentials.


**Procedure**

1. In the management portal, navigate to **Resources** > **Hosts** and click **Add a host**.
2. On the Add Host page, configure the host settings.
	1. Enter the endpoint for the VCH as Address.

	For example, *https://*hostname*:2376*.
	2. Select **VCH** as Host type.
	3. Do not enter credentials and click **Verify**.
3.	After successful verification, click **Add**.

**Result**

The VCH appears on the Hosts page and can be managed.