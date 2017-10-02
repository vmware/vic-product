# Configure the Public Network #

The public network is the network that container VMs and the virtual container host (VCH) use to connect to the Internet. VCHs use the public network to pull container images from public registries, for example from Docker Hub. Container VMs that use port mapping expose network services on the public network. In Docker terminology, the public network corresponds to the `eth0` network on a Docker host.

- [`vic-machine` Option](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Option <a id="options"></a>

You designate a specific network for traffic from container VMs and the VCH to the Internet by specifying the `vic-machine create --public-network` option when you deploy the VCH.

### `--public-network` <a id="public-network"></a>

**Short name**: `--pn`

A port group that container VMs and VCHs use to connect to the Internet. Ports that containers that are connected to the default bridge network expose with `docker create -p` are made available on the public interface of the VCH endpoint VM via network address translation (NAT), so that containers can publish network services.  

**NOTE**: vSphere Integrated Containers adds a new capability to Docker that allows you to directly map containers to a network by using the `--container-network` option. This is the recommended way to deploy container services with vSphere Integrated Containers. For more information, see [Configure Container Networks](container_networks.md).

**Usage**: 
<pre>--public-network <i>port_group_name</i></pre>

If you do not specify this option, containers use the VM Network for public network traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

## Example `vic-machine` Command <a id="example"></a>

This example deploys a VCH with the following configuration:

- Specifies the target vCenter Server instance, the vCenter Server user name, password, datacenter and cluster, an image store, a port group for the bridge network, a name for the VCH, and the thumbprint of the vCenter Server certificate.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.
- Directs public network traffic to an existing port group named `network 1`. 
- Does not specify either of the `--management-network` or `--client-network` options. Consequently, management and client traffic also routes over `network 1` because those networks default to the public network setting if they are not set.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network 'network 1'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>