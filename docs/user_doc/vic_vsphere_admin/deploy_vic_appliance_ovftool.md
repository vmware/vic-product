# Deploy the vSphere Integrated Containers Appliance Using VMware OVF Tool #

You can deploy the vSphere Integrated Containers Appliance using the VMware OVF Tool. 

The vSphere Integrated Containers Engine bundle includes the `OVA-util` utility. The `OVA-util` utility is a command-line utility that allows you to import and export OVF packages. This utility contains the `ovftool` command that you can use to deploy the vSphere Integrated Containers Appliance at the command line.

* [Prerequisites](#prerequisites)
* [Running the `ovftool` Command](#running-the-ovftool-command)
* [Specifying Option Arguments](#specifying-option-arguments)
* [Basic `ovftool` Options](#basic-ovftool-options)
* [Advanced `ovftool` Options](#advanced-ovftool-options)
* [Example `ovftool` Command](#example-ovftool-command)

## Prerequisites

Download the VMware OVF Tool from [https://code.vmware.com/web/tool/4.3.0/ovf](https://code.vmware.com/web/tool/4.3.0/ovf).

## Running the `ovftool` Command 

You run `ovftool` by specifying the source locator, target locator, and options for the command. 

At the command-line prompt, run the command as follows: 

`ovftool <source locator> <target locator>`

If you are using an operating system where spaces are not allowed in paths on the command line, and need the full path to run OVF Tool, enclose the path in quotes as shown below:

`"/Applications/VMware OVF Tool/ovftool"`

The `<source locator>` can be one of the following:

- A path to an OVF or OVA file (a local file path, or an HTTP, HTTPS, or FTP URL).
- A virtual machine (a local file path to a .vmx file).
- A vSphere locator identifying a virtual machine or vApp on vCenter, ESXi, or VMware Server.

The target locator can be one of the following:

- A local file path for VMX, OVF, OVA, or vApprun workspace.
- A vSphere locator identifying a cluster, host, or a vSphere location

**Example**:

```
ovftool
[...]
${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}/%{TEST_RESOURCE}'
```

## Specifying Option Arguments

To specify additional options, type them before the source and target locators as follows:
`ovftool <options> <source locator> <target locator>`

Options perform actions only between certain source and target types. If you specify an option using an irrelevant source or target type, the command does nothing.

All options can be set as follows:

`--option=value`

**Example**:

`--net:"Network"="%{PUBLIC_NETWORK}"`

Binary options can be enabled or disabled explicitly. For example: `--option=true`, `--option=false`.

## Basic `ovftool` Options

This section lists some of the basic `ovftool` options. You can set environment variables so that you do not have to specify the `<source locator>`, `<target locator>`, `--datastore`, `--name`, `--net`, and `--prop` options in every `ovftool` command. 

### `--datastore`

**Short name**: `-ds`

Target datastore name for a vSphere locator. 

**Usage**

<pre>datastore=<i>datastore name</i></pre>

**Example**: `--datastore='%{TEST_DATASTORE}'`

### `--noSSLVerify`

**Short name**: None

Skips SSL verification for vSphere connections. 

**Usage**

<pre>--noSSLVerify</pre>

### `--acceptAllEulas`

Accepts all end-user licenses agreements (EULAS) without being prompted.  

### `--name`

**Short name**: `-n`

The target name. If you do not specify name, the name defaults to the source name.

**Usage**

<pre>--name=<i>OVA name</i></pre>

### `--diskMode`

**Short name**: `-dm`

Specify the disk format. You can specify the following formats: `monolithicSparse`, `monolithicFlat`, `twoGbMaxExtentSparse`,
`twoGbMaxExtentFlat`, `seSparse` (vSphere target),
`eagerZeroedThick` (vSphere target), `thin` (vSphere target), `thick`
(vSphere target), `sparse`, and `flat`.

**Usage**

<pre>--diskmode=<i>format</i></pre>

**Example**: `--diskMode=thin`

### `--help`

**Short name**: `-h`

Prints the OVF Tool help message that lists the `--help` options.

**Usage**

<pre>--help</pre>

### `--powerOn`

**Short name**: None

Powers on a virtual machine that is deployed on a vSphere target. 

**Usage**

<pre>--powerOn</pre>

### `--net`

**Short name**: None

Sets a network assignment in the deployed OVF package. 

**Usage**

<pre>--net:<i>OVF name=target name</i></pre>

**Example**: `--net:"Network"="%{PUBLIC_NETWORK}"`

### `--prop`

**Short name**: None

Sets a property in the deployed OVF package. 

**Usage**

<pre>--prop:<i>key=value<i></pre>

For multiple property mappings, repeat the option by separating them with a blank as follows: 

<pre>--prop:<i>key1=value1</i>&nbsp--prop:<i>key2=value2</i>&nbsp--prop:<i>key3=value3</i></pre>

**Examples**:

    ```
    --prop:appliance.root_pwd='${OVA_PASSWORD_ROOT}'
    --prop:appliance.permit_root_login=True
    --prop:appliance.tls_cert="${tls_cert}"
    --prop:appliance.tls_cert_key="${tls_cert_key}"
    --prop:appliance.ca_cert="${ca_cert}" 
    --prop:network.ip0="${static-ip}"
    --prop:network.netmask0="${netmask}" 
    --prop:network.gateway="${gateway}" 
    --prop:network.DNS="${dns}" 
    --prop:network.searchpath="${searchpath}" 
    --prop:network.fqdn="${fqdn}"
    --prop:syslog_server.syslog_srv_host="${syslog_srv_host}"
    --prop:syslog_server.syslog_srv_protocol="${syslog_srv_protocol}"
    --prop:syslog_server.syslog_srv_port="${syslog_srv_port}" --
    ```

## Advanced `ovftool` Options

This section lists some of the advanced `ovftool` options.

### `--X:waitForIp`

Waits for VMware tools to return an IP address and print it out. This option must be used together with the `--powerOn` option of the VI target and a single VM source.

**Usage**:

<pre>--powerOn --X:waitForIp</pre>

**Example**:

```
ovftool 
[...]
--powerOn --X:waitForIp
[...]
${ova-file} 'vi://%{TEST_USERNAME}:%{TEST_PASSWORD}@%{TEST_URL}/%{TEST_RESOURCE}'
```

### `--X:injectOvfEnv` 

If you are running `ovftool` on an ESXi host, you must “inject” the parameters into the resulting VM when it is powered on. This is because the ESXi host lacks a cache to store the OVF parameters, as in vCenter Server. Therefore, you must use the `--X:injectOvfEnv` debug option with the `--powerOn` flag in the command line if you are deploying a virtual machine from ESXi.

**Usage**:

<pre>--X:injectOvfEnv --powerOn</pre>

**Example**:

```
ovftool 
[...]
--X:injectOvfEnv 
[...]
--powerOn
[...]
```

### `--X:enableHiddenProperties`

Enables source properties that are marked as `ovf:userConfigurable=false`. Use this option to set the values to `true`. By default, the OVF Tool sets them as `false`.

**Usage**:

<pre>--X:enableHiddenProperties</pre>

### `--X:logFile`

Logs internal events to given log file.

**Usage**:

<pre>--X:logFile=<i>log-file-name<i></pre> 

**Example**: 

`--X:logFile=ovftool-log.txt`

### `--X:logLevel`	

Indicates the log level. Specify one of the following values: `none`, `quiet`,  `panic`, `error`, `warning`, `info`, `verbose`, `trivia`.

**Usage**:

<pre>--X:logLevel=<i>level</i></pre>

**Example**:

<pre>--X:logLevel=verbose</pre>

### `--X:logToConsole`

Log internal events to console.

**Usage**:

<pre>--X:logToConsole</pre>

### `--X:logTransferHeaderData`

Add transfer header data to the log. Use this option with care. The default value is `false`.

**Usage**:

<pre>--X:logTransferHeaderData</pre>

## Example `ovftool` Command

The following command sets the appliance root password and uses the default values for other options:

    ovftool --datastore=vsanDatastore --noSSLVerify --acceptAllEulas --name=<vch_name> --diskMode=thin --powerOn --X:waitForIp --X:injectOvfEnv --X:enableHiddenProperties --prop:appliance.root_pwd=<root_pwd>' --prop:appliance.permit_root_login=True --net:"Network"="vm-network" installer/bin/vic-*.ova 'vi://<vc_username>:<vc_pwd>@10.160.222.221/vcqaDC/host/cls' 2>&1
    

For more information about the VMware OVF Tool and how to use it, see the [OVF Tool Documentation](https://www.vmware.com/support/developer/ovf/).

The following sources also provide useful information:

- [OVF Tool Advanced Options](https://www.virtuallyghetto.com/2014/07/quick-tip-handy-ovftool-4-0-advanced-options.html)
- [Deploying vSphere Integrated Containers with the OVF Tool](https://virsed.net/2017/08/11/deploying-vsphere-integrated-containers-with-the-ovf-tool/)
