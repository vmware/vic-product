# Configure Virtual Container Hosts #

You can configure certain settings on an existing virtual container host (VCH) by using the `vic-machine configure` command.

When you run `vic-machine configure`, you use the options described in [Common `vic-machine` Options](common_vic_options.md) to identify the VCH to configure. In addition to these options, the `vic-machine configure` command provides options that allow you to perform the following modifications on VCHs:

- [Update vCenter Server Credentials](#vccreds)
- [Update vCenter Server Certificates](#vccert)
- [Add or Update Registry Server Certificates](#registries)
- [Update Security Configuration](#tlscerts)
- [Add and Remove Volume Stores](#volumes)
- [Add and Remove DNS Servers](#dns)
- [Configure Container Network Settings](#containernet)
- [Add, Configure, or Reset Proxy Servers](#proxies)
- [Enable, Reset, and Disable Debug Mode](#debug)
- [Configure CPU and Memory Allocations](#cpumem)

To see the current configuration of a VCH before you configure it, and to check the new configuration,  run `vic-machine inspect config` before and after you run `vic-machine configure`. For information about running `vic-machine inspect config`, see [Obtain VCH Configuration Information](inspect_vch_config.md).

## Update vCenter Server Credentials <a id="vccreds"></a>

If the vCenter Server credentials change after the deployment of a VCH, you must update that VCH with the new credentials. The VCH will not function until you update the credentials. 

You provide the new vCenter Server credentials in the `vic-machine configure --ops-user` and `--ops-password` options. You use the `vic-machine configure --ops-user` and `--ops-password` options to update the credentials even if you did not specify the `vic-machine create --ops-user` and `--ops-password` options during the initial deployment of the VCH. If you did not specify `vic-machine create --ops-user` and `--ops-password` during the deployment of the VCH, by default the VCH uses the values from `vic-machine create --user` and `--password` for the `--ops-user` and `--ops-password` settings, and it uses these credentials for day-to-day, post-deployment operation. 

For example, if you specified `--user Administrator@vsphere.local` in the `vic-machine create` command, and you did not set the `vic-machine create --ops-user` and `--ops-password` options, the VCH automatically sets `--ops-user` to Administrator@vsphere.local and uses this account for post-deployment operations. Consequently, if the password for Administrator@vsphere.local changes, you must specify the `vic-machine configure --ops-user` and `--ops-password` options to update the password. This example specifies the `--user` and `--password` options to log into vCenter Server, and then specifies `--ops-user` and `--ops-password` to update those settings in the VCH. 

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_address</i>
    --user Administrator@vsphere.local
    --password <i>password</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --ops-user Administrator@vsphere.local
    --ops-password <i>new_password</i></pre>

You can also use the `vic-machine configure --ops-user` and `--ops-password` options to configure an operations user on a VCH that was not initially deployed with that option. Similarly, you can use `--ops-user` and `--ops-password` to change the operations user account on a VCH that was deployed with an operations user account, or to update the password for a previously specified operations user account. This example specifies the credentials to log into vCenter Server in the `--target` option, rather than in `--user` and `--password`.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --ops-user <i>new_operations_user_account</i>
    --ops-password <i>password</i></pre>

## Update vCenter Server Certificates <a id="vccert"></a>

If the vCenter Server certificate changes, you must update any VCHs running on that vCenter Server instance, otherwise they will no longer function.

To update the certificate, provide the new certificate thumbprint to the VCH in the `--thumbprint` option:

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --id <i>vch_id</i>
    --thumbprint <i>new_certificate_thumbprint</i></pre>

**NOTE**: If you run `vic-machine configure` with the `--force` option and you do not specify `--thumbprint`, `vic-machine` updates the thumbprint automatically.

## Add or Update Registry Server Certificates <a id="registries"></a>

If a VCH requires access to a new vSphere Integrated Containers Registry instance, or to another private registry, you can add new registry CA certificates by using the `vic-machine configure --registry-ca` option. You also use the `vic-machine configure --registry-ca` option if the certificate for an existing registry changes.

The `vic-machine configure --registry-ca` option functions in the same way as the equivalent `vic-machine create --registry-ca` option. For information about the `vic-machine create --registry-ca` option, see [Private Registry Options](vch_installer_options.md#registry) in VCH Deployment Options.

This example passes the CA certificate for a new registry to a VCH, and updates the certificate for a registry that this VCH already uses.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --registry-ca <i>path_to_ca_cert_for_new_registry</i>
    --registry-ca <i>path_to_new_ca_cert_for_existing_registry</i></pre>

**NOTE**: Unlike `vic-machine create`, the `vic-machine configure` command does not provide an `--insecure-registry` option.

## Update Security Configuration  <a id="tlscerts"></a>

You can configure the security settings of a VCH by using the different TLS options of the `vic-machine configure` command.

- To configure TLS authentication with automatically generated certificates on a VCH that currently implements no TLS authentication, or to regenerate automatically generated certificates, use the `vic-machine configure --tls-cname` option.
- To configure TLS authentication with custom certificates on a VCH that currently implements no TLS authentication, or that uses automatically generated certificates, or to replace existing custom certificates, use the `vic-machine configure --tls-server-cert` and `--tls-server-key` options. 
- To disable verification of client certificates, use the `vic-machine configure --no-tlsverify` option.
- To change the location in which to search for and store certificates, use the `vic-machine configure --tls-cert-path` option.

The `vic-machine configure` TLS options function in the same way as the equivalent `vic-machine create` options. For information about the `vic-machine create` security options, see [Security Options](vch_installer_options.md#security) in VCH Deployment Options.

**NOTE**: The `vic-machine configure` command does not include an equivalent to `vic-machine create --tls-ca` option.

This example  sets the `vic-machine configure --tls-cname` option to  implement TLS authentication with automatically generated server and client certificates. Before the configuration, the VCH either has no authentication or uses automatically generated certificates that you want to regenerate. The `--tls-cert-path` option specifies the folder in which to store the generated certificate.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --tls-cname *.example.com
    --tls-cert-path <i>path_to_cert_folder</i></pre>

This example  uses the `vic-machine configure --tls-server-cert` and `--tls-server-key` options to implement TLS authentication with custom certificates. Before the configuration, the VCH either has no TLS authentication, or it uses automatically generated certificates, or it uses custom certificates that require replacement. 

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --tls-server-cert <i>path_to_cert</i>/<i>certificate_name</i>.pem
    --tls-server-key <i>path_to_key</i>/<i>key_name</i>.pem</pre>

This example sets `--no-tlsverify` to disable the verification of client certificates on a VCH that implements client and server authentication.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --no-tlsverify</pre>

## Add and Remove Volume Stores <a id="volumes"></a>

Blah

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i></pre>

--volume-store value, --vs value                 Specify a list of location and label for volume store, nfs stores can have mount options specified as query parameters in the url target.
                                                Examples for a vsphere backed volume store are:  "datastore/path:label" or "datastore:label" or "ds://my-datastore-name:store-label"
                                                     Examples for nfs back volume stores are: "nfs://127.0.0.1/path/to/share/point?uid=1234&gid=5678&proto=tcp:my-volume-store-label" or "nfs://my-store/path/to/share/point:my-label"

## Add and Reset DNS Servers <a id="dns"></a>

If you deployed the VCH with a static IP address, you can add DNS servers or reset them to the default by using the `vic-machine configure --dns-server` option. 

The `vic-machine configure --dns-server` option functions in the same way as the equivalent `vic-machine create --dns-server` option. For information about the `vic-machine create --dns-server` option, see  [`--dns-server`](vch_installer_options.md#dns-server) in VCH Deployment Options.

This example adds a new DNS server to a VCH. If the VCH already uses a DNS server, the new DNS server replaces it. 

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --dns-server <i>dns_server_address</i></pre>

To reset the DNS servers on a VCH to their defaults of 8.8.8.8 and 8.8.4.4, set the `vic-machine configure --dns-server` option to `""`.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --dns-server ""</pre>

**NOTE**: The `vic-machine configure` command does not include options to set a static IP address on a VCH that uses DHCP.

## Configure Container Network Settings <a id="containernet"></a>

If containers that run in a VCH require a dedicated network for external communication, you can add one or more container networks to the VCH by using the `vic-machine configure --container-network` options. You can also use the `vic-machine configure --container-network` options to reconfigure an existing container network.

The `vic-machine configure --container-network` options function in the same way as the equivalent `vic-machine create` options. For information about the `vic-machine create` container network options, see the description of the [--container-network](vch_installer_options.md#container-network) option and [Options for Configuring a Non-DHCP Network for Container Traffic](vch_installer_options.md#adv-container-net) in VCH Deployment Options.

This example adds a new container network to a VCH. It designates a port group named `vic-containers` for use by container VMs, gives the container network the name `vic-container-network` for use by Docker, specifies the gateway, two DNS servers, and a range of IP addresses on the container network for container VMs to use.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --container-network vic-containers:vic-container-network
    --container-network-gateway vic-containers:<i>gateway_ip_address</i>/24
    --container-network-ip-range vic-containers:192.168.100.0/24
    --container-network-dns vic-containers:<i>dns1_ip_address</i>
    --container-network-dns vic-containers:<i>dns2_ip_address</i></pre>

This example extends the range of IP addresses that the existing `vic-containers` port group makes available. 

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --container-network-ip-range vic-containers:192.168.100.0/32</pre>


## Add, Configure, or Reset Proxy Servers <a id="proxies"></a>

If access to the Internet or to private registry servers changes to pass through a proxy server, you configure a VCH to use the new proxy server by using the `vic-machine configure --https-proxy` and `--http-proxy` options.  You also use the `vic-machine configure --https-proxy` and `--http-proxy` options if an existing proxy server changes.
 
The `vic-machine configure --https-proxy` and `--http-proxy` options function in the same way as the equivalent `vic-machine create` options. For information about the `vic-machine create --https-proxy` and `--http-proxy` options, see [Options to Configure VCHs to Use Proxy Servers](vch_installer_options.md#proxy) in VCH Deployment Options.

This example configures a VCH to use a new HTTPS proxy server.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --https-proxy https://<i>new_proxy_server_address</i>:<i>port</i></pre>

To remove a proxy server from a VCH, set the `vic-machine configure --https-proxy` or `--http-proxy` options to `""`.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --https-proxy ""</pre>

## Configure Debug Mode  <a id="debug"></a>

To enable or disable debug mode on a VCH, you use the `vic-machine configure --debug` option. You can also use `vic-machine configure --debug` to increase or decrease the level of debugging on a VCH that is already running in debug mode.

The `vic-machine configure --debug` option functions in the same way as the equivalent `vic-machine create --debug` option. For information about the `vic-machine create --debug` option, see [`--debug`](vch_installer_options.md#debug) in VCH Deployment Options.

This example increases the level of debugging to level 3, either on a VCH that is running with a lower level of debugging, or on a VCH that is not running in debug mode.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --debug 3</pre>

This example sets the `--debug` option to 0, to disable debug mode on a VCH that is already running at any level of debug mode.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --debug 0</pre>


## Configure CPU and Memory Allocations <a id="cpumem"></a>

If a VCH requires more resources, or if it consumes too many resources, you can configure CPU and memory allocations on the VCH vApp by using the different `vic-machine configure --memory` and `--cpu` options.

The `vic-machine configure` options for memory and CPU allocations function in the same way as the equivalent `vic-machine create` options. For information about the `vic-machine create --cpu` and `--memory` options, see [General Deployment Options](vch_installer_options.md#deployment) in VCH Deployment Options. For information about the memory and CPU reservation and shares options, see [Advanced Resource Management Options](vch_installer_options.md#adv-mgmt).

This example configures a VCH to impose memory and CPU reservations, limits, and shares.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --memory 1024
    --memory-reservation 1024
    --memory-shares low
    --cpu 1024
    --cpu-reservation 1024
    --cpu-shares low
</pre>

**NOTE**: If you set limits on memory and CPU usage that are too low, the `vic-machine configure` operation might fail because it is unable to restart the VCH.

This example removes all limitations on memory and CPU use from a VCH.

<pre>$ vic-machine-<i>operating_system</i> configure
    --target <i>vcenter_server_username</i>:<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    --memory 0
    --memory-reservation 0
    --memory-shares normal
    --cpu 0
    --cpu-reservation 0
    --cpu-shares normal
</pre>