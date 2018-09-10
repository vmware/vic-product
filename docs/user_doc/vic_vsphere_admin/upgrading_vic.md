# Upgrading vSphere Integrated Containers #

You can only upgrade vSphere Integrated Containers from version 1.2.x or  1.3.x to 1.4.x, or from 1.4.x to a later 1.4.y update release. You cannot upgrade any release earlier than 1.2.x to 1.4.x.

You upgrade vSphere Integrated Containers in three stages: 

## Upgrade the vSphere Integrated Containers Appliance

Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal. 

- For information about how to prepare for upgrade, see [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md) 
- For information about upgrading the appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). 

## Upgrade Virtual Container Hosts

After you have upgraded the appliance, you can download the new version of the vSphere Integrated Containers Engine bundle. Then, you can use `vic-machine` to upgrade your virtual container hosts (VCHs) individually. 

For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).

## Upgrade the vSphere Client Plug-In

If you upgraded to vSphere Integrated Containers 1.4.3 or later, by default the vSphere Integrated Containers plug-in for the vSphere Client is upgraded automatically. If you choose not to automatically upgrade the plug-in, or if you upgraded to a version of vSphere Integrated Containers that pre-dates 1.4.3, you must upgrade the plug-in manually.

For information about manually upgrading the vSphere Client plug-in, see [Manually Upgrade the vSphere Client Plug-In](upgrade_plugins.md).