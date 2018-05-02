# Check the Status of the vSphere Integrated Containers Services #

You can check the status of the vSphere Integrated Containers services that run in the appliance by logging in to the vSphere Integrated Containers appliance. The following services run in the vSphere Integrated Containers appliance:

- vSphere Integrated Containers Registry service
- vSphere Integrated Containers Management Portal service
- The file server for vSphere Integrated Containers Engine downloads and installation of the vSphere Client plug-ins
- The `vic-machine-server` service, that powers the Create Virtual Container Host wizard in the HTML5 vSphere Client plug-in

**Prerequisites**

You deployed the vSphere Integrated Containers appliance.

**Procedure**

1. Connect to the vSphere Integrated Containers appliance by using SSH.
2. Run one of the following commands to check the status of one of the vSphere Integrated Containers services:

  - vSphere Integrated Containers Registry: <pre>systemctl status harbor.service</pre>
  - vSphere Integrated Containers Management Portal services: <pre>systemctl status admiral.service</pre>
  - Embedded file server: <pre>systemctl status fileserver.service</pre>
  - `vic-machine-server`: <pre>systemctl status vic-machine-server.service</pre>

**Result**

The output shows the status of the service that you specified, as well as the most recent log entries.

|Status|Description|
|---|---|
|`active (running)`|The service is running correctly.|
|`inactive (failed)`|The service failed to start.|
|`inactive (dead)`|The service is not responding.|

**What to Do Next**

If the status is `inactive (failed)` or `inactive (dead)`, see [Restart the vSphere Integrated Containers Services](restart_services.md).