# Configure a Registry #

When you first log in to a new vSphere Integrated Containers Registry instance, you can optionally configure the registry to implement authentication of users by using an LDAP or Active Directory service. You can define who can create projects or register as users, implement certificate verification for image replications, set up a mail server, and set the period of validity for login sessions.

**IMPORTANT**: The option to switch from local user management that uses a database to LDAP authentication is only available while the local database is empty. If you start to populate the database with users and projects, the option to switch to LDAP authentication is disabled. If you want to implement LDAP authentication, you must enable this option when you first log in to a new registry instance, before you create any projects or users. 

With the exception of setting up LDAP authentication after you have already created projects or users, you can change any of the other settings at any time after the initial configuration. This includes changing from LDAP authentication back to local user management that uses a database. 
	
**Prerequisites**

The vSphere administrator enabled vSphere Integrated Containers Registry when they deployed the vSphere Integrated Containers appliance.

**Procedure**

1. Log in as `admin` user to the vSphere Integrated Containers Registry interface at https://<i>vic_appliance_address</i>:443.

   If you configured the vSphere Integrated Containers appliance to use a different port for vSphere Integrated Containers Registry, replace 443 with the appropriate port.
2. Expand **Administration** on the left, select **Configuration** > **Authentication**, and set the **Auth Mode**.

    - To use local user management, leave **Auth Mode** set to **Database**.
    - To implement LDAP or Active Directory authentication, select **LDAP**.
    
3. If you selected LDAP authentication, fill in the details of your LDAP or Active Directory service, click **Test LDAP Server**, and click **Save** if the test is successful. 
4. Use the **Project Creation** drop-down menu to set which users can create projects.

   - Select **Everyone** to allow all users to create projects
   - Select **Admin Only** to allow only users with the Administrator role to create projects

5. If you selected **Database** authentication, optionally uncheck the **Allow Self-Registration** checkbox.

   This option is not available if you use LDAP authentication. If you leave this option enabled, a link that allows unregistered users to sign up for an account appears on the vSphere Integrated Containers Registry login page. When self-registration is disabled, the link does not appear on the login page, and only users with the Administrator role can register new users.  

6. Click **Save** to save the authentication settings.
7. Click **Replication**, and optionally uncheck the **Verify Remote Cert** checkbox to disable verification of replication endpoint certificates. 

    You must disable certificate verification if the remote registry uses a self-signed or an untrusted certificate. For example, disable certificate verification if the registry uses the default auto-generated certificates that vSphere Integrated Containers Registry created during the deployment of the vSphere Integrated Containers appliance.
7. Click **Email** to set up a mail server, test the settings, and click **Save**.

   The mail server is used to send responses to users who request to reset their password.

8. Click **System Settings** to change the length of login sessions from the default of 30 minutes, and click **Save**.

**What to Do Next**

If you use local user management, create users. If you use either LDAP authentication or local user management, create projects and assign users to those projects. 