# Add Hosts with No TLS Authentication to the Management Portal #

Connect hosts that do not require TLS authentication over HTTP with no credentials.


**Procedure**

1. In the management portal, navigate to **Infrastructure** > **Container Hosts** and click **+New**.
2. On the New Container Host page, configure the host settings.
	1. Enter name for the host.
	2. Select **VCH** as type.
	2. Enter the endpoint for the VCH as URL and click **Save**.

	For example, *http://*hostname*:2375*.

**Result**

The VCH appears on the Container Hosts page and can be managed.
