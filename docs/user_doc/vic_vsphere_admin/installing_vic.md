# Installing vSphere Integrated Containers #

You install vSphere Integrated Containers by deploying an OVA appliance. The OVA appliance provides access to all of the vSphere Integrated Containers components.

The installation process involves several steps.

- You download the OVA from http://www.vmware.com/go/download-vic.
- You deploy the OVA, providing configuration information for vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal.
- The OVA deploys an appliance VM to the target vCenter Server instance.
- vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal both run in the appliance VM. 
  - vSphere Integrated Containers Registry: https://<i>vm_address</i>:443
  - vSphere Integrated Containers Management Portal: https://<i>vm_address</i>:8282
- The OVA connects the Registry and Portal instances to each other.
- The appliance VM runs a Web server, that serves two purposes:
  - Makes the vSphere Integrated Containers Engine binaries available for download at https://<i>vm_address</i>:<i>port</i>.
  - Makes the vSphere Client Plug-Ins available for you to upload to vCenter Server.
- You download and unpack the vSphere Integrated Containers Engine binaries on your working system. The vSphere Integrated Containers Engine binaries include command line utilities:
  - You run scripts to deploy the vSphere Client Plug-Ins to vCenter Server.
  - You run the `vic-machine` command line utility to deploy and manage virtual container hosts.