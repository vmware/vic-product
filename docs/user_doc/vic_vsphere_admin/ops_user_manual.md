# Manually Create a User Account for the Operations User #

When you deploy a VCH, the user account that you specify as the operations user must have the correct privileges to allow the VCH to perform post-deployment operations. vSphere Integrated Containers Engine provides a mechanism to automatically assign the necessary permissions to the operations user account, but you can also choose to create the user account manually in vSphere. To do so, you create roles, assign privileges to those roles, and assign the roles to the user account to use as the operations user. 

- For information about how to create vSphere roles, see [vSphere Permissions and User Management Tasks](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-5372F580-5C23-4E9C-8A4E-EF1B4DD9033E.html) in the vSphere documentation. 
- For information about how to assign permissions to objects in the vSphere Inventory, see [Add a Permission to an Inventory Object](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.security.doc/GUID-A0F6D9C2-CE72-4FE5-BAFC-309CFC519EC8.html) in the vSphere documentation.

**Prerequisite**

Log into the Flex-based vSphere Web Client with a vSphere administrator account. You cannot use the HTML5 vSphere Client to create user accounts.

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
<td>Datastore  &gt; Configure datastore<br>
Datastore &gt; Low level file operations<br>
VirtualMachine &gt; Configuration &gt; Add existing disk<br>
VirtualMachine &gt; Configuration &gt; Add new disk<br>
VirtualMachine &gt; Configuration &gt; Advanced<br>
VirtualMachine &gt; Configuration &gt; Remove disk<br>
VirtualMachine &gt; Inventory &gt; Create new<br>
VirtualMachine &gt; Inventory &gt; Remove</td>
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
<td>dvPort group &gt; Modify<br>
  dvPort group &gt; Policy operation<br>
  dvPort group &gt; Scope operation<br>
  Global &gt; Enable methods<br>
  Global &gt; Disable methods<br>
  Resource &gt; Assign virtual machine to resource pool<br>
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
  VirtualMachine &gt; Inventory &gt; Unregister
  </td>
</tr></tbody></table>
6. In each of the **Hosts and Clusters**, **Storage**, and **Networking** views, select inventory objects and assign the user group and the appropriate role to each one.

 1. Right-click an inventory object and select **Add Permission**.
 2. Under Users and Groups, select the operations user group that you created.
 3. Under Assigned Role, assign the appropriate role for each type of inventory object and select the **Propagate to children** check box where necessary.

The following table lists which roles to assign to which type of inventory object, and whether or not to propagate the role.

<table>
<thead>
<tr>
<th>Inventory Object</th>
<th>Role to Assign</th>
<th>Propagate?</th>
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
<td>Yes, if vSphere Distributed Switches are not in network folders. No, if you use network folders. See <a href="#vds">About vSphere Distributed Switches</a> below</td>
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
<td>Yes, if used. See <a href="#vds">About vSphere Distributed Switches</a> below</td>
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
</tbody></table>

**About vSphere Distributed Switches** <a id="vds"></a>

The operations user account must have the `Read-only` role on all of the vSphere Distributed Switches that VCHs use. You can assign this role to switches in either of the following ways:

- If you do not place the switches in network folders, enable propagation of the  `VCH - datacenter` role on datacenters. 
- If you place the switches in network folders, assign the `Read-only` role to the network folders, and enable propagation. In this case, you must still assign the `VCH - datacenter` role to datacenters, but you do not need to enable propagation.

**What to Do Next**

You can use the user accounts in the user group that you created as operations users for VCHs. When you deploy VCHs you do not need to select the option to grant all necessary permissions in the Create Virtual Container Host wizard, or specify `--ops-grant-perms` in `vic-machine create` commands.
