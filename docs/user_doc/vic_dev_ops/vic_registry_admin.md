# Initial Configuration of vSphere Integrated Containers Registry #

vSphere Integrated Containers Registry supports two authentication modes:  

* **Database**  

	Users are stored in the local database.  
	
	A user can register himself/herself in vSphere Integrated Containers Registry in this mode. To disable user self-registration, refer to the **[installation guide](installation_guide_ova.md)**. When self-registration is disabled, the system administrator can add users in vSphere Integrated Containers Registry.  
	
	When registering or adding a new user, the username and email must be unique in the vSphere Integrated Containers Registry system. The password must contain at least 8 characters, less than 20 characters with 1 lowercase letter, 1 uppercase letter and 1 numeric character.  
	
	When you forgot your password, you can follow the below steps to reset the password:  

	1. Click the link "Forgot Password" in the sign in page.  
	2. Input the email address entered when you signed up, an email will be sent out to you for password reset.  
	3. After receiving the email, click on the link in the email which directs you to a password reset web page.  
	4. Input your new password and click "Save".  
	
* **LDAP**  

	Under this authentication mode, users whose credentials are stored in an external LDAP or AD server can log in to vSphere Integrated Containers Registry directly.  
	
	When an LDAP/AD user logs in by *username* and *password*, vSphere Integrated Containers Registry binds to the LDAP/AD server with the **"LDAP Search DN"** and **"LDAP Search Password"** described in [installation guide](installation_guide_ova.md). If it successes, vSphere Integrated Containers Registry looks up the user under the LDAP entry **"LDAP Base DN"** including substree. The attribute (such as uid, cn) specified by **"LDAP UID"** is used to match a user with the *username*. If a match is found, the user's *password* is verified by a bind request to the LDAP/AD server.  
	
	Self-registration, changing password and resetting password are not supported anymore under LDAP/AD authentication mode because the users are managed by LDAP or AD.  


###Managing user
Administrator can add "administrator" role to an ordinary user by toggling the switch under "Administrator". To delete a user, click on the recycle bin icon.  

![browse project](img/new_set_admin_remove_user.png)

###Managing destination
You can list, add, edit and delete destinations in the "Destination" tab. Only destinations which are not referenced by any policies can be edited.  

![browse project](img/new_manage_destination.png)

###Managing replication
You can list, edit, enable and disable policies in the "Replication" tab. Make sure the policy is disabled before you edit it.  

![browse project](img/new_manage_replication.png)

### Deleting repositories

Repository deletion runs in two steps.  

First, delete a repository in Harbor's UI. This is soft deletion. You can delete the entire repository or just a tag of it. After the soft deletion, 
the repository is no longer managed in Harbor, however, the files of the repository still remain in Harbor's storage.  

![browse project](img/new_delete_repository.png)

**CAUTION: If both tag A and tag B refer to the same image, after deleting tag A, B will also get deleted.**  

Next, set **"Garbage Collection"** to true according to the [installation guide](installation_guide_ova.md)(skip this step if this flag has already been set) and reboot the VM, Harbor will perform garbage collection when it boots up.  

For more information about garbage collection, please see Docker's document on [GC](https://github.com/docker/docker.github.io/blob/master/registry/garbage-collection.md).  