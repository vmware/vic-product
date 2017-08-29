# Add Cloud Administrators #

You can add any user from the Platform Services Controller to the vSphere Integrated Containers Management Portal and assign them the Cloud administrator role.  

For more information about working with local users and identity sources in the Platform Services Controller, see the [Platform Services Controller Administration Guide](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.psc.doc/GUID-9451A5B4-5747-42C1-8A82-83AFCC1F2861.html "Platform Services Controller Administration Guide") in the VMware vSphere documentation.

For more information about users and roles in vSphere Integrated Containers, see [Users and Roles](..\vic_overview\introduction.md#usersandroles).

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

    Use an account with Cloud administrator privileges.
2. Select **Administration** > **Identity Management**, and click **Users & Groups**.
3. In the search box, enter a user name, email address, or the user's full name and press Enter.

	Wait for the user to appear in the table.

5. Select the check box next to the user in the table and click **Make Admin**.
	
	The user is now a Cloud administrator for vSphere Integrated Containers.

   
**What to Do Next**

Create projects and assign the users to those projects.