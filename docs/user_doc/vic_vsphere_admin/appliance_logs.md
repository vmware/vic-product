# Access and Configure Appliance Logs #

You access the logs for the vSphere Integrated Containers appliance by using SSH and navigating to `/storage/log`. You can also configure log retention for the different logs.

**Prerequisites**

Make sure that SSH access to the appliance is enabled. To enable SSH access to the appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).

**Procedure**

1. Use SSH to connect to the appliance as root user.<pre>$ ssh root@vic_appliance_address</pre>When prompted for the password, enter the appliance password that you specified when you deployed the appliance.
2. To create a complete log bundle for the appliance, run the `appliance-support.sh` script.<pre>/etc/vmware/support/appliance-support.sh</pre>Running this script creates a log bundle, `/storage/log/vic_appliance_logs_YYYY-MM-DD-00-01-00.tar.gz`, that you can supply to VMware support. This bundle includes the installation logs.
3. If you performed an upgrade on this appliance instance and need to see the upgrade log, navigate to `/var/log/vmware` to obtain the `upgrade.log` file.<pre>$ cd /var/log/vmware</pre> 
4. To access logs for vSphere Integrated Containers Registry, navigate to `/storage/log/harbor`.<pre>$ cd /storage/log/harbor</pre>The `/storage/log/harbor` folder contains the log files for the following services:

   - `adminserver.log`: Registry administration service
   - `clair-db.log`: Clair database used for vulnerability scanning of images
   - `clair.log`: Clair service used for vulnerability scanning of images
   - `jobservice.log`: Registry job service log
   - `mysql.log`: Embedded registry database
   - `notary-db.log`: Notary database by Docker Content Trust
   - `notary-server.log`: Notary server used by Docker Content Trust
   - `notary-signer.log`: Notary image signing service used by Docker Content Trust
   - `proxy.log`: Proxy service logs
   - `registry.log`: Registry service logs
   - `ui.log`: User interface logs

5. To configure the log retention for the registry services, edit the `/storage/data/harbor/harbor.cfg` file.<pre>$ vi /storage/data/harbor/harbor.cfg</pre>The default configuration allows 50 files, up to 200MB each per service.
	1. To set the maximum number of files used for storing logs per service, change the `log_rotate_count` property value to the desired number.
	2. To set the maximum size in MB per file, change the `log_rotate_size` property value to the desired number.
6. To access logs for the `vic-machine-server` service, navigate to `/storage/log/vic-machine-server`.<pre>$ cd /storage/log/vic-machine-server</pre>The default configuration allows 10 files, up to 1GB each.
7. To configure the `vic-machine-server` service log retention, edit the `/etc/logrotate.d/vic-machine-server` file.<pre>$ vi /etc/logrotate.d/vic-machine-server</pre>The default configuration allows 50 files, up to 200MB each per service.
	1. To set the maximum number of files used for storing logs, change the `rotate` property value to the desired number.
	2. To set the maximum size in GB per file, change the `size` property value to the desired number.
8. To access logs for vSphere Integrated Containers Management Portal, navigate to `/storage/log/admiral`.<pre>$ cd /storage/log/admiral</pre>
9. To configure the management portal log retention, edit the `/etc/vmware/admiral/logging-vic.properties` file.<pre>$ vi /etc/vmware/admiral/logging-vic.properties</pre>
The default configuration allows 5 files, up to 1GB each.
	1. To set the maximum number of files used for storing logs, change the `java.util.logging.FileHandler.count` property value to the desired number.
	2. To set the maximum size in bytes per file, change the `java.util.logging.FileHandler.limit` property value to the desired number.