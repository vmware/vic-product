# Client Network #

You can designate a specific network for use by the Docker API by specifying the `--client-network` option. If you do not specify the `--client-network` option, the Docker API uses the public network.

The network on which the VCH endpoint VM makes the Docker API available to Docker clients. The client network isolates the Docker endpoints from the public network. VCHs can access vSphere Integrated Containers Registry over the client network, but it is recommended to connect to registries either over the public network or over the management network. vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry require a connection to the client network. 

You define the Docker management endpoint network by setting the `--client-network` option when you run `vic-machine create`.

### `--client-network` <a id="client-network"></a>

Short name: `--cln`

A port group on which the VCH will make the Docker API available to Docker clients. Docker clients use this network to issue Docker API requests to the VCH.

If not specified, the VCH uses the public network for client traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

<pre>--client-network <i>port_group_name</i></pre>

### Example

This example deploys a VCH with the following configuration:

- Specifies the user name, password, datacenter, cluster, image store, bridge network, and name for the VCH.
- Directs public and management traffic to network 1 and Docker API traffic to network 2.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network 'network 1'
--management-network 'network 1'
--client-network 'network 2'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>
