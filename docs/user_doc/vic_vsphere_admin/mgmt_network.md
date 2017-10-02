# Configure the Management Network #

The management network is the network on which the VCH endpoint VM connects to vCenter Server and ESXi hosts. By designating a specific management network, you isolate connections to vSphere resources from the public network. The VCH uses this network to provide the `attach` function of the Docker API. 

- [`vic-machine` Options](#options)
- [Example `vic-machine` Commands](#example)

## `vic-machine` Options <a id="options"></a>

You designate a specific network for traffic between the VCH and vSphere resources by specifying the `vic-machine create --management-network` option when you deploy the VCH. You can also route incoming connections from ESXi hosts to VCHs over the public network rather than over the management network by specifying the `--asymmetric-routes` option.

### `--management-network` <a id="management-network"></a>

**Short name**: `--mn`

A port group that the VCH uses to communicate with vCenter Server and ESXi hosts. Container VMs use this network to communicate with the VCH. 

**IMPORTANT**: Because the management network provides access to your vSphere environment, and because container VMs use this network to communicate with the VCH, always use a secure network for the management network. Ideally, use separate networks for the management network and the container networks. The most secure setup is to make sure that VCHs can access vCenter Server and ESXi hosts directly over the management network, and that the management network has route entries for the subnets that contain both the target vCenter Server and the corresponding ESXi hosts. If the management network does not have route entries for the vCenter Server and ESXi host subnets, you must configure asymmetric routing. For more information about asymmetric routing, see the section on the [`--asymmetric-routes` option](#asymmetric-routes). 

When you create a VCH, `vic-machine create` checks that the firewall on ESXi hosts allows connections to port 2377 from the management network of the VCH. If access to port 2377 on ESXi hosts is subject to IP address restrictions, and if those restrictions block access to the management network interface, `vic-machine create` fails with a firewall configuration error:
<pre>Firewall configuration incorrect due to allowed IP restrictions on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

For information about how to open port 2377, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

**NOTE**: If the management network uses DHCP, `vic-machine` checks the firewall status of the management network before the VCH receives an IP address. It is therefore not possible to fully assess whether the firewall permits the IP address of the VCH. In this case, `vic-machine create` issues a warning. 

<pre>Unable to fully verify firewall configuration due to DHCP use on management network 
VCH management interface IP assigned by DHCP must be permitted by allowed IP settings 
Firewall allowed IP configuration may prevent required connection on hosts: 
"/ha-datacenter/host/localhost.localdomain/localhost.localdomain" 
Firewall must permit dst 2377/tcp outbound to the VCH management interface
</pre>

**Usage**: 
<pre>--management-network <i>port_group_name</i></pre>

If you do not specify this option, the VCH uses the public network for management traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

### `--asymmetric-routes` <a id="asymmetric-routes"></a>

**Short name**: `--ar`

Allows incoming connections from ESXi hosts to VCHs over the public network rather than over the management network. This option allows containers on bridge networks to indirectly access assets on the management or client networks via the public interface, if those assets are routable from the public network. If the management network does not have route entries for the vCenter Server and ESXi host subnets,  and you do not set `--asymmetric-routes`, containers that run without specifying `-d` remain in the starting state.

In this scenario, use the `--asymmetric-routes` option to allow management traffic from ESXi hosts to the VCH to pass over the public network. By setting the `--asymmetric-routes` option, you set reverse path forwarding in the VCH endpoint VM to loose mode rather than the default strict mode. For information about reverse path forwarding and loose mode, see https://en.wikipedia.org/wiki/Reverse_path_forwarding.

**Usage**: 
<pre>--asymmetric-routes</pre>

The `--asymmetric-routes` option takes no arguments. If you do not set `--asymmetric-routes`, all management traffic is routed over the management network.

## Example `vic-machine` Commands <a id="example"></a>

This example deploys a VCH with the following configuration:

- Specifies the target vCenter Server instance, the vCenter Server user name, password, datacenter and cluster, an image store, a port group for the bridge network, a name for the VCH, and the thumbprint of the vCenter Server certificate.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Directs public and management traffic to an existing port group named `network 1` and Docker API traffic to `network 2`.
- Does not specify the `--public-network` option, so traffic from container VMs and the VCH default to the VM Network. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--management-network 'network 1'
--client-network 'network 2'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

The following example deploys a similar VCH, but specifies `--asymmetric-routes` to allow incoming connections from ESXi hosts to VCHs over the public network rather than over the management network.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--management-network 'network 1'
--client-network 'network 2'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--asymmetric-routes
</pre>