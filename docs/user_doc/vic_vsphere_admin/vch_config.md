# Virtual Container Host Configuration #

You can set limits on the memory and CPU shares and reservations on the VCH. For information about memory and CPU shares and reservations, see [Allocate Memory Resources](https://pubs.vmware.com/vsphere-65/topic/com.vmware.vsphere.vm_admin.doc/GUID-49D7217C-DB6C-41A6-86B3-7AFEB8BF575F.html), and [Allocate CPU Resources](https://pubs.vmware.com/vsphere-65/topic/com.vmware.vsphere.vm_admin.doc/GUID-6C9023B2-3A8F-48EB-8A36-44E3D14958F6.html) in the vSphere documentation.

- [`vic-machine `Options](#options)
- [Example `vic-machine` Commands](#examples)

## `vic-machine` Options <a id="options"></a>

The following `vic-machine create` options modify the configuration of the VCH appliance itself. 

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### `--use-rp` ###

Short name: none

By default, a VCH is deployed as a vApp. You can optioanlly deploy the VCH appliance in a resource pool on vCenter Server rather than as a vApp. Use this option if the VCH is likely to manage multiple container VMs that run concurrent operations. If you specify this option, `vic-machine create` creates a resource pool with the same name as the VCH, instead of creating a vApp. 

**NOTE**: If you specify both the `--use-rp` and `--ops-user` options when you create a VCH, you must specify an additional permission when you create the roles for the operations user. For information about operations user roles and permissions, see [Use Different User Accounts for VCH Deployment and Operation](set_up_ops_user.md).

<pre>--use-rp</pre>

### `--memory` ###

Short name: `--mem`

Limit the amount of memory that is available for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the memory limit value in MB. If not specified, `vic-machine create` sets the limit to 0 (unlimited).

<pre>--memory 1024</pre>

### `--cpu` ###

Short name: None

Limit the amount of CPU capacity that is available for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the CPU limit value in MHz. If not specified, `vic-machine create` sets the limit to 0 (unlimited).

<pre>--cpu 1024</pre>


### `--memory-reservation` ###

Short name: `--memr`

Reserve a quantity of memory for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the memory reservation value in MB. If not specified, `vic-machine create` sets the reservation to 1.

<pre>--memory-reservation 1024</pre>

### `--memory-shares` ###

Short name: `--mems`

Set memory shares on the VCH vApp in vCenter Server, or on the VCH resource pool on an ESXi host.  This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the share value as a level or a number, for example `high`, `normal`, `low`, or `163840`. If not specified, `vic-machine create` sets the share to `normal`.

<pre>--memory-shares low</pre>

### `--cpu-reservation` ###

Short name: `--cpur`

Reserve a quantity of CPU capacity for use by the VCH vApp in vCenter Server, or for the VCH resource pool on an ESXi host. This limit also applies to the container VMs that run in the VCH vApp or resource pool.  Specify the CPU reservation value in MHz. If not specified, `vic-machine create` sets the reservation to 1.

<pre>--cpu-reservation 1024</pre>

### `--cpu-shares` ###

Short name: `--cpus`

Set CPU shares on the VCH vApp in vCenter Server, or on the VCH resource pool on an ESXi host.  This limit also applies to the container VMs that run in the VCH vApp or resource pool. Specify the share value as a level or a number, for example `high`, `normal`, `low`, or `163840`. If not specified, `vic-machine create` sets the share to `normal`.

<pre>--cpu-shares low</pre>

### `--endpoint-cpu ` ###

Short name: none

The number of virtual CPUs for the VCH endpoint VM. The default is 1. Set this option to increase the number of CPUs in the VCH endpoint VM.

**NOTE** Always use the `--cpu` option instead of the `--endpoint-cpu` option to increase the overall CPU capacity of the VCH vApp, rather than increasing the number of CPUs on the VCH endpoint VM. The `--endpoint-cpu` option is mainly intended for use by VMware Support.

<pre>--endpoint-cpu <i>number_of_CPUs</i></pre>

### `--endpoint-memory ` ###

Short name: none

The amount of memory for the VCH endpoint VM. The default is 2048MB. Set this option to increase the amount of memory in the VCH endpoint VM if the VCH will pull large container images.

**NOTE** With the exception of VCHs that pull large container images, always use the `--memory` option instead of the `--endpoint-memory` option to increase the overall amount of memory for the VCH vApp, rather than on the VCH endpoint VM. Use `docker create -m` to set the memory on container VMs. The `--endpoint-memory` option is mainly intended for use by VMware Support.

<pre>--endpoint-memory <i>amount_of_memory</i></pre>

### `--appliance-iso` ###

Short name: `--ai`

The path to the ISO image from which the VCH appliance boots. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--appliance-iso <i>path_to_ISO_file</i>/appliance.iso</pre>

## Example `vic-machine` Commands <a id="examples"></a>

- [Set Limits on Resource Use](#customized)
- [Deploy VCH as a Resource Pool Instead of as a vApp](#not_vapp)

### Set Limits on Resource Use <a id="customized"></a>

To limit the amount of system resources that the container VMs in a VCH can use, you can set resource limits on the VCH vApp. 

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Sets resource limits on the VCH by imposing memory and CPU reservations, limits, and shares.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--memory 1024
--memory-reservation 1024
--memory-shares low
--cpu 1024
--cpu-reservation 1024
--cpu-shares low
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>

### Deploy VCH as a Resource Pool Instead of as a vApp <a id="not_vapp"></a> 

If a VCH is likely to handle heavy loads, with multiple concurrent operations running in container VMs, it is recommended to deploy that VCH as a resource pool rather than as a vApp.

This example deploys a VCH with the following configuration:

- Provides the vCenter Single Sign-On user name and password for a vSphere administrator account in the `--target` option. The user name is wrapped in quotes, because it contains the `@` character.
- Deploys a VCH named `vch1` to the cluster `cluster1` in datacenter `dc1`. 
- Uses an existing port group named `vch1-bridge` for the bridge network. 
- Designates `datastore1` as the image store. 
- Specifies `--use-rp` so that the VCH is deployed as a resource pool rather than as a vApp.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--use-rp
</pre>