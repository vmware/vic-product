# vSphere Integrated Containers Security Reference
The Security Reference provides information to allow you to secure your vSphere Integrated Containers implementation.

- [Network Security](#network)
- [External Interfaces, Ports, and Services](#open_ports)
- [Service Accounts and Privileges](#accounts)
- [Apply Security Updates and Patches](#patches)
- [Security Related Log Messages](#logs)
- [Sensitive Data](#data)


## Network Security <a id="network"></a>
VMware highly recommends using a secure management network for vSphere Integrated Containers Engine. Container VMs communicate with the virtual container host (VCH) endpoint VM over the management network when an interactive shell is required. While the communication is encrypted, the public keys are not validated, which leaves scope for man-in-the-middle attacks. This connection is only used when the interactive console is enabled (stdin/out/err), and not for any other purpose.

All connections to vSphere Integrated Containers Management Portal and Registry are encrypted and secured by HTTPS.

## External Interfaces, Ports, and Services <a id="open_ports"></a>

The following ports must be open on the vSphere Integrated Containers appliance, VCH endpoint VMs, and container VMs:

### vSphere Integrated Containers Appliance

The vSphere Integrated Containers appliance makes the core vSphere Integrated Containers services available.

|Port|Protocol|Description|
|---|---|---|
|443|HTTPS|Connections to vSphere Integrated Containers Registry from vSphere Integrated Containers Management Portal, VCHs, and Docker clients|
|1337|HTTPS|Connections to the Demo VCH Installer|
|4443|HTTPS|Connections to the Docker Content Trust service for vSphere Integrated Containers Registry|
|8282|HTTPS|Connections to vSphere Integrated Containers Management Portal UI and API|
|9443|HTTPS|Connections to the appliance intialization and Getting Started page, vSphere Integrated Containers Engine download, and vSphere Client plug-in installer|

### VCH Endpoint VM

The different network interfaces on a VCH expose different services on different ports. For an overview of the different network interfaces on a VCH, see [Virtual Container Host Networking](vch_networking.md).


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
|22|SSH|Connections to the VCH when using `vic-machine debug --enable-ssh`|
|2375|HTTP|Insecure port for Docker API access if VCH is deployed with `--no-tls`|
|2376|HTTPS|Secure port for Docker API access if VCH is not deployed with `--no-tls`|
|2378|HTTPS|Connections to the VCH Administration Portal server|
|6060|HTTPS|Exposes `pprof` debug data about the VCH if the VCH is running with `vic-machine create --debug` or `vic-machine configure --debug` enabled|

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

## Service Accounts and Privileges <a id="accounts"></a>
vSphere Integrated Containers does not create service accounts and does not assign any vSphere privileges. The vSphere Integrated Containers appliance uses vCenter Single Sign-On user accounts to manage user authentication. You can optionally create example Single Sign-On user accounts for vSphere Integrated Containers Management Portal when you deploy the appliance. For information about the example user accounts, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md) and [User Authentication](../vic_overview/introduction.html#authentication).

The `vic-machine create --ops-user` and `--ops-password` options allow a VCH to operate with less-privileged credentials than those that are required for deploying a new VCH. For information about the `--ops-user` option and the permissions that it requires, see the descriptions of `--ops-user` in [VCH Deployment Options](vch_installer_options.md#ops-user) and [Advanced Examples of Deploying a VCH](vch_installer_examples.md#ops-user), and the section [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

## Security Updates and Patches <a id="patches"></a>
Download a new version of vSphere Integrated Containers and upgrade your existing appliances, vSphere Client plug-ins, and VCHs. For information about installing security patches, see [Upgrading vSphere Integrated Containers](upgrading_vic.md).

## Security Related Log Messages <a id="logs"></a>
Security-related information for vSphere Integrated Containers Engine appears in `docker-personality.log` and `vicadmin.log`, that you can access from the VCH Admin portal for a VCH. For information about accessing VCH logs, see [Access Virtual Container Host Log Bundles](log_bundles.md).

There are no specific security-related logs for the vSphere Integrated Containers appliance. To access logs for the appliance, see [Access vSphere Integrated Containers Appliance Logs](appliance_logs.md).

## Sensitive Data <a id="data"></a>

The VMX file of the VCH endpoint VM stores vSphere Integrated Containers Engine configuration information, which allows most of the configuration to be read-only by the guest. The container VMs might hold sensitive application data, such as environment variables for processes, command arguments, and so on.

vSphere Integrated Containers Management Portal securely stores the credentials for access to VCHs, Docker hosts, and registries. Any private elements of those credentials, such as passwords or private keys, are kept encrypted in the vSphere Integrated Containers Management Portal data store.