# Create Users in vSphere Integrated Containers Registry #

If you configured vSphere Integrated Containers Registry to use local user management rather than LDAP authentication, you must create user accounts before you can assign users to projects. 

If the registry uses LDAP authentication, you cannot create or register new users in the registry. The LDAP server manages users externally. However, users must log in at least once with their LDAP credentials in order to be added to the registry account system. After a user has logged in once, you can assign that user to projects.

**Procedure**

1. Log in to the vSphere Integrated Containers Management Portal at https://<i>vic_appliance_address</i>:8282.

    Use an account with vCenter Server administrator privileges. If the vSphere Integrated Containers appliance uses a different port for vSphere Integrated Containers Registry, replace 443 with the appropriate port.
2. Expand **Administration** on the left, click **Users**, then click the **+ Users** button.
3. Enter a user name, email address, and the user's full name.

   The user name and email address must be unique in this registry instance. The email address and the user's full name are for use in email responses to password reset requests.
5. Enter and confirm a password for the user.

   The password must contain at least 8 characters, with at least 1 lower case letter, 1 upper case letter, and 1 numeric character. Special characters are permitted. If the passwords do not match or if they do not meet the password criteria, the **OK** button remains deactivated.
6. When you have completed all of the required fields correctly, click **OK**.

   
**What to Do Next**

Create projects and assign the users to those projects. 