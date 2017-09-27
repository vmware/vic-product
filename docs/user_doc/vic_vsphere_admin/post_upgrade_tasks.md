# Tasks to Perform After Upgrading the vSphere Integrated Containers Appliance #

Due to changes in the data model, user identity management, and the merging of the user interfaces for vSphere Integrated Containers Registry and Management Portal in version 1.2.x, you must perform some manual tasks after you upgrade the vSphere Integrated Containers appliance. 

- Import users from the Platform Services Controller into vSphere Integrated Containers Management Portal. For information about users and roles in this version of vSphere Integrated Containers, see the following topics:

  - [User Authentication](../vic_overview/introduction.md#authentication)
  - [Add Cloud Administrators](../vic_cloud_admin/add_cloud_admins.md)
  - [Add Viewers, Developers, or DevOps Administrators to Projects](../vic_cloud_admin/add_users.md)
- If, in version 1.1.x of the appliance, you manually added the vSphere Integrated Containers Registry instance to vSphere Integrated Containers Management Portal, and if the address of the appliance changed during the upgrade, two instances of vSphere Integrated Containers Registry appear in the **Administration** > **Registries** > **Source Registries** view in the new version. The registry named `default-vic-registry` is the new registry instance that is running in the new appliance, that is automatically registered with the management portal. Data from the registry that was running in the previous appliance has migrated to this instance. A registry instance with the name and address from the old, and now defunct, appliance is present in the list of registries. Delete this instance from the list.
- If you added the same virtual container host (VCH) to more than one placement zone in vSphere Integrated Containers Management Portal 1.1.x, multiple instances of that VCH appear in the **Home** > **Infrastructure** > **Container Hosts** view in the new version. Delete the duplicates. 
