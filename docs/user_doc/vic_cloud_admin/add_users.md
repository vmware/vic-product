# Add Users to vSphere Integrated Containers #

If you configured vSphere Integrated Containers Registry to use local user management rather than LDAP authentication, you must create user accounts before you can assign users to projects. 

If the registry uses LDAP authentication, you cannot create or register new users in the registry. The LDAP server manages users externally. However, users must log in at least once with their LDAP credentials in order to be added to the registry account system. After a user has logged in once, you can assign that user to projects.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

    Use an account with Cloud Administrator privileges.
2. Select **Administration** > **Identity Management**, and click **Users & Groups**.
3. Enter a user name, email address, and the user's full name.

   The user name and email address must be unique in this registry instance. The email address and the user's full name are for use in email responses to password reset requests.
5. Enter and confirm a password for the user.

   The password must contain at least 8 characters, with at least 1 lower case letter, 1 upper case letter, and 1 numeric character. Special characters are permitted. If the passwords do not match or if they do not meet the password criteria, the **OK** button remains deactivated.
6. When you have completed all of the required fields correctly, click **OK**.

   
**What to Do Next**

Create projects and assign the users to those projects. 