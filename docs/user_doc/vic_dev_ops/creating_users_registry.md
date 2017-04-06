# Creating and Managing Users in vSphere Integrated Containers Registry #

##Role Based Access Control

In vSphere Integrated Containers Registry, images are grouped under projects. To access an image, a user should be added as a member into the project of the image. A member can have one of the three roles:  

* **Guest**: Guest has read-only privilege for a specified project.
* **Developer**: Developer has read and write privileges for a project.
* **ProjectAdmin**: When creating a new project, you will be assigned the "ProjectAdmin" role to the project. Besides read-write privileges, the "ProjectAdmin" also has some management privileges, such as adding and removing members.

Besides the above three roles, there are two system-wide roles:  

* **SysAdmin**: "SysAdmin" has the most privileges. In addition to the privileges mentioned above, "SysAdmin" can also list all projects, set an ordinary user as administrator and delete users. The public project "library" is also owned by the administrator.  
* **Anonymous**: When a user is not logged in, the user is considered as an "anonymous" user. An anonymous user has no access to private projects and has read-only access to public projects.  

##User account
vSphere Integrated Containers Registry supports two authentication modes:  

* **Database(db_auth)**  

	Users are stored in the local database.  
	
	A user can register himself/herself in vSphere Integrated Containers Registry in this mode. To disable user self-registration, refer to the **[installation guide](installation_guide_ova.md)**. When self-registration is disabled, the system administrator can add users in vSphere Integrated Containers Registry.  
	
	When registering or adding a new user, the username and email must be unique in the vSphere Integrated Containers Registry system. The password must contain at least 8 characters, less than 20 characters with 1 lowercase letter, 1 uppercase letter and 1 numeric character.  
	
	When you forgot your password, you can follow the below steps to reset the password:  

	1. Click the link "Forgot Password" in the sign in page.  
	2. Input the email address entered when you signed up, an email will be sent out to you for password reset.  
	3. After receiving the email, click on the link in the email which directs you to a password reset web page.  
	4. Input your new password and click "Save".  
	
* **LDAP/Active Directory (ldap_auth)**  

	Under this authentication mode, users whose credentials are stored in an external LDAP or AD server can log in to vSphere Integrated Containers Registry directly.  
	
	When an LDAP/AD user logs in by *username* and *password*, vSphere Integrated Containers Registry binds to the LDAP/AD server with the **"LDAP Search DN"** and **"LDAP Search Password"** described in [installation guide](installation_guide_ova.md). If it successes, vSphere Integrated Containers Registry looks up the user under the LDAP entry **"LDAP Base DN"** including substree. The attribute (such as uid, cn) specified by **"LDAP UID"** is used to match a user with the *username*. If a match is found, the user's *password* is verified by a bind request to the LDAP/AD server.  
	
	Self-registration, changing password and resetting password are not supported anymore under LDAP/AD authentication mode because the users are managed by LDAP or AD.  
