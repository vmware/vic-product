# Restart the vSphere Integrated Containers Services #

You can restart the vSphere Integrated Containers services that run in the appliance by logging in to the vSphere Integrated Containers appliance. The following services run in the vSphere Integrated Containers appliance:

- vSphere Integrated Containers Registry service
- vSphere Integrated Containers Management Portal service
- The file server for vSphere Integrated Containers Engine downloads and installation of the vSphere Client plug-in
- The `vic-machine-server` service, that powers the Create Virtual Container Host wizard in the HTML5 vSphere Client plug-in

**Prerequisites**

You deployed the vSphere Integrated Containers appliance.

**Procedure**

1. Connect to the vSphere Integrated Containers appliance by using SSH.
2. Run one of the following commands to restart one of the vSphere Integrated Containers services:

  - vSphere Integrated Containers Registry: <pre>systemctl restart harbor.service</pre>
  - vSphere Integrated Containers Management Portal services: <pre>systemctl restart admiral.service</pre>
  - Embedded file server: <pre>systemctl restart fileserver.service</pre>
  - `vic-machine-server`: <pre>systemctl restart vic-machine-server.service</pre>