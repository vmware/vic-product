# Installing vSphere Integrated Containers #

You install vSphere Integrated Containers by deploying an OVA appliance. The OVA appliance provides access to all of the vSphere Integrated Containers components.

The installation process involves several steps.

- Download the OVA from http://www.vmware.com/go/download-vic.
- Deploy the OVA, providing configuration information for vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal. The OVA deploys an appliance VM that provides the following services:
  - Runs vSphere Integrated Containers Registry
  - Runs vSphere Integrated Containers Management Portal
  - Makes the vSphere Integrated Containers Engine binaries available for download
  - Hosts the vSphere Client plug-in packages for vCenter Server
- Run the scripts to install the vSphere Client plug-ins on vCenter Server.
- Run the command line utility, `vic-machine`, to deploy and manage virtual container hosts.