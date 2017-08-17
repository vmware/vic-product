# Configure System Settings #

When you first log in to a new vSphere Integrated Containers instance, you can implement certificate verification for image replications and set the period of validity for login sessions.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.
7. Select **Administration** > **Configuration**, and optionally check the **CONFIG.VERIFY_REMOTE_CERT** checkbox to enable verification of replication endpoint certificates. 

    You must disable certificate verification if the remote registry uses a self-signed or an untrusted certificate. For example, disable certificate verification if the registry uses the default auto-generated certificates that vSphere Integrated Containers Registry created during the deployment of the vSphere Integrated Containers appliance.

8. Modify **CONFIG.TOKEN_EXPIRATION** to optionally change the duration of login sessions from the default of 30 minutes, and click **Save**.

**What to Do Next**

Add users to the system.