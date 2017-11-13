# Debugging Virtual Container Host Deployment #

If you experience problems when deploying virtual container hosts (VCHs), you can specify additional `vic-machine create` options to help you to debug the deployment. You can also configure a VCH so that it sends its logs to an external syslog endpoint. 

- [`vic-machine` Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

You debug VCH deployment by using the [`--debug`](#debug), [`--force`](#insecure-registry), and [`--timeout`](#timeout) options. You configure an external syslog endpoint by using the [`--syslog-address`](#syslog) option.

### `--debug` <a id="debug"></a>

**Short name**: `-v`

Deploy the VCH with more verbose levels of logging, and optionally modify the behavior of `vic-machine` for troubleshooting purposes. Specifying the `--debug` option increases the verbosity of the logging for all aspects of VCH operation, not just deployment. For example, by setting the `--debug` option, you increase the verbosity of the logging for VCH initialization, VCH services, container VM initialization, and so on. If not specified, the `--debug` value is set to 0 and verbose logging is disabled.

**NOTE**: Do not confuse the `vic-machine create --debug` option with the `vic-machine debug` command, that enables access to the VCH endpoint VM. For information about `vic-machine debug`, see [Debugging the VCH](debug_vch.md). 

When you specify `vic-machine create --debug`, you set a debugging level of 1, 2, or 3. Setting `--debug` to 2 or 3 changes the behavior of `vic-machine create` as well as increasing the level of verbosity of the logs:

- `--debug 1` Provides verbosity in the logs, with no other changes to `vic-machine` behavior. This is the default setting.
- `--debug 2` Exposes servers on more interfaces, launches `pprof` in container VMs.
- `--debug 3` Disables recovery logic and logs sensitive data. Disables the restart of failed components and prevents container VMs from shutting down. Logs environment details for user application, and collects application output in the log bundle.

Additionally, deploying a VCH with a `--debug 3` enables SSH access to the VCH endpoint VM console by default, with a root password of `password`, without requiring you to run the `vic-machine debug` command. This functionality enables you to perform targeted interactive diagnostics in environments in which a VCH endpoint VM failure occurs consistently and in a fashion that prevents `vic-machine debug` from functioning. 

**IMPORTANT**: There is no provision for persistently changing the default root password. Only use this configuration for debugging in a secured environment.

**Usage**:

<pre>--debug 3</pre>

### `--force` <a id="force"></a>

Short name: `-f`

Forces `vic-machine create` to ignore warnings and non-fatal errors and continue with the deployment of a VCH. Errors such as an incorrect compute resource still cause the deployment to fail.

**CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments. 

**Usage**:

<pre>--force</pre>

### `--timeout` <a id="timeout"></a>

**Short name**: none

The timeout period for uploading the vSphere Integrated Containers Engine files and ISOs to the ESXi host, and for powering on the VCH. Specify a value in the format `XmYs` if the default timeout of 3m0s is insufficient. 

**Usage**:

<pre>--timeout 5m0s</pre> 

### `--syslog-address` <a id="syslog"></a>

**Short name**: None

Configure a VCH so that it sends the logs in the `/var/log/vic` folder on the VCH endpoint VM to a syslog endpoint that is not located in the VCH. The VCH also sends container logs to the same syslog endpoint.

You specify the address and port of the syslog endpoint in the `--syslog-address` option. You must also specify whether the transport protocol is UDP or TCP. If you do not specify a port, the default port is 514. 

**Usage**:

<pre>--syslog-address udp://<i>syslog_host_address</i>[:<i>port</i>]</pre>
<pre>--syslog-address tcp://<i>syslog_host_address</i>[:<i>port</i>]</pre>

## Example `vic-machine` Command <a id="example"></a>

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