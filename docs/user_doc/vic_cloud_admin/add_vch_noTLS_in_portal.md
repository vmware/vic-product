# Add Container Hosts with No TLS Authentication #

If a Docker host or a vSphere Integrated Containers virtual container host (VCH) does not implement any level of TLS authentication, you do not provide a certificate when you add the host to a project in the management portal. Connections to the host use HTTP.

**IMPORTANT**: You can only register a VCH with one project at a time. Similarly, you cannot add the same VCH to projects in multiple instances of vSphere Integrated Containers.

**Prerequisite**

Log in to vSphere Integrated Containers Management Portal with a vSphere administrator or Management Portal administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).

**Procedure**

1. In the **Home** view, click the **Project**  drop-down menu and select the project to which to add the host.
2. Navigate to **Infrastructure** > **Container Hosts** and click **+Host**.
2. On the New Container Host page, configure the host settings.
	1. Enter name for the host.
	2. Select **VCH** or **Docker** as type.
	2. Enter the endpoint for the VCH as URL and click **Save**.

	    For example, *http://*hostname*:2375*.

**Result**

The host appears on the Container Hosts page for the selected project. You can also see the hosts that you added to a project by navigating to **Administration** > **Projects** > *project* > **Infrastructure**.

**What to Do Next**

[Configure Project Settings](manage_projects.md)
