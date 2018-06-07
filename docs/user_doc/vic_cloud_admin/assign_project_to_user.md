# Assign Projects to a User #

You can assign one or more projects to any user from the Platform Services Controller to the vSphere Integrated Containers Management Portal. You assign the same user different roles in different projects.  

For more information about working with local users and identity sources in the Platform Services Controller, see the [Platform Services Controller Administration Guide](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.psc.doc/GUID-9451A5B4-5747-42C1-8A82-83AFCC1F2861.html "Platform Services Controller Administration Guide") in the VMware vSphere documentation.

For more information about users and roles in vSphere Integrated Containers, see [vSphere Integrated Containers Roles and Personas](../vic_overview/roles_and_personas.md).

**Prerequisites**

Log in to vSphere Integrated Containers Management Portal with a vSphere administrator or Cloud administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).

**Procedure**

1. Select **Administration** > **Identity Management** > **Users & Groups**.
4. In the search box, enter all or part of a user name, email address, or user group name and press Enter.
5. Select the check box for a user, and click **Assign Project Roles**.
6. From the left hand drop-down menu, select a project to which to assign the user or group.   
7. From the right-hand drop-down menu, select a role for the user or group in that project. 
8. (Optional) Click the plus (**+**) symbol to assign more projects to the same user.

    You can assign multiple projects to the same user. The user can have a different role in each project.

9. Click **OK**. 

**Result**

The projects that you assigned to the user are listed in the **Projects** column. You can remove a user from a project by selecting the user, clicking **Assign Project Roles**, and clicking the minus (**-**) symbol for a project.

**What to Do Next**

[Add Container Hosts to Projects](vchs_and_mgmt_portal.md)

