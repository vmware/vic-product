# Data That Migrates During vSphere Integrated Containers Appliance Upgrade #

Due to differences in implementation between versions 1.1 and 1.2 of the vSphere Integrated Containers Registry and Management Portal, not all data is migrated when you upgrade the vSphere Integrated Containers appliance from 1.1.x to 1.2.x.

## vSphere Integrated Containers Management Portal Data ##

|Type of data|Migrated?|More Information|
|---|---|---|
|Virtual Container Hosts (VCHs)|Yes|VCHs that you added in the previous version migrate to the new version. Upgrading the appliance does not upgrade the VCHs themselves. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).|
|Placement policies|No|This version of vSphere Integrated Containers does not implement placement policies. In this version of vSphere Integrated Containers, projects manage placement.|
|Registries|Yes|Registries that you added in the previous version migrate to the new version. Registry certificates and credentials also migrate.  **IMPORTANT**: If you added vSphere Integrated Containers Registry to the previous version of the vSphere Integrated Containers Management Portal, you must update the address of that registry to reflect the address of the new vSphere Integrated Containers appliance.|
|Applications|Yes|Applications that you created in the previous version migrate to the new version.|
|Containers and templates|Yes|Containers and templates that you created in the previous version migrate to the new version. Containers that are running in VCHs also migrate.|
|Networks and volumes|Yes|Networks and volumes that you created in the previous version migrate to the new version.|

## vSphere Integrated Containers Registry Data ##

|Type of data|Migrated?|More Information|
|---|---|---|
|System Configuration|Partially|After upgrade, the login token expiration period reverts to the default of 30 minutes. If you deselected the checkbox to verify remote registry certificates during replication, this setting persists after upgrade.|
|Email Settings|No|This version of vSphere Integrated Containers does not implement email notifications.|
|Projects|Yes|All existing projects migrate|
|Replication endpoints and rules|No|Because registry addresses change during the upgrade, and because you cannot replicate between registries of different versions, replication endpoints and rules do not migrate.|
|Users|No|???|
|Image repositories|???|???|
|Logs|???|???|