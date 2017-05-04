# Upgrading vSphere Integrated Containers #

If you have an existing deployment of vSphere Integrated Containers 1.0, you can upgrade its components to version 1.1 or to a 1.1.x update release.

- You can upgrade the vSphere Integrated Containers appliance from version 1.1.x to a later 1.1.y update release. Upgrading the appliance upgrades both vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal, and allows you to download the new version of vSphere Integrated Containers Engine.
- To upgrade vSphere Integrated Containers Engine from 0.8 or later to a 1.1.x release, you upgrade the virtual container hosts (VCHs) individually.
- You can upgrade vSphere Integrated Containers Registry from version 0.5 to version 1.1.x.
- There is no upgrade for the Flex-based vSphere Web Client plug-in for vSphere Integrated Containers 1.0. Use the plug-in for the HTML5 vSphere Client, which is new in 1.1. 

vSphere Integrated Containers 1.0 did not officially support vSphere Integrated Containers Management Portal. You cannot upgrade an instance of vSphere Integrated Containers Management Portal that predates version 1.1.0 to version 1.1.x. 


* [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md)
* [Upgrade a VCH](upgrade_vch.md)
* [Upgrade the HTML5 vSphere Client Plug-In](upgrade_h5_plugin.md)
* [Upgrade vSphere Integrated Containers Registry 0.5 to 1.1.x](upgrade_registry.md)