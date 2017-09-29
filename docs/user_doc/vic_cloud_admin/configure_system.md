# Configure System Settings #

When you first log in to a new vSphere Integrated Containers instance, you can implement certificate verification for image replications, set the period of validity for login sessions, and schedule vulnerability scans.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.
7. Select **Administration** > **Configuration**, and optionally deselect the **Verify Remote Cert** checkbox to disable verification of replication endpoint certificates. 

    You must disable certificate verification if the remote registry uses a self-signed or an untrusted certificate. For example, disable certificate verification if the registry uses the default auto-generated certificates that vSphere Integrated Containers Registry created during the deployment of the vSphere Integrated Containers appliance.

8. Modify **Token Expiration (Minutes)** to optionally change the duration of login sessions from the default of 30 minutes.
9. Click **Download** to obtain the root certificate of the vSphere Integrated Containers Registry so that you can distribute it to interested parties.
	Developers need that certificate to pull an image from the Registry into their Docker client.

9. Under **Vulnerability Scanning**, optionally change the default settings for the scheduled daily vulnerability scanning at 3AM, and click **Save**.

**What to Do Next**

Add users to the system.
