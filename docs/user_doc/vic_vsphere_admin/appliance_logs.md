# Access and Configure Appliance Logs #

You access the logs for vSphere Integrated Containers by using SSH to connect to the appliance. You can also access logs and configure log retention for each of the different vSphere Integrated Containers components.

**Prerequisites**

Make sure that SSH access to the appliance is enabled. To enable SSH access to the appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).

**Procedure**

1. Use SSH to connect to the appliance as root user.<pre>$ ssh root@vic_appliance_address</pre>When prompted for the password, enter the appliance password that you specified when you deployed the appliance.
2. To create a complete log bundle for the appliance, run the `appliance-support.sh` script.<pre>/etc/vmware/support/appliance-support.sh --include-private --outdir <directory> --ignore-disk-space</pre>
  The script includes the following options:
 
  - `--include-private`: Includes files containing private values in the log bundle
  -  `--outdir <directory>`: Directory to store the resulting log bundle
  -  `--ignore-disk-space`:  Ignore low disk space warnings for log bundle output`

  Running this script creates a log bundle, `/storage/log/vic_appliance_logs_YYYY-MM-DD-00-01-00.tar.gz`, that you can supply to VMware support. This bundle includes the installation logs.

3. To see the startup logs for each of the vSphere Integrated Containers components, run the `journalctl` command.

   - vSphere Integrated Containers Registry:<pre>journalctl -u harbor</pre>
   - `vic-machine-server` service:<pre>journalctl -u vic-machine-server</pre>
   - vSphere Integrated Containers Management Portal:<pre>journalctl -u admiral</pre>

**Configuring Log Retention**
1. To configure log retention for the registry services, edit the `/storage/data/harbor/harbor.cfg` file.<pre>$ vi /storage/data/harbor/harbor.cfg</pre>The default configuration allows 50 files, up to 200MB each per service.
	1. To set the maximum number of files used for storing logs per service, change the `log_rotate_count` property value to the desired number.
	2. To set the maximum size in MB per file, change the `log_rotate_size` property value to the desired number.
2. To configure log retention for the `vic-machine-server` service, edit the `/etc/logrotate.d/vic-machine-server` file.

    The default configuration allows 10 files, up to 1GB each.
    <pre>$ vi /etc/logrotate.d/vic-machine-server</pre> 

	1. To set the maximum number of files used for storing logs, change the `rotate` property value to the desired number.
	2. To set the maximum size in GB per file, change the `size` property value to the desired number.
3. To configure log retention for the management portal, edit the `/etc/vmware/admiral/logging-vic.properties` file.

   The default configuration allows 5 files, up to 1GB each.
    <pre>$ vi /etc/vmware/admiral/logging-vic.properties</pre>

	1. To set the maximum number of files used for storing logs, change the `java.util.logging.FileHandler.count` property value to the desired number.
	2. To set the maximum size in bytes per file, change the `java.util.logging.FileHandler.limit` property value to the desired number.

**Log File Location**

Depending on the component, navigate to the following locations to access the log files:
<table width="100%" border="1">
        <tr>
          <th width="20%" scope="col">Component</th>
          <th width="30%" scope="col">Location</th>
          <th width="50%" scope=:col">Log Files</th>
 </tr>
<tr>
<td>Applliance </td>
<td> <code>/var/log/vmware</code></td>
<td> <code>/upgrade.log</code></td>
</tr>
<tr>
<td>vSphere Integrated Containers Registry </td>
<td> <code>/storage/log/harbor</code></td>
<td><p> <code>adminserver.log</code>: Registry administration service</p>
<p><code>clair-db.log</code>: Clair database used for vulnerability scanning of images</p>
<p><code>clair.log</code>: Clair service used for vulnerability scanning of images</p>
<p><code>jobservice.log</code>: Registry job service log</p>
<p><code>mysql.log</code>: Embedded registry database</p>
<p><code>notary-db.log</code>: Notary database by Docker Content Trust</p>
<p><code>notary-server.log</code>: Notary server used by Docker Content Trust</p>
<p><code>notary-signer.log</code>: Notary image signing service used by Docker Content Trust</p>
<p><code>proxy.log</code>: Proxy service logs</p>
<p><code>registry.log</code>: Registry service logs</p>
<p><code>ui.log</code>: User interface logs</p>
</td>
</tr><tr>
<td> <code>vic-machine-server</code> service</td>
<td><code>/storage/log/vic-machine-server</code></td>
<td><code>vic-machine-server.log</code></td>
</tr><tr>
<td>vSphere Integrated Containers Management Portal</td>
<td><code>storage/log/admiral</code></td>
<td> <code>xenonHost.0.log</code></td>
</tr>    </table>