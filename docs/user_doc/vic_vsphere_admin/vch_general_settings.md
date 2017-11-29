# General Virtual Container Host Settings #

When you deploy a virtual container host (VCH), you can configure a name for the VCH, a naming convention for container VMs, and debugging levels. 

The sections in this topic each correspond to an entry in the General Settings page of the Create Virtual Container Host wizard and to the  corresponding `vic-machine create` options.

- [VCH Name](#name)
- [Container VM Name Template](#container-name-convention)
- [Debug](#debug)
- [Syslog](#syslog)
- [Example `vic-machine` Commands](#examples)

## VCH Name <a id="name"></a>

A name for the VCH, that appears the vCenter Server inventory and that you can use in other `vic-machine` commands. The default VCH name is `virtual-container-host`.

**Create VCH Wizard**

Enter a name for the VCH. 

**vic-machine Option**

`--name`, `-n`

If a VCH of the same name exists on the ESXi host or in the vCenter Server inventory, `vic-machine create` fails with an error. If a folder of the same name exists in the target datastore, `vic-machine create` creates a folder named <code><i>vch_name</i>_1</code>. If the name that you provide contains unsupported characters, `vic-machine create` fails with an error.

<pre>--name <i>vch_name</i></pre>

## Container VM name template <a id="container-name-convention"></a>

Enforce a naming convention for container VMs, that applies a prefix or suffix to the names of all container VMs that run in the VCH. Applying a naming convention to container VMs facilitates organizational requirements such as chargeback. The container naming convention applies to the display name of the container VM that appears in the vSphere Client, not to the container name that Docker uses. 

You specify whether to use the container name or the container ID for the second part of the container VM display name. If you use the container name, the container VM display names use either the name that Docker generates for the container, or a name that the container developer specifies in `docker run --name` when they run the container.

**Create VCH Wizard**

Optionally enter a prefix, select **Docker name** or **Container ID**, and optionally add a suffix.

**vic-machine Option**

`--container-name-convention`, `--cnc`

You specify the container naming convention by providing a prefix and/or suffix to apply to container names, and adding `-{name}` or `-{id}` to specify whether to use the container name or the container ID for the second part of the container VM display name. 

<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}</pre>
<pre>--container-name-convention {id}-<i>cVM_name_suffix</i></pre>
<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}<i>cVM_name_suffix</i></pre>

## Debug <a id="debug"></a>

Deploy the VCH with more verbose levels of logging, and optionally modify the behavior of `vic-machine` for troubleshooting purposes. Specifying a debug level of greater than 0 increases the verbosity of the logging for all aspects of VCH operation, not just deployment. For example, by setting a higher debug level, you increase the verbosity of the logging for VCH initialization, VCH services, container VM initialization, and so on. 

You can set a debugging level of 1, 2, or 3. Setting level 2 or 3 changes the behavior of `vic-machine create` as well as increasing the level of verbosity of the logs:

- `1` Provides verbosity in the logs, with no other changes to `vic-machine` behavior. This is the default setting.
- `2` Exposes servers on more interfaces, launches `pprof` in container VMs.
- `3` Disables recovery logic and logs sensitive data. Disables the restart of failed components and prevents container VMs from shutting down. Logs environment details for user application, and collects application output in the log bundle.

Additionally, deploying a VCH with debug level 3 enables SSH access to the VCH endpoint VM console by default, with a root password of `password`, without requiring you to run the `vic-machine debug` command. This functionality enables you to perform targeted interactive diagnostics in environments in which a VCH endpoint VM failure occurs consistently and in a fashion that prevents `vic-machine debug` from functioning. 

**IMPORTANT**: There is no provision for persistently changing the default root password. Only use this configuration for debugging in a secured environment.

**Create VCH Wizard**

Leave the default level of 0 for usual deployments. Optionally select level 1, 2, or 3 if you need to debug deployment problems.

**vic-machine Option**

`--debug`, `-v`

If not specified, the debug level is set to 0 and verbose logging is disabled.

**NOTE**: Do not confuse the `vic-machine create --debug` option with the `vic-machine debug` command, that enables access to the VCH endpoint VM. For information about `vic-machine debug`, see [Debugging the VCH](debug_vch.md). 

<pre>--debug 3</pre>

## Syslog <a id="syslog"></a>

Configure a VCH so that it sends the logs in the `/var/log/vic` folder on the VCH endpoint VM to a syslog endpoint that is not located in the VCH. The VCH also sends container logs to the same syslog endpoint.

**Create VCH Wizard**

Select **tcp** or **udp** for the transport protocol, enter the IP address or FQDN of the syslog endpoint, and optionally enter the port on which with syslog endpoint is exposed if it is not the default of 514. 

**vic-machine Option**

`--syslog-address`, no short name

Specify the address and port of the syslog endpoint in the `--syslog-address` option. You must also specify whether the transport protocol is UDP or TCP. If you do not specify a port, the default port is 514. 

<pre>--syslog-address udp://<i>syslog_host_address</i>[:<i>port</i>]</pre>
<pre>--syslog-address tcp://<i>syslog_host_address</i>[:<i>port</i>]</pre>

## Example `vic-machine` Commands <a id="examples"></a>

### Set a Container Name Convention <a id="convention"></a>

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates `datastore1` as the image store. 
- Specifies `--container-name-convention` so that the vCenter Server  display names of all container VMs that run in this VCH include the prefix `vch1-container` followed by the container name.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--container-name-convention vch1-container-{name}
</pre>

### Configure Debugging and Sylog on a VCH

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Sets the deployment debugging level to 3.
- Bypasses certain checks and errors by setting the `--force` option. 
- Increases the timeout for `vic-machine create` operations to 15 minutes.
- Sends logs to an external syslog endpoint.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch_registry
--thumbprint <i>vcenter_server_certificate_thumbprint</i>
--no-tlsverify
--debug 3
--force
--timeout 15m0s
--syslog-address tcp://<i>syslog_host_address</i>
</pre>