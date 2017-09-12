# Data That Migrates During vSphere Integrated Containers Appliance Upgrade #

To upgrade an older version of the appliance, you deploy a new appliance instance. The appliance upgrade process migrates vSphere Integrated Containers Registry and Management Portal data from the older appliance to the new appliance. Due to the change in user identity management and the merging of the user interfaces in version 1.2.x of vSphere Integrated Containers Registry and Management Portal, not all data can migrate when you upgrade the vSphere Integrated Containers appliance from 1.1.x to 1.2.x.

## vSphere Integrated Containers Management Portal Data ##

|Type of data|Migrated?|More Information|
|---|---|---|
|Virtual Container Hosts (VCHs)|Yes|VCHs that you added in vSphere Integrated Containers Management Portal 1.1.x migrate to the new version. VCH certificates and credentials also migrate. Upgrading the appliance does not upgrade the VCHs themselves. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).|
|Placement policies|No|You cannot modify placements and placement zones in vSphere Integrated Containers 1.2.x. This version manages placements internally when you create or modify projects.|
|Projects|Yes|Projects that you created in vSphere Integrated Containers Management Portal 1.1.x appear in the **Projects** view of the upgraded interface alongside projects that you created in vSphere Integrated Containers Registry 1.1.x. If you renamed the default project in 1.1.x, the project name reverts to `default-project` after the upgrade. vSphere Integrated Containers Management Portal project names must respect the rules described in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).|
|Registries|Yes|Registries that you added in version 1.1.x migrate to the new version. Registry certificates and credentials also migrate.|
|Applications|Yes|Applications that you created in version 1.1.x migrate to the new version.|
|Containers and templates|Yes|Containers and templates that you created in version 1.1.x migrate to the new version. Containers that are running in VCHs also migrate.|
|Networks and volumes|Yes|Networks and volumes that you created in version 1.1.x migrate to the new version.|

## vSphere Integrated Containers Registry Data ##

|Type of data|Migrated?|More Information|
|---|---|---|
|System Configuration|Yes|If you changed the login token expiration period or deselected the checkbox to verify remote registry certificates during replication, these settings persist after upgrade.|
|Email Settings|No|vSphere Integrated Containers 1.2.x does not implement email notifications.|
|Projects|Yes|All existing projects migrate.|
|Replication endpoints and rules|Yes|All replication endpoints and rules migrate. If the replication endpoints are vSphere Integrated Containers Registry instances, upgrade those instances to 1.2.x. Replication of images from the 1.2.x registry instance to the 1.1.x replication endpoint still functions, but it is recommended that you upgrade the  target registry.|
|Users|No|vSphere Integrated Containers 1.2.x imports users and user groups from the Platform Services Controller. In addition, the roles that you assign to users are different in version 1.2.x. If vSphere Integrated Containers Registry 1.1.x uses database authentication, local registry users cannot migrate to the Platform Services Controller. You can recreate these users in the new version as local users in the Platform Services Controller. If vSphere Integrated Containers Registry 1.1.x uses LDAP authentication, in the new version you must add the appropriate LDAP server as an identity source in the Platform Services Controller. In either case, you must import the users from the Platform Services Controller into vSphere Integrated Containers Management Portal after the upgrade.|
|Image repositories|Yes|All of the images in a project migrate.|
|Logs|Yes|Project logs migrate.|
|Notary|Yes and no|If you used Docker Content Trust, or Notary, to sign images, the signatures include the address of the registry. If the address of the appliance, and therefore of the registry, changed during the upgrade, you must resign the images with the new address. If the address did not change, no action is required. |