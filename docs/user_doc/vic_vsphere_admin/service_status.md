# Check the Status of the vSphere Integrated Containers Services #

You can check the status of the vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal services, and the file server that runs in the appliance, by logging in to the vSphere Integrated Containers appliance.

**Prerequisites**

You deployed the vSphere Integrated Containers appliance

**Procedure**
1. Connect to the vSphere Integrated Containers appliance by using SSH.
2. Run one of the following commands to check the status of one of the vSphere Integrated Containers services:

  - vSphere Integrated Containers Registry: `systemctl status harbor`
  - vSphere Integrated Containers Management Portal services: `systemctl status admiral`
  - Embedded file server: `systemctl status fileserver`

**Result**

The output shows the status of the service that you specified, as well as the most recent log entries.

|Status|Description|
|---|---|
|`active (running)`|The service is running correctly.|
|`inactive (failed)`|The service failed to start.|
|`inactive (dead)`|The service is not responding.|

**What to Do Next**

If the status is `inactive (failed)` or `inactive (dead)`, see [Restart the vSphere Integrated Containers Services](restart_services.md).