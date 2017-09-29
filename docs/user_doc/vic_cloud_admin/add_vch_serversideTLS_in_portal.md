# Add Hosts with Server-Side TLS Authentication to the Management Portal #

Connect hosts that require server-side TLS authentication only over HTTP with no credentials.

**IMPORTANT**: If you have deployed multiple instances of the vSphere Integrated Containers appliance, you can only register a virtual container host (VCH) with one instance of the management portal at a time. 

**Procedure**

1. In the management portal, navigate to **Infrastructure** > **Container Hosts** and click **+New**.
2. On the New Container Host page, configure the host settings.
	1. Enter name for the host.
	2. Select **VCH** as type.
	2. Enter the endpoint for the VCH as URL.

	    For example, *https://*hostname*:2376*.
	
	3. Do not enter credentials and click **Save**. 
	4. If you are prompted to trust the  certificate, click **OK**.

**Result**

The VCH appears on the Container Hosts page and can be managed.