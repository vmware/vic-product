# Manually Create a User Account for the Operations User #

When you deploy a VCH, the user account that you specify as the operations user must have the correct privileges to allow the VCH to perform post-deployment operations. vSphere Integrated Containers Engine provides a mechanism to automatically assign the necessary permissions to the operations user account, but you can also choose to create the user account manually in vSphere. To do so, you create roles, assign privileges to those roles, and assign the roles to the user account to use as the operations user. 

- For information about how to create vSphere roles, see [vSphere Permissions and User Management Tasks](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.security.doc/GUID-5372F580-5C23-4E9C-8A4E-EF1B4DD9033E.html) in the vSphere documentation. 
- For information about how to assign permissions to objects in the vSphere Inventory, see [Add a Permission to an Inventory Object](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.security.doc/GUID-A0F6D9C2-CE72-4FE5-BAFC-309CFC519EC8.html) in the vSphere documentation.

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
<td><code>VCH - datacenter</code></td>
<td>Datastore  &gt; Configure datastore<br>
Datastore &gt; Low level file operations<br>
VirtualMachine.Configuration &gt; Add new disk<br>
VirtualMachine.Configuration &gt; Advanced<br>
VirtualMachine.Configuration &gt; Remove disk<br>
VirtualMachine.Inventory &gt; Create new<br>
VirtualMachine.Inventory &gt; Remove</td>
</tr>
<tr>
<td><code>VCH - endpoint</code></td>
<td><p>dvPort group &gt; Modify<br>
  dvPort group &gt; Policy operation<br>
  dvPort group &gt; Scope operation<br>
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
  VirtualMachine &gt; Inventory &gt; Unregister</p>
  </td>
</tr></tbody></table>
5. In the Hosts and Clusters view, right-click the datacenter in which to deploy the VCH and select **Add Permission**.
6. Under Users and Groups, select the operations user group that you created.
7. Under Assigned Role, select the **VCH - datacenter** and **VCH - endpoint** roles that you just created.
8. Do not select the Propagate to children checkbox, and click **OK**.

**What to Do Next**

You can use the user accounts in the user group that you created as operations users for VCHs. When you deploy VCHs you do not need to select the option to grant all necessary permissions in the Create Virtual Container Host wizard, or specify `--ops-grant-perms` in `vic-machine create` commands.
