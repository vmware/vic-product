# Create and Manage Container Placements #

You can use placements and placement settings to limit and reserve resources. You can also set a priority to the reserved amount of CPU or memory. Select a project for your placement and provision templates to that project to use the placement resourcing. 

** Prerequisite **

Verify that at least one host is configured and available.

** Procedure **

1. In the management portal, navigate to **Policies** > **Placements** and click **Add**.
2. In the Add Placement dialog box, configure the new placement settings and click **Save**.

Setting | Description
------------ | -------------
**Name** | Enter a name for your placement.
**Project** | Assign the placement to a project. When you provision new templates to that project, you utilize the placement configuration.
**Placement Zone** | Select a placement zone from the list to assign the placement to a host. 
**Priority** | (Optional) Enter a priority value for the placement. Higher value results in higher prioritized resourcing of the provisioned containers in the placement zone.  
**Instances** | (Optional) Enter a number to limit the count of provisioned instances up to that number. For unlimited count, leave empty. 
**Memory Limit** | (Optional) Limits the maximum amount of memory that the placement uses. For unlimited usage, leave empty.

**Result**

The placement appears on the Placements page and you can provision templates to that placement by selecting the assigned project.