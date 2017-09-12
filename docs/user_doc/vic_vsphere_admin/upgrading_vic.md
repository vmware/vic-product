# Upgrading vSphere Integrated Containers #

You can upgrade vSphere Integrated Containers from version 1.1.x to 1.2.x, or from 1.2.x to a later 1.2.y update release.

You cannot upgrade any of the components of vSphere Integrated Containers 1.0, namely vSphere Integrated Containers Engine 0.8 and vSphere Integrated Containers Registry 0.5, to 1.2.x. Similarly, you cannot upgrade an instance of vSphere Integrated Containers Management Portal (Admiral) that predates version 1.1.0 to version 1.2.x.

You upgrade vSphere Integrated Containers in three stages: 

## Upgrade the vSphere Integrated Containers Appliance

Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal. 

- For information about the data that migrates during upgrade, see [Data That Migrates During vSphere Integrated Containers Appliance Upgrade](upgrade_data.md). 
- For information about how to prepare for upgrade, see [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md) 
- For information about upgrading the appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). 

## Upgrade Virtual Container Hosts

After you have upgraded the appliance, you can download the new version of the vSphere Integrated Containers Engine bundle. To upgrade vSphere Integrated Containers Engine, you upgrade the virtual container hosts (VCHs) individually. 

For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).

## Upgrade the vSphere Client Plug-Ins

After you have upgraded the appliance and downloaded the vSphere Integrated Containers Engine bundle, you can upgrade the HTML5 vSphere Client plug-in. 

For information about upgrading the vSphere Client plug-in, see the topic that corresponds to the type of vCenter Server that you use.

- [Upgrade the Plug-Ins on vCenter Server for Windows](upgrade_h5_plugin_windows.md)
- [Upgrade the Plug-Ins on vCenter Server Appliance](upgrade_h5_plugin_vcsa.md)