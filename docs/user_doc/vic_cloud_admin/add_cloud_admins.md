# Add Management Portal Administrators

You can add any user or group from the Platform Services Controller to the vSphere Integrated Containers Management Portal and assign them the Management Portal administrator role.  

For more information about working with local users and identity sources in the Platform Services Controller, see the [Platform Services Controller Administration Guide](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.psc.doc/GUID-9451A5B4-5747-42C1-8A82-83AFCC1F2861.html "Platform Services Controller Administration Guide") in the VMware vSphere documentation.

For more information about users and roles in vSphere Integrated Containers, see [vSphere Integrated Containers Roles and Personas](../vic_overview/roles_and_personas.md).

## Prerequisites

Log in to vSphere Integrated Containers Management Portal with a vSphere administrator or Management Portal administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).

## Procedure

1. Select **Administration** > **Identity Management**, and click **Users & Groups**.
3. In the search box, enter a group name, user name, email address, or the user's full name and press Enter.

	Wait for the user or group to appear in the table.

5. Select the check box next to the user in the table and click **Assign Admin Role**.
	
	The user is now a Management Portal administrator for vSphere Integrated Containers. You can use the same workflow to unassign the role from a current Management Portal Administrator user or group.

   
## What to Do Next

Start [Working with Projects](working_with_projects.md) and [Working with Registries](working_with_registries.md).

