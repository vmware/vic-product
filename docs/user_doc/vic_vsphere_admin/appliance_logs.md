# Access vSphere Integrated Containers Appliance Logs #

You access the logs for the vSphere Integrated Containers appliance by using SSH.

**Prerequisites**

Make sure that SSH access to the appliance is enabled. To enable SSH access to the appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).

**Procedure**

1. Use SSH to connect to the appliance as root user.<pre>$ ssh root@new_vic_appliance_address</pre>When prompted for the password, enter the appliance password that you specified when you deployed the appliance.
2. To access the logs for the appliance, navigate to `/var/log`.<pre>$ cd /var/log</pre>The `/var/log` folder contains the appliance installation log, `installation.log`.
3. To access logs for vSphere Integrated Containers Registry, navigate to `/var/log/harbor`.<pre>$ cd /var/log/harbor</pre>The `/var/log` folder contains the log files for the following services:

   - `adminserver.log`: Registry administration service.
   - `clair-db.log`: Clair database used for vulnerability scanning of images
   - `clair.log`: Clair service used for vulnerability scanning of images
   - `jobservice.log`
   - `mysql.log`: Embedded registry database
   - `notary-db.log`: Notary database by Docker Content Trust
   - `notary-server.log`: Notary server used by Docker Content Trust
   - `notary-signer.log`: Notary image signing service used by Docker Content Trust
   - `registry.log`: Registry service logs
   - `ui.log`: User interface logs

1. To access logs for vSphere Integrated Containers Management Portal, run the `docker logs` command.

    vSphere Integrated Containers Management Portal runs as a Docker container in the appliance.<pre>$ docker logs vic-admiral</pre>