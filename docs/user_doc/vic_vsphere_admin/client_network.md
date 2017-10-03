# Configure the Client Network #

The client network is the network on which the VCH endpoint VM makes the Docker API available to Docker clients. By designating a specific client network, you isolate Docker endpoints from the public network. Virtual container hosts (VCHs) access vSphere Integrated Containers Management Portal and vSphere Integrated Containers Registry over the client network. 

- [`vic-machine` Option](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Option <a id="options"></a>

You designate a specific network for traffic between Docker clients and the VCH by specifying the `vic-machine create --client-network` option when you deploy the VCH.

### `--client-network` <a id="client-network"></a>

**Short name**: `--cln`

A port group on which the VCH makes the Docker API available to Docker clients. Docker clients use this network to issue Docker API requests to the VCH.

**Usage**: 
<pre>--client-network <i>port_group_name</i></pre>

If you do not specify this option, the VCH uses the public network for client traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

## Example `vic-machine` Command <a id="example"></a>

This example deploys a VCH with the following configuration:

- Specifies the target vCenter Server instance, the vCenter Server user name, password, datacenter and cluster, an image store, a port group for the bridge network, a name for the VCH, and the thumbprint of the vCenter Server certificate.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Directs public traffic to an existing port group named `network 1` and Docker API and management traffic to `network 2`.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network 'network 1'
--management-network 'network 2'
--client-network 'network 2'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>
