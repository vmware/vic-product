# Restart the vSphere Integrated Containers Services #

You can restart the vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal services and the file server that run in the appliance by logging in to the vSphere Integrated Containers appliance.

**Prerequisites**

You deployed the vSphere Integrated Containers appliance.

**Procedure**
1. Connect to the vSphere Integrated Containers appliance by using SSH.
2. If the status of the service is `active (running)`, run one of the following commands to restart one of the vSphere Integrated Containers services:

  - vSphere Integrated Containers Registry: `systemctl restart harbor`
  - vSphere Integrated Containers Management Portal services: `systemctl restart admiral`
  - Embedded file server: `systemctl restart fileserver`
2. If the status of the service is `failed` or `inactive (dead)`, run one of the following commands to restart one of the vSphere Integrated Containers services:

  - vSphere Integrated Containers Registry: `systemctl start harbor`
  - vSphere Integrated Containers Management Portal services: `systemctl start admiral`
  - Embedded file server: `systemctl start fileserver`