# Public Network #

You can direct the traffic between the VCH and the Internet to a specific network by specifying the `--public-network` option. Any container VM traffic that routes through the VCH also uses the public network. If you do not specify the `--public-network` option, the VCH uses the VM Network for public network traffic.

The network that container VMs use to connect to the internet. Ports that containers expose with `docker create -p` when connected to the default bridge network are made available on the public interface of the VCH endpoint VM via network address translation (NAT), so that containers can publish network services. 

You define the public network by setting the `--public-network` option when you run `vic-machine create`.

### `--public-network` <a id="public-network"></a>

Short name: `--pn`

A port group for containers to use to connect to the Internet. VCHs use the public network to pull container images, for example from https://hub.docker.com/. Containers that use use port mapping expose network services on the public interface. 

**NOTE**: vSphere Integrated Containers Engine adds a new capability to Docker that allows you to directly map containers to a network by using the `--container-network` option. This is the recommended way to deploy container services.

If not specified, containers use the VM Network for public network traffic. If you specify an invalid port group name, `vic-machine create` fails and suggests valid port groups.

<pre>--public-network <i>port_group</i></pre>

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