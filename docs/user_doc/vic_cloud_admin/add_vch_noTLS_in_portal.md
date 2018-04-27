# Add Virtual Container Hosts with No TLS Authentication to the Management Portal #


If the vSphere administrator deployed a virtual container host (VCH)  without implementing any TLS authentication, you do not provide a certificate when you add the VCH to a project in the management portal. Connections to the VCH use HTTP.

**IMPORTANT**: If you have deployed multiple instances of the vSphere Integrated Containers appliance, you can only register a virtual container host (VCH) with one instance of the management portal at a time.

**Procedure**

1. In the **Home** view of the management portal, click the **Project**  drop-down menu and select the project to which to add the VCH.
2. Navigate to **Infrastructure** > **Container Hosts** and click **+Host**.
2. On the New Container Host page, configure the host settings.
	1. Enter name for the host.
	2. Select **VCH** as type.
	2. Enter the endpoint for the VCH as URL and click **Save**.

	    For example, *http://*hostname*:2375*.

**Result**

The VCH appears on the Container Hosts page for the selected project. You can also see the VCHs that you added to a project by navigating to **Administration** > **Projects** > *project* > **Infrastructure**.
