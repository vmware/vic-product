# Configuring Registries #

A user can register himself/herself in vSphere Integrated Containers Registry in local user management (Database) mode. You can disable user self-registration. When self-registration is disabled, only the system administrator can add users in vSphere Integrated Containers Registry.  


## LDAP Authentication ## 

The auth_mode can only be switched when there is no user (except for admin) and no project (except for library) in the database. This instance already has quite a few users ( in database mode), switching to LDAP will cause user management issues. Therefore ldap_mode has been disabled.

So our document should describe that the users must choose LDAP mode at the first login of Harbor. After they’ve created some projects or users, they no longer have the option to switch to LDAP mode.

When an LDAP/AD user logs in by *username* and *password*, vSphere Integrated Containers Registry binds to the LDAP/AD server with the **"LDAP Search DN"** and **"LDAP Search Password"** described in [installation guide](installation_guide_ova.md). If it successes, vSphere Integrated Containers Registry looks up the user under the LDAP entry **"LDAP Base DN"** including substree. The attribute (such as uid, cn) specified by **"LDAP UID"** is used to match a user with the *username*. If a match is found, the user's *password* is verified by a bind request to the LDAP/AD server.  
	
Self-registration, changing password and resetting password are not supported anymore under LDAP/AD authentication mode because the users are managed by LDAP or AD.  



