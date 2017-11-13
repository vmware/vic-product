# Use Different User Accounts for VCH Deployment and Operation #

A virtual container host (VCH) appliance requires the appropriate permissions in vSphere to perform various tasks during VCH operation. 

During deployment of a VCH, `vic-machine` uses the vSphere account that you specify in either of the `vic-machine create --user` or `--target` options for all deployment operations. Deployment of a VCH requires a user account with vSphere administrator privileges. However, day-to-day operation of a VCH requires fewer vSphere permissions than deployment.

By default, after deployment, a VCH runs with the same user account as you used to deploy that VCH. In this case, a VCH uses the vSphere administrator account for post-deployment operations, meaning that it runs with full vSphere administrator privileges. Running with full vSphere administrator privileges is excessive, and potentially a security risk.

To avoid this situation, you can configure a VCH so that it uses different user accounts for deployment and for post-deployment operation by using the `vic-machine create --ops-user` and `--ops-password` options when you deploy the VCH. By specifying `--ops-user`, you can limit the post-deployment privileges of the VCH to only those vSphere privileges that it needs.

- [How `--ops-user` Works](#behavior)
- [Create a User Account for `--ops-user`](#createuser)
- [`vic-machine` Options](#options)
- [Example `vic-machine` Command](#example)

## How `--ops-user` Works  <a id="behavior"></a>

If you use `--ops-user` to specify a different user account for post-deployment operation, `vic-machine` and the VCH behave differently to how they behave in a default deployment.

### Default Behavior

- When you create a VCH, you provide vSphere administrator credentials to `vic-machine create`, either in `--target` or in the `--user` and `--password` options. During deployment, `vic-machine create` uses these credentials to log in to vSphere and create the VCH. The VCH safely and securely stores the vSphere administrator credentials, for use in post-deployment operation.
- When you run other `vic-machine` commands on the VCH after deployment, for example, `ls`, `upgrade`, or `configure`, you again provide the vSphere administrator credentials in the `--target` or `--user` and `--password` options. Again, `vic-machine` uses these credentials to log in to vSphere to retrieve the necessary information or to perform upgrade or configuration tasks on the VCH.
- When a container developer creates a container in the VCH, they authenticate with the VCH with their client certificate. In other words, the developer interacts with the VCH via the Docker client, and does not need to provide any vSphere credentials. However, the VCH uses the stored vSphere administrator credentials that you provided during deployment to log in to vSphere to create the container VM.

### Behavior with `--ops-user` Specified

- When you create a VCH, you provide vSphere administrator credentials to `vic-machine create`, either in `--target` or in the `--user` and `--password` options. You also provide the credentials for an account with lesser privileges in the `--ops-user` and `--ops-password` options. During deployment, `vic-machine create` uses the vSphere administrator credentials to log in to vSphere and create the VCH, in the same way as in the default case. The credentials that you specify in `--ops-user` and `--ops-password` are safely and securely stored in the VCH, for use in post-deployment operation. In this case, the VCH does not store the vSphere administrator credentials.
- When you run other `vic-machine` commands on the VCH after deployment, for example, `ls`, `upgrade`, or `configure`, you provide the vSphere administrator credentials in the `--target` or `--user` and `--password` options. This is the same as in the default case. The stored `--ops-user` and `--ops-password` credentials are not used.
- When a container developer creates a container in the VCH, the VCH uses the stored `--ops-user` and `--ops-password` credentials that you provided during deployment to log in to vSphere to create the container VM.


## Create a User Account for `--ops-user` <a id="createuser"></a>

After deployment, a VCH must have permission to perform the following operations:

- Create, modify, and delete VMs within its resource pool
- Reconfigure the endpoint VM
- Validate host firewall configuration and system licenses

When you deploy a VCH, the user account that you specify in `--ops-user` must have the correct privileges to allow the VCH to perform these operations. vSphere Integrated Containers Engine does not currently create the required vSphere roles, so to assign privileges to the `--ops-user` user account, you must manually create user roles in vSphere before you deploy the VCH. You assign privileges to those roles, and assign the roles to the user account to use in `--ops-user`. 

- For information about how to create vSphere roles, see [vSphere Permissions and User Management Tasks](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.security.doc/GUID-5372F580-5C23-4E9C-8A4E-EF1B4DD9033E.html) in the vSphere documentation. 
- For information about how to assign permissions to objects in the vSphere Inventory, see [Add a Permission to an Inventory Object](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.security.doc/GUID-A0F6D9C2-CE72-4FE5-BAFC-309CFC519EC8.html) in the vSphere documentation.

**Procedure**

1. In the vSphere Web Client, create a user group, for example `VIC Ops Users`, and add the appropriate user accounts to the user group.

    The best practice when assigning roles in vSphere is to assign the roles to user groups and then to add users to those groups, rather than assigning roles to the users directly.

2. Go to **Administration** > **Roles** and create one role for each type of inventory object that VCHs need to access.

    It is possible to create a single role, but by creating multiple roles you keep the privileges of the VCH as granular as possible.

    <table>
<thead>
<tr>
<th><strong>Role to Create</strong></th>
<th><strong>Required Permissions</strong></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>VCH - vcenter</code></td>
<td>Datastore &gt; Configure datastore</td>
</tr>
<tr>
<td><code>VCH - datacenter</code></td>
<td>Datastore &gt; Configure datastore<br>Datastore &gt; Low level file operations</td>
</tr>
<tr>
<td><code>VCH - datastore</code></td>
<td>Datastore &gt; AllocateSpace<br>Datastore &gt; Browse datastore <br>Datastore &gt; Configure datastore<br>Datastore &gt; Remove file<br>Datastore &gt; Low level file operations<br>Host &gt; Configuration &gt; System management</td>
</tr>
<tr>
<td><code>VCH - network</code></td>
<td>Network &gt; Assign network</td>
</tr>
<tr>
<td><code>VCH - endpoint</code></td>
<td><p>dvPort group &gt; Modify<br>
  dvPort group &gt; Policy operation<br>
  dvPort group &gt; Scope operation<br>
  Resource &gt; Add virtual machine *<br>
  vApp &gt; Add virtual machine<br>
  VirtualMachine &gt; Configuration &gt; Add existing disk<br>
  VirtualMachine &gt; Configuration &gt; Add new disk<br>
  VirtualMachine &gt; Configuration &gt; Add or remove device<br>
  VirtualMachine &gt; Configuration &gt; Advanced<br>
  VirtualMachine &gt; Configuration &gt; Modify device settings<br>
  VirtualMachine &gt; Configuration &gt; Remove disk<br>
  VirtualMachine &gt; Configuration &gt; Rename<br>
  VirtualMachine &gt; Guest operations &gt; Guest operation program execution<br>
  VirtualMachine &gt; Interaction &gt; Device connection<br>
  VirtualMachine &gt; Interaction &gt; Power off<br>
  VirtualMachine &gt; Interaction &gt; Power on<br>
  VirtualMachine &gt; Inventory &gt; Create new<br>
  VirtualMachine &gt; Inventory &gt; Remove<br>
  VirtualMachine &gt; Inventory &gt; Register<br>
  VirtualMachine &gt; Inventory &gt; Unregister</p>
  </td>
</tr></tbody></table>

    &#42; If you use both of the `--ops-user` and  [`--use-rp`](vch_config.md#use-rp) options when you create a VCH, you must include the **Resource** &gt; **Add virtual machine** permission in the `VCH - endpoint` role. The **vApp** &gt; **Add virtual machine** permission is not required if you deploy the VCH with the `--use-rp` option. 

3. Go to **Networking**, create a network folder, and place the distributed virtual switches that the VCHs will use for the bridge network and any container networks into that folder.

    The parent object of distributed virtual switches that the VCH uses  as the bridge network and container networks must be set to `Read-Only`, with **Propagate to Children** enabled. By placing distributed virtual switches in a network folder, you avoid setting an entire datacenter to `Read-Only`. This restriction only applies to the bridge network and container networks. When you specify the `vic-machine create --bridge-network` and `--container-network` options, include the full inventory path to the networks in the following format:<pre><i>datacenter</i>/network/<i>network_folder</i>/<i>port_group_name</i></pre>

2. (Optional) Go to **Hosts and Clusters** and create a resource pool in which to deploy VCHs.

    By creating a resource pool for VCHs, you can set the correct permissions on just that resource pool rather than on an entire host or cluster. You specify this resource pool in the `vic-machine create --compute-resource` option when you deploy the VCH. For a more granular application of privileges, you can also apply the permissions directly to VCH vApps after deployment, rather than to a resource pool.

5. In each of the **Hosts and Clusters**, **Storage**, and **Networking** views, select inventory objects and assign the user group and the appropriate role to each one.

    <table>
<thead>
<tr>
<th>Inventory Object</th>
<th>Role to Assign</th>
<th>Propagate</th>
</tr>
</thead>
<tbody>
<tr>
<td>Top-level vCenter Server instance</td>
<td><code>VCH - vcenter</code></td>
<td>No</td>
</tr>
<tr>
<td>Datacenters</td>
<td><code>VCH - datacenter</code></td>
<td>No</td>
</tr>
<tr>
<td>Clusters. All datastores in the cluster inherit permissions from the cluster.</td>
<td><code>VCH - datastore</code></td>
<td>Yes</td>
</tr>
<tr>
<td>Standalone VMware vSAN datastores</td>
<td><code>VCH - datastore</code></td>
<td>No</td>
</tr>
<tr>
<td>Standalone datastores</td>
<td><code>VCH - datastore</code></td>
<td>No</td>
</tr>
<tr>
<td>Network folders</td>
<td><code>Read-only</code></td>
<td>Yes</td>
</tr>
<tr>
<td>Port groups</td>
<td><code>VCH - network</code></td>
<td>No</td>
</tr>
<tr>
<td>Resource pools for VCHs</td>
<td><code>VCH - endpoint</code></td>
<td>Yes</td>
</tr>
<tr>
<td>VCH vApps, for a very granular application of privileges</td>
<td><code>VCH - endpoint</code></td>
<td>Yes</td>
</tr></tbody></table>

**What to do next**

Use `vic-machine create --ops-user` to deploy VCHs that operate with restricted vSphere privileges. Ensure that the various vSphere inventory objects that you specify as arguments have the user group with the appropriate role.

## `vic-machine` Options <a id="options"></a>

You configure a VCH so that it uses different user accounts for deployment and for operation by using the `--ops-user` and `--ops-password` options.

### `--ops-user` <a id="ops-user"></a>

**Short name**: None

A vSphere user account with which the VCH runs after deployment. If not specified, the VCH runs with the vSphere Administrator credentials with which you deploy the VCH, that you specify in either `--target` or `--user`.

The user account that you specify in `--ops-user` must exist before you deploy the VCH. For information about the permissions that the `--ops-user` account requires, see [Create a User Account for `--ops-user`](#createuser) above.

**Usage**:

<pre>--ops-user <i>user_name</i></pre>

### `--ops-password` ###

**Short name**: None

The password or token for the operations user that you specify in `--ops-user`. If not specified, `vic-machine create` prompts you to enter the password for the `--ops-user` account.

**Usage**:

<pre>--ops-password <i>password</i></pre>

## Example `vic-machine` Command <a id="example"></a>

This example deploys a VCH with the following configuration:

- Specifies the image store and name for the VCH.
- Specifies the account <i>vsphere_admin</i> in the `--target` option, to identify the user account with vSphere administrator privileges with which to deploy the VCH.
- Specifies <i>vsphere_user</i> and its password in the `--ops-user` and `--ops-password` options, to identify the user account with which the VCH runs after deployment. The user account that you specify in `--ops-user` must  be different to the vSphere Administrator account that you use for deployment, must have the privileges listed in [Create a User Account for `--ops-user`](#createuser) above, and must exist before you deploy the VCH. 
- Specifies a resource pool in which to deploy the VCH in the `--compute-resource` option.
- Specifies the full paths to VCH port groups in a network folder named `vic_networks` in the `--bridge-network` and `--container-network` options.
- Secures connections to the Docker API with an automatically generated server certificate, without client certificate verification, by setting `--no-tlsverify`.

<pre>vic-machine-<i>operating_system</i> create
--target <i>vsphere_admin</i>:<i>vsphere_admin_password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1/VCH_pool
--image-store datastore1
--bridge-network dc1/network/vic_networks/vch1-bridge
--container-network dc1/network/vic_networks/vic-containers:vic-container-network
--name vch1
--ops-user <i>vsphere_user</i>
--ops-password <i>vsphere_user_password</i>
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>