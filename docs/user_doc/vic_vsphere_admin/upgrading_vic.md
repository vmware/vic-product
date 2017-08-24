# Upgrading vSphere Integrated Containers #

You can upgrade vSphere Integrated Containers from version 1.1.x to 1.2.x, or from 1.2.x to a later 1.2.y update release.

You cannot upgrade any of the components of vSphere Integrated Containers 1.0, namely vSphere Integrated Containers Engine 0.8 and vSphere Integrated Containers Registry 0.5, to 1.2.x. Similarly, you cannot upgrade an instance of vSphere Integrated Containers Management Portal (Admiral) that predates version 1.1.0 to version 1.2.x.

You upgrade vSphere Integrated Containers in three stages: 

## Upgrade the vSphere Integrated Containers Appliance

Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal. For information about upgrading the appliance, see [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). For information about the data that migrates during upgrade, see [Data That Migrates During vSphere Integrated Containers Appliance Upgrade](upgrade_data.md). 

## Upgrade Virtual Container Hosts

After you have upgraded the appliance, you can download the new version of the vSphere Integrated Containers Engine bundle. To upgrade vSphere Integrated Containers Engine, you upgrade the virtual container hosts (VCHs) individually. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).

## Upgrade the HTML5 vSphere Client Plug-In

After you have upgraded the appliance and downloaded the vSphere Integrated Containers Engine bundle, you can upgrade the HTML5 vSphere Client plug-in. For information about upgrading the vSphere Client plug-in, see [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md) or [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md), depending on the type of vCenter Server that you use.
   
    
**NOTE**: No new development work is planned for the plug-in for the Flex-based vSphere Web Client. In this and future releases, only the HTML5 vSphere Client will be updated. This release adds no new features to the Flex plug-in. If you installed the Flex plug-in with a previous release of vSphere Integrated Containers, there is no upgrade to perform.