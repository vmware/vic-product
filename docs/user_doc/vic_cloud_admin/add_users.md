# Assign Viewers, Developers, or DevOps Administrators to a Project #

You can add any user or user group from the Platform Services Controller to the vSphere Integrated Containers Management Portal and assign them a role in a project.  

For more information about working with local users and identity sources in the Platform Services Controller, see the [Platform Services Controller Administration Guide](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.psc.doc/GUID-9451A5B4-5747-42C1-8A82-83AFCC1F2861.html "Platform Services Controller Administration Guide") in the VMware vSphere documentation.

For more information about users and roles in vSphere Integrated Containers, see [vSphere Integrated Containers Roles and Personas](../vic_overview/roles_and_personas.md).

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

    Use an account with Cloud administrator or DevOps administrator privileges.
2. Select **Administration** > **Projects**, and click a project to add users to.
3. Click the **Members** tab and click **+ Add** to add a new user or group to that project.
4. In the Add Users and Groups window configure the user and the access.
	1. In the **ID or email** text box, enter any detail for a desired user and select it from the populated list.
	2. From the **Role in project** drop-down menu, select a role for that user and click **OK**.   
5. (Optional) Change the role of a user that is assigned to the project.
	1. From the table with users, select the check box next to a user and click **Edit**.
	2. In the **Edit member role in project** window, select new role for that user and click **OK**.