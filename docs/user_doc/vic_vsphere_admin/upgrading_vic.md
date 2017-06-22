# Upgrading vSphere Integrated Containers #

If you have an existing deployment of vSphere Integrated Containers, you can upgrade its components to a 1.2.x release.

- You can upgrade the vSphere Integrated Containers appliance from version 1.2.x to a later 1.2.y update release. Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal, and allows you to download the new version of vSphere Integrated Containers Engine.
- To upgrade vSphere Integrated Containers Engine from 0.8 or later to a 1.2.x release, you upgrade the virtual container hosts (VCHs) individually.
- You can upgrade vSphere Integrated Containers Registry from version 0.5 to version 1.2.x.
- You can upgrade the HTML5 vSphere Client plug-in from version 1.1.x to 1.2.x update release, from version 1.2.x to a later 1.2.y update release.
- vSphere Integrated Containers 1.0 did not officially support vSphere Integrated Containers Management Portal. You cannot upgrade an instance of vSphere Integrated Containers Management Portal (Admiral) that predates version 1.1.0 to version 1.2.x. 

**NOTE**: No new development work is planned for the plug-in for the Flex-based vSphere Web Client. In this and future releases, only the HTML5 vSphere Client will be updated. This release adds no new features to the Flex plug-in. If you installed the Flex plug-in with a previous release of vSphere Integrated Containers, there is no upgrade to perform.

* [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md)
* [Upgrade a VCH](upgrade_vch.md)
* [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md)
* [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md)
* [Upgrade vSphere Integrated Containers Registry 0.5 to 1.1.x](upgrade_registry.md)