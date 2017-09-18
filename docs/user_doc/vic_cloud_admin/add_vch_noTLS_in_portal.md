# Add Hosts with No TLS Authentication to the Management Portal #

Connect hosts that do not require TLS authentication over HTTP with no credentials.

**IMPORTANT**: If you have deployed multiple instances of the vSphere Integrated Containers appliance, you can only register a virtual container host (VCH) with one instance of the management portal at a time.

**Procedure**

1. In the management portal, navigate to **Infrastructure** > **Container Hosts** and click **+New**.
2. On the New Container Host page, configure the host settings.
	1. Enter name for the host.
	2. Select **VCH** as type.
	2. Enter the endpoint for the VCH as URL and click **Save**.

	For example, *http://*hostname*:2375*.

**Result**

The VCH appears on the Container Hosts page and can be managed.
