# Virtual Container Host Compute Capacity #

When you deploy a virtual container host (VCH), you must select the compute resource in your virtual infrastructure in which to deploy the VCH. You can optionally configure resource usage limits on the VCH.

- [Options](#options)
  - [Compute Resource](#compute-resource)
  - [CPU](#cpu)
  - [Memory](#memory)
- [Advanced Options](#advanced)
  - [CPU Reservation](#cpures)
  - [CPU Shares](#cpushares)
  - [Memory Reservation](#memoryres)
  - [Memory Shares](#memoryshares)
  - [Endpoint VM CPUs](#endpointcpu)
  - [Endpoint VM Memory](#endpointmemory)
- [What to Do Next](#whatnext)
- [Example `vic-machine` Commands](#examples)
  - [Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores](#cluster)
  - [Deploy to a Specific Standalone Host in vCenter Server](#standalone)
  - [Deploy to a Resource Pool on an ESXi Host](#rp_host)
  - [Deploy to a Resource Pool in a vCenter Server Cluster](#rp_cluster)
  - [Set Limits on Resource Use](#customized) 

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Compute Capacity page of the Create Virtual Container Host wizard and to the  corresponding `vic-machine create` options.

### Compute Resource <a id="compute-resource"></a>

The host, cluster, or resource pool in which to deploy the VCH. 

**NOTE**: You cannot deploy a VCH to a specific host in a cluster. You deploy the VCH to the cluster, and DRS manages the placement of the VCH on a host.

#### Create VCH Wizard 

Selecting a compute resource is **mandatory**.

1. Expand the **Compute resource** inventory hierarchy.
2. Select a standalone host, cluster, or resource pool to which to deploy the VCH. 

#### vic-machine Option 

`--compute-resource`, `-r`

If the vCenter Server instance on which you are deploying a VCH only includes a single instance of a standalone host or cluster, `vic-machine create` automatically detects and uses those resources. In this case, you do not need to specify a compute resource when you run `vic-machine create`. If you are deploying the VCH directly to an ESXi host and you do not use `--compute-resource` to specify a resource pool, `vic-machine create` automatically uses the default resource pool.

You specify the `--compute-resource` option in the following circumstances:

- A vCenter Server instance includes multiple instances of standalone hosts or clusters, or a mixture of standalone hosts and clusters.
- You want to deploy the VCH to a specific resource pool in your environment. 

If you do not specify the `--compute-resource` option and multiple possible resources exist, or if you specify an invalid resource name, `vic-machine create` fails and suggests valid targets for `--compute-resource` in the failure message. 

To deploy to a specific resource pool on an ESXi host that is not managed by vCenter Server, specify the name of the resource pool: <pre>--compute-resource  <i>resource_pool_name</i></pre>

To deploy to a vCenter Server instance that has multiple standalone hosts that are not part of a cluster, specify the IPv4 address or fully qualified domain name (FQDN) of the target host:<pre>--compute-resource <i>host_address</i></pre>

To deploy to a vCenter Server with multiple clusters, specify the name of the target cluster: <pre>--compute-resource <i>cluster_name</i></pre>

To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, or to a specific resource pool in a cluster, if the resource pool name is unique across all hosts and clusters, specify the name of the resource pool:<pre>--compute-resource <i>resource_pool_name</i></pre>

To deploy to a specific resource pool on a standalone host that is managed by vCenter Server, if the resource pool name is not unique across all hosts, specify the IPv4 address or FQDN of the target host and name of the resource pool:<pre>--compute-resource <i>host_name</i>/<i>resource_pool_name</i></pre>

To deploy to a specific resource pool in a cluster, if the resource pool name is not unique across all clusters, specify the full path to the resource pool:<pre>--compute-resource <i>cluster_name</i>/Resources/<i>resource_pool_name</i></pre>

### CPU <a id="cpu"></a>

Limit the amount of CPU capacity that is available for use by the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool. Specify the CPU capacity in MHz.

#### Create VCH Wizard 

In the **CPU** text box, leave the default value of `Unlimited`,  or optionally enter a limit of between the minimum and maximum shown. 

#### vic-machine Option  

`--cpu`, no short name

Specify a CPU limit value in MHz. If not specified, `vic-machine create` sets the limit to 0 (unlimited).

<pre>--cpu 1024</pre>

### Memory <a id="memory"></a>

Limit the amount of memory that is available for use by the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool. Specify the memory limit value in MB. 

#### Create VCH Wizard 

In the **Memory** text box, leave the default value of `Unlimited`, or optionally enter a limit of between the minimum and maximum shown.  

#### vic-machine Option   

`--memory`, `--mem`

Specify a limit in MB. If not specified, `vic-machine create` sets the limit to 0 (unlimited).

<pre>--memory 1024</pre>

## Advanced Options <a id="advanced"></a>

When using the Create Virtual Container Host wizard, if you change any of the advanced options, leave the **Advanced** view open when you click **Next** to proceed to the next page.

If you are using `vic-machine`, the options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

For information about vSphere memory and CPU shares and reservations, see [Allocate Memory Resources](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.vm_admin.doc/GUID-49D7217C-DB6C-41A6-86B3-7AFEB8BF575F.html), and [Allocate CPU Resources](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.vm_admin.doc/GUID-6C9023B2-3A8F-48EB-8A36-44E3D14958F6.html) in the vSphere documentation.

### CPU Reservation <a id="cpures"></a>

Reserve a quantity of CPU capacity for use by the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool.  Specify the CPU reservation value in MHz. 

#### Create VCH Wizard 

1. Expand **Advanced**.
2. In the **CPU reservation** text box, leave the default value of 1, or optionally enter a limit of between the minimum and maximum shown.

#### vic-machine Option  

`--cpu-reservation`, `--cpur`

Specify a limit in MHz. If not specified, `vic-machine create` sets the reservation to 1.

<pre>--cpu-reservation 1024</pre>

### CPU Shares <a id="cpushares"></a>

Set CPU shares on the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool.  

#### Create VCH Wizard 

1. Expand **Advanced**.
2. In the **CPU shares** text box, leave the default value of **Normal**, or select **Low** or **High**.

#### vic-machine Option 

`--cpu-shares`, `--cpus`

Specify the share value as a level or a number, for example `high`, `normal`, `low`, or `163840`. If not specified, `vic-machine create` sets the share to `normal`.

<pre>--cpu-shares low</pre>

### Memory Reservation <a id="memoryres"></a>

Reserve a quantity of memory for use by the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool. Specify the memory reservation value in MB.  

#### Create VCH Wizard 

1. Expand **Advanced**.
2. In the **Memory reservation** text box, leave the default value of 1, or optionally enter a limit of between the minimum and maximum shown.

#### vic-machine Option 

`--memory-reservation`, `--memr`

Specify a limit in MB. If not specified, `vic-machine create` sets the reservation to 1.

<pre>--memory-reservation 1024</pre>

### Memory Shares <a id="memoryshares"></a>

Set memory shares on the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool.  

#### Create VCH Wizard 

1. Expand **Advanced**.
2. In the **Memory shares** text box, leave the default value of **Normal** or select **Low** or **High**.

#### vic-machine Option  

`--memory-shares`, `--mems`

Specify the share value as a level or a number, for example `high`, `normal`, `low`, or `163840`. If not specified, `vic-machine create` sets the share to `normal`.

<pre>--memory-shares low</pre>

### Endpoint VM CPUs <a id="endpointcpu"></a>

The number of virtual CPUs for the VCH endpoint VM. The default is 1. Set this option to increase the number of CPUs in the VCH endpoint VM.

**NOTE**: In most cases, increase the overall CPU capacity of the VCH resource pool, rather than increasing the number of CPUs on the VCH endpoint VM. This option is mainly intended for use by VMware Support.  

#### Create VCH Wizard 

1. Expand **Advanced**.
2. In the **CPUs** text box, leave the default value of 1 or enter a higher number of CPUs.

#### vic-machine Option 

Specify a value of greater than 1. If not specified, `vic-machine create` sets the number of CPUs to 1.

`--endpoint-cpu `, no short name

<pre>--endpoint-cpu <i>number_of_CPUs</i></pre>

### Endpoint VM Memory <a id="endpointmemory"></a>

The amount of memory for the VCH endpoint VM. Set this option to increase the amount of memory in the VCH endpoint VM if the VCH will pull large container images.

**NOTE** With the exception of VCHs that pull large container images, increase the overall amount of memory for the VCH resource pool, rather than the amount of memory of the VCH endpoint VM. Use `docker create -m` to set the memory on container VMs. This option is mainly intended for use by VMware Support.

#### Create VCH Wizard 

1. Expand **Advanced**.
2. In the **Memory** text box, leave the default value of 2048 MB, or optionally enter a limit of between the minimum and maximum shown.

#### vic-machine Option 

`--endpoint-memory `, no short name

Specify a value in MB. If not specified, `vic-machine create` sets memory to 2048 MB.

<pre>--endpoint-memory <i>amount_of_memory</i></pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to go to the [Storage Capacity](vch_storage.md) settings.

## Example `vic-machine` Commmands <a id="examples"></a>

The following examples show `vic-machine create` commands that use the options described in this topic. For simplicity, the examples all use the `--no-tlsverify` option to automatically generate server certificates but disable client authentication. The examples use existing port groups named `vch1-bridge` and `vic-public` for the bridge and public networks, and designate `datastore1` as the image store. 

### Deploy to a vCenter Server Cluster with Multiple Datacenters and Datastores <a id="cluster"></a>

This example `vic-machine create` command deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Deploy to a Specific Standalone Host in vCenter Server <a id="standalone"></a> 

This example `vic-machine create` command deploys a VCH on the ESXi host with the FQDN `esxihost1.organization.company.com`.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--bridge-network vch1-bridge
--public-network vic-public
--image-store datastore1
--compute-resource esxihost1.organization.company.com
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Deploy to a Resource Pool on an ESXi Host <a id="rp_host"></a>

This example `vic-machine create` command deploys a VCH into a resource pool named `rp 1`. The resource pool name is wrapped in quotes, because it contains a space. It does not specify an image store, assuming that the host in this example only has one datastore.

<pre>vic-machine-<i>operating_system</i> create
--target root:<i>password</i>@<i>esxi_host_address</i>
--compute-resource 'rp 1'
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Deploy to a Resource Pool in a vCenter Server Cluster <a id="rp_cluster"></a>

This example `vic-machine create` command deploys a VCH into a resource pool named `rp 1`. In this example, the resource pool name `rp 1` is unique across all hosts and clusters, so it only specifies the resource pool name.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

If the name of the resource pool is not unique across all clusters, for example if two clusters each contain a resource pool named `rp 1`, you must specify the full path to the resource pool in the `compute-resource` option, in the format <i>cluster_name</i>/Resources/<i>resource_pool_name</i>.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource 'cluster 1'/Resources/'rp 1'
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

### Set Limits on Resource Use <a id="customized"></a>

This example `vic-machine create` command sets resource limits on the VCH by imposing memory and CPU reservations, limits, and shares.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--memory 1024
--memory-reservation 1024
--memory-shares low
--cpu 1024
--cpu-reservation 1024
--cpu-shares low
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>