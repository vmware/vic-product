# Installing vSphere Integrated Containers #

You install vSphere Integrated Containers by deploying an OVA appliance. The OVA appliance provides access to all of the vSphere Integrated Containers components.

The installation process involves several steps.

- [Download the OVA installer](download_vic.md).
- [Deploy the OVA](deploy_vic_appliance.md), providing configuration information for vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal. The OVA deploys an appliance VM that provides the following services:
  - Runs vSphere Integrated Containers Registry
  - Runs vSphere Integrated Containers Management Portal
  - Makes the vSphere Integrated Containers Engine binaries available for download
  - Hosts the vSphere Client plug-in packages for vCenter Server
  - Hosts the Web Installer for demo virtual container hosts (VCHs)
- Run the Web Installer to [deploy a demo VCH](deploy_demo_vch.md).
- Run the scripts to [install the vSphere Client plug-ins on vCenter Server](install_vic_plugin.md).
- Run the command line utility, `vic-machine`, to [deploy and manage VCHs in production](deploy_vch.md).