# Upgrading vSphere Integrated Containers #

You can only upgrade vSphere Integrated Containers from version 1.2.x or  1.3.x to 1.4.x, or from 1.4.x to a later 1.4.y update release. You cannot upgrade any release earlier than 1.2.x to 1.4.x.

You upgrade vSphere Integrated Containers in three stages: 

## Upgrade the vSphere Integrated Containers Appliance

Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal. 

- For information about how to prepare for upgrade, see [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md) 
- For information about upgrading the appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). 

## Upgrade Virtual Container Hosts

After you have upgraded the appliance, you can download the new version of the vSphere Integrated Containers Engine bundle. To upgrade vSphere Integrated Containers Engine, you upgrade the virtual container hosts (VCHs) individually. 

For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).

## Upgrade the vSphere Client Plug-Ins

After you have upgraded the appliance and downloaded the vSphere Integrated Containers Engine bundle, you can upgrade the HTML5 vSphere Client plug-in. 

For information about upgrading the vSphere Client plug-in, see the topic that corresponds to the type of vCenter Server that you use.

- [Upgrade the vSphere Client Plug-Ins on vCenter Server for Windows](upgrade_h5_plugin_windows.md)
- [Upgrade the vSphere Client Plug-Ins on vCenter Server Appliance](upgrade_h5_plugin_vcsa.md)
