# Add Global Registries #

You can add multiple global registries that are available to all users of the management portal. Global registries that are allowed by the cloud admin cannot be disabled or removed by other users. 


**Procedure**

1. In the management portal, navigate to **Administration** > **Global Registries** > **Source Registries** and click **+Registry**.

2. In the dialog box that opens, configure the registry settings.
	1. As address, enter the IP or hostname of the registry, the port, and optionally a namespace.

	For example: `https://registry.hub.docker.com:443/vmware`

	2. Enter a name for the registry.
	3. Optionally, select the login credentials to access the registry.
	4. Click **Verify** and if prompted to trust the registry certificate, click **OK**.
	5. After successful verification, click **Save**.


**Result**

The registry appears on the Global Registries page and all users can access the images stored in that registry.
