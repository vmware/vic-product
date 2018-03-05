# General Virtual Container Host Settings #

When you deploy a virtual container host (VCH), you can configure a name for the VCH, a naming convention for container VMs, and debugging levels. 

- [Options](#options)
  - [VCH Name](#name)
  - [Container VM Name Template](#container-name-convention)
  - [Debug](#debug)
  - [Syslog](#syslog)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Commands](#examples)
  - [Set a Container Name Convention](#convention) 
  - [Configure Debugging and Sylog on a VCH](#syslog)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the General Settings page of the Create Virtual Container Host wizard and to the  corresponding `vic-machine create` options.

### VCH Name <a id="name"></a>

A name for the VCH, that appears the vCenter Server inventory and that you can use in other `vic-machine` commands. The default VCH name is `virtual-container-host`. If a VCH of the same name already exists, or if the name you provide contains unsupported characters, the wizard reports an error and you cannot progress to the next page, or `vic-machine create` fails with an error.

#### Create VCH Wizard

Enter a name for the VCH. 

#### vic-machine Option

`--name`, `-n`

If a folder of the same name exists in the target datastore, `vic-machine create` creates a folder named <code><i>vch_name</i>_1</code>. 

<pre>--name <i>vch_name</i></pre>

### Container VM Name Template <a id="container-name-convention"></a>

Enforce a naming convention for container VMs, that applies a prefix or suffix to the names of all container VMs that run in the VCH. Applying a naming convention to container VMs facilitates organizational requirements such as chargeback. The container naming convention applies to the display name of the container VM that appears in the vSphere Client, not to the container name that Docker uses. 

You specify whether to use the container name or the container ID for the second part of the container VM display name. If you use the container name, the container VM display names use either the name that Docker generates for the container, or a name that the container developer specifies in `docker run --name` when they run the container.

#### Create VCH Wizard

1. Optionally enter a container name prefix.
2. Select **Docker name** or **Container ID**.
3. Optionally enter a container name suffix.

#### vic-machine Option

`--container-name-convention`, `--cnc`

Specify a prefix and/or suffix to apply to container names, and add `{name}` or `{id}`, including the curly brackets, to specify whether to use the container name or the container ID for the second part of the container VM display name. 

<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}</pre>
<pre>--container-name-convention {id}-<i>cVM_name_suffix</i></pre>
<pre>--container-name-convention <i>cVM_name_prefix</i>-{name}<i>cVM_name_suffix</i></pre>

### Debug <a id="debug"></a>

Deploy the VCH with more verbose levels of logging, and optionally modify the behavior of `vic-machine` for troubleshooting purposes. Specifying a debug level of greater than 0 increases the verbosity of the logging for all aspects of VCH operation, not just deployment. For example, by setting a higher debug level, you increase the verbosity of the logging for VCH initialization, VCH services, container VM initialization, and so on. 

**NOTE**: Do not confuse the `vic-machine create --debug` option with the `vic-machine debug` command, that enables access to the VCH endpoint VM. For information about `vic-machine debug`, see [Debug Running Virtual Container Hosts](debug_vch.md). 

You can set a debugging level of 1, 2, or 3. Setting level 2 or 3 changes the behavior of `vic-machine create` as well as increasing the level of verbosity of the logs:

- `1` Provides verbosity in the logs, with no other changes to `vic-machine` behavior. This is the default setting.
- `2` Exposes servers on more interfaces, launches `pprof` in container VMs.
- `3` Disables recovery logic and logs sensitive data. Disables the restart of failed components and prevents container VMs from shutting down. Logs environment details for user application, and collects application output in the log bundle.

Additionally, deploying a VCH with debug level 3 enables SSH access to the VCH endpoint VM console by default, with a root password of `password`, without requiring you to run the `vic-machine debug` command. This functionality enables you to perform targeted interactive diagnostics in environments in which a VCH endpoint VM failure occurs consistently and in a fashion that prevents `vic-machine debug` from functioning.

**IMPORTANT**: There is no provision for persistently changing the default root password. Only use this configuration for debugging in a secured environment.

#### Create VCH Wizard

- Leave the default level of 0 for usual deployments. 
- Optionally select level 1, 2, or 3 if you need to debug deployment problems.

**NOTE**: When you use the wizard to deploy a VCH, deployment logging is always verbose. The settings that you apply in the wizard apply to post-deployment operation logging.   

#### vic-machine Option

`--debug`, `-v`

Optionally specify a debugging level of `1`, `2`, or `3`. If not specified, the debug level is set to 0 and verbose logging is disabled.

<pre>--debug 3</pre>

### Syslog <a id="syslog"></a>

Configure a VCH so that it sends the logs in the `/var/log/vic` folder on the VCH endpoint VM to a syslog endpoint that is not located in the VCH. The VCH also sends container logs to the same syslog endpoint.

#### Create VCH Wizard

1. Select **tcp** or **udp** for the transport protocol.
2. Enter the IP address or FQDN of the syslog endpoint.
3. Optionally enter the port on which with syslog endpoint is exposed if it is not the default of 514. 

#### vic-machine Option

`--syslog-address`, no short name

Specify the address and port of the syslog endpoint. You must also specify whether the transport protocol is UDP or TCP. If you do not specify a port, the default port is 514. 

<pre>--syslog-address udp://<i>syslog_host_address</i>:<i>port</i></pre>
<pre>--syslog-address tcp://<i>syslog_host_address</i>:<i>port</i></pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to go to the [Compute Capacity](vch_compute.md) settings.

## Example `vic-machine` Commands <a id="examples"></a>

The following examples show `vic-machine create` commands that use the options described in this topic. For simplicity, the examples all use the `--no-tlsverify` option to automatically generate server certificates but disable client authentication. The examples use an existing port group named `vch1-bridge` for the bridge network and designate `datastore1` as the image store, and deploy the VCH to `cluster1` in datacenter `dc1`. 

### Set a Container Name Convention <a id="convention"></a>

This example `vic-machine create` command deploys a VCH that specifies `--container-name-convention` so that the vCenter Server  display names of all container VMs include the prefix `vch1-container` followed by the container name.

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

### Configure Debugging and Sylog on a VCH <a id="syslog"></a>

This example `vic-machine create` command deploys a VCH that sets the deployment debugging level to 3 and sends logs to an external syslog endpoint.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>vcenter_server_certificate_thumbprint</i>
--no-tlsverify
--debug 3
--syslog-address tcp://<i>syslog_host_address</i>
</pre>