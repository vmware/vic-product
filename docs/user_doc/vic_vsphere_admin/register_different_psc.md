# Register the vSphere Integrated Containers Appliance with a Different Platform Services Controller

If necessary, you can register the vSphere Integrated Containers appliance with a different Platform Services Controller than the one that you used for the initial deployment of the appliance.

**Procedure**

1. Use SSH to connect to the appliance as root user.

    <pre>ssh root@<i>vic_appliance_address</i></pre>
2. Stop the vSphere Integrated Containers Management Portal service.

    <pre>systemctl stop admiral.service</pre>
2. List all of the containers that are running in the appliance.

    <pre>docker ps -a</pre>

2. If a container named `vic-admiral` is present, remove it. 

    The `vic-admiral` container runs the  vSphere Integrated Containers Management Portal service.

    <pre>docker rm -f vic-admiral</pre>

2. Delete the three Platform Services Controller configuration files from the appliance.

    <pre>rm /etc/vmware/psc/admiral/psc-config.properties`</pre>
    <pre>rm /etc/vmware/psc/engine/psc-config.properties`</pre>
    <pre>rm /etc/vmware/psc/harbor/psc-config.properties`</pre>
3. Go to the vSphere Integrated Containers Getting Started page at http://<i>vic_appliance_address</i>.
4. Scroll to the bottom of the page and click the  **Re-Initialize the  vSphere Integrated Containers Appliance** button. 
5. Enter the vCenter Server address and credentials and the address of the new Platform Services Controller and click **Continue**.
