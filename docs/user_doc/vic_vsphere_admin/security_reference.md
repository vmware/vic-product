# vSphere Integrated Containers Security Reference
The Security Reference provides information to allow you to secure your vSphere Integrated Containers implementation.

- [Service Accounts, Privileges, and User Authentication](#accounts)
- [Network Security](#network)
- [External Interfaces, Ports, and Services](#open_ports)
- [Apply Security Updates and Patches](#patches)
- [Security Related Log Messages](#logs)
- [Sensitive Data](#data)
- [Certificates](#certs)

## Service Accounts, Privileges, and User Authentication <a id="accounts"></a>
vSphere Integrated Containers does not create service accounts and does not assign any vSphere privileges. The vSphere Integrated Containers appliance uses vCenter Single Sign-On user accounts to manage user authentication. You can optionally create example Single Sign-On user accounts for vSphere Integrated Containers Management Portal when you deploy the appliance. For information about the example user accounts, see [User Authentication](../vic_overview/intro_to_vic_mp.md#authentication) and [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

### Appliance Authentication with vSphere

The appliance uses a single TLS certificate for all of the services that run in the appliance.

For information about how vSphere Integrated Containers uses certificates, see the [vSphere Integrated Containers Appliance Certificate Requirements](vic_cert_reqs.md).

### VCH Authentication with vSphere

Using `vic-machine` to deploy and manage virtual container hosts (VCHs) requires a user account with vSphere administrator privileges. The `vic-machine create --ops-user` and `--ops-password` options allow a VCH to operate with less-privileged credentials than those that are required to deploy a new VCH. For information about the `--ops-user` option and the permissions that it requires, see [Configure the Operations User](set_up_ops_user.md).

When deploying VCHs, you must provide the certificate thumbprint of the vCenter Server or ESXi host on which you are deploying the VCH. For information about how to obtain and verify vSphere certificate thumbprints, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md). Be aware that it is possible to use the `--force` option to run `vic-machine` commands that bypass vSphere certificate verification. For information about the `--force` option, see [`--force`](running_vicmachine_cmds.md#force) in the topic on running `vic-machine` commands.

### Docker Client and Management Portal Authentication with VCHs

VCHs authenticate Docker API clients and vSphere Integrated Containers Management Portal by using client certificates. For information about VCHs and client authentication, see the [Virtual Container Host Certificate Requirements](vch_cert_reqs.md). Be aware that it is possible to use the `--no-tlsverify` and `--no-tls` options to deploy VCHs that do not authenticate client connections. For information about the `--no-tlsverify` and `--no-tls` options, see [Disable Certificate Authentication](tls_unrestricted.md).

## Network Security <a id="network"></a>

All connections to vSphere Integrated Containers Management Portal and Registry are encrypted and secured by HTTPS. 

VMware highly recommends using a secure network for the VCH management network. For more information about connections to VCHs in general and the management network in particular, see [Virtual Container Host Networks](vch_networking.md) and [Configure the Management Network](mgmt_network.md).

## External Interfaces, Ports, and Services <a id="open_ports"></a>

The following ports must be open on the vSphere Integrated Containers appliance, VCH endpoint VMs, and container VMs:

### ESXi Hosts

ESXi hosts must have the following firewall configuration for VCH deployment:

- Allow outbound TCP traffic to port 2377 on the endpoint VM, for use by the interactive container shell.
- Allow inbound HTTPS/TCP traffic on port 443, for uploading to and downloading from datastores.

For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

### vSphere Integrated Containers Appliance

The vSphere Integrated Containers appliance makes the core vSphere Integrated Containers services available.

|Port|Protocol|Description|
|---|---|---|
|443|HTTPS|Connections to vSphere Integrated Containers Registry from vSphere Integrated Containers Management Portal, VCHs, and Docker clients|
|4443|HTTPS|Connections to the Docker Content Trust service for vSphere Integrated Containers Registry|
|8282|HTTPS|Connections to vSphere Integrated Containers Management Portal UI and API|
|8443|HTTPS|Connections to the `vic-machine-server` service, that powers the Create Virtual Container Host wizard in the HTML5 vSphere Client plug-in|
|9443|HTTPS|Connections to the appliance intialization and Getting Started page, vSphere Integrated Containers Engine download, and vSphere Client plug-in installer|

### VCH Endpoint VM

The different network interfaces on a VCH expose different services on different ports. For an overview of the different network interfaces on a VCH, see [Virtual Container Host Networks](vch_networking.md).


#### Public Interface

Container developers can forward any VCH port that is not used elsewhere to a container VM. For more information about the VCH public interface, see [Configure the Public Network](public_network.md).

#### Bridge Interface

For information about the VCH bridge interface, see [Configure Bridge Networks](bridge_network.md).

|Port|Protocol|Description|
|---|---|---|
|53|TCP|Connections from the VCH to DNS servers for container name resolution|

#### Client Interface

For information about the VCH client interface, see [Configure the Client Network](client_network.md). 

|Port|Protocol|Description|
|---|---|---|
|22|SSH|Connections to the VCH when using `vic-machine debug --enable-ssh` or `vic-machine create/configure --debug 3`.|
|2375|HTTP|Insecure port for Docker API access if VCH is deployed with `--no-tls`|
|2376|HTTPS|Secure port for Docker API access if VCH is not deployed with `--no-tls`|
|2378|HTTPS|Connections to the VCH Administration Portal server|
|6060|HTTPS|Exposes `pprof` debug data about the VCH if the VCH is running with `vic-machine create --debug` or `vic-machine configure --debug` enabled|

For information about VCH TLS options, see [Virtual Container Host Security](vch_security.md). For information about how debugging VCHs affects VCH behavior, see , see [Debug](vch_general_settings.md#debug) in the topic on configuring general VCH settings and [Debug Running Virtual Container Hosts](debug_vch.md).

#### Management Interface

For information about the VCH management interface, see [Configure the Management Network](mgmt_network.md).

|Port|Protocol|Description|
|---|---|---|
|443|HTTPS|Outgoing connections from the VCH to vCenter Server and ESXi hosts|
|2377|HTTPS|Incoming connections from container VMs to the VCH|

### Container VMs

If container developers do not explicitly expose ports, container VMs do not expose any ports if they are not running in debug mode.

|Port|Protocol|Description|
|---|---|---|
|6060|HTTPS|Exposes `pprof` debug data about a container VM when a VCH is running with `vic-machine create --debug` enabled|

## Security Updates and Patches <a id="patches"></a>
Download a new version of vSphere Integrated Containers and upgrade your existing appliances, vSphere Client plug-ins, and VCHs. For information about installing security patches, see [Upgrading vSphere Integrated Containers](upgrading_vic.md).

## Security Related Log Messages <a id="logs"></a>
Security-related information for vSphere Integrated Containers Engine appears in `docker-personality.log` and `vicadmin.log`, that you can access from the VCH Admin portal for a VCH. For information about accessing VCH logs, see [Access Virtual Container Host Log Bundles](log_bundles.md).

There are no specific security-related logs for the vSphere Integrated Containers appliance. To access logs for the appliance, see [Access vSphere Integrated Containers Appliance Logs](appliance_logs.md).

## Sensitive Data <a id="data"></a>

The VMX file of the VCH endpoint VM stores vSphere Integrated Containers Engine configuration information, which allows most of the configuration to be read-only by the guest. The container VMs might hold sensitive application data, such as environment variables for processes, command arguments, and so on.

vSphere Integrated Containers Management Portal securely stores the credentials for access to VCHs, Docker hosts, and registries. Any private elements of those credentials, such as passwords or private keys, are kept encrypted in the vSphere Integrated Containers Management Portal data store.