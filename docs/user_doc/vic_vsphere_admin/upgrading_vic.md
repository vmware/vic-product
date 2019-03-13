# Upgrading vSphere Integrated Containers #

You can only upgrade vSphere Integrated Containers from version 1.3.x or 1.4.x to 1.5.x, or from 1.5.x to a later 1.5.y update release. You cannot upgrade any release earlier than 1.3.x to 1.5.x.

You upgrade vSphere Integrated Containers in three stages: 

- [Upgrade the vSphere Integrated Containers Appliance](#appliance)
- [Upgrade Virtual Container Hosts](#vch)
- [Upgrade the vSphere Client Plug-In](#ui)

## Upgrade the vSphere Integrated Containers Appliance <a id="appliance"></a>

Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal. By default, upgrading the appliance also upgrades the vSphere Integrated Containers plug-in for the vSphere Client.

- For information about how to prepare for upgrade, see [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md) 
- For information about upgrading the appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). 

## Upgrade Virtual Container Hosts <a id="vch"></a>

After you have upgraded the appliance, you can download the new version of the vSphere Integrated Containers Engine bundle. Then, you can use `vic-machine` to upgrade your virtual container hosts (VCHs) individually. 

For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).

## Upgrade the vSphere Client Plug-In <a id="ui"></a>

By default the vSphere Integrated Containers plug-in for the vSphere Client is upgraded automatically when you upgrade the appliance. If you choose not to upgrade the plug-in at the same time as the appliance, you can do so later by reinitializing the appliance. 

For information about upgrading the vSphere Client plug-in, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md).