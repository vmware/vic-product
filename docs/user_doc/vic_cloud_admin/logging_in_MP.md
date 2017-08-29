# Logging In to the Management Portal #

You can access the Management Portal in a web browser by entering the vSphere Integrated Containers appliance IP address and the port that you specified for the portal during the deployment. By default the port number is *8282*.

If you don't know the port number, you can access the portal by going to http://<i>vic_appliance_address</i> and following the **Go to the vSphere Integrated Containers Management Portal** link.

## Default User Access to the Management Portal ##

The role that has full permissions for vSphere Integrated Containers is the cloud administrator role. 
By default, the cloud administrator role is assigned to the Administrators group for vCenter Server during the installation of vSphere Integrated Containers. Every user that is a member of that group in the Platform Services Controller can access the Management Portal as cloud administrator. After you log in as a cloud administrator, you can give other users access to vSphere Integrated Containers by assigning them roles in projects.

Optionally, you can log in with an example user that you created during the OVA deployment, if you used that option.

For more information about users and roles, see [Users and Roles](../vic_overview/introduction.md#usersandroles).
