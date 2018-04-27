# Configure System Settings #

When you first log in to a new vSphere Integrated Containers instance, you can set the period of validity for login sessions and schedule vulnerability scans.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.
2. Select **Administration** > **Configuration**.
3. Under System Settings, modify **Token Expiration (Minutes)** to optionally change the duration of login sessions from the default of 30 minutes.
4. Click **Download** to obtain the root certificate of the vSphere Integrated Containers Registry. 
	
    You must distribute the certificate to the interested parties:

    - vSphere administrators need the certificate so that they can deploy VCHs that connect to the Registry.
    - Developers need the certificate so that they can pull images from the Registry into their Docker client.

5. Under **Vulnerability Scanning**, optionally change the default settings for the scheduled daily vulnerability scanning at 3AM, and click **Save**.

**What to Do Next**

Add users to the system.
