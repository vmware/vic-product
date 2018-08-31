# Configure the Operations User #

When you deploy a virtual container host (VCH), you must use an account with vSphere administrator permissions. However, day-to-day operation of the VCH requires fewer permissions. You can configure a VCH so that it uses a different operations user account for post-deployment operation.

If you use the Create Virtual Container Host wizard to deploy VCHs, it is **mandatory** to specify an operations user. If you use `vic-machine`, specifying an operations user is recommended but optional. The user account that you specify as the operations user must exist before you deploy the VCH. For information about how to create an operations user account, see [Create the Operations User Account](create_ops_user.md).

- [Options](#options)
  - [vSphere User Credentials](#credentials)
  - [Grant Any Necessary Permissions](#perms)
- [Example](#example)
- [What to Do Next](#whatnext)

## Options <a id="options"></a>

The following sections each correspond to an entry in the Operations User page of the Create Virtual Container Host wizard. Each section also includes a description of the corresponding `vic-machine create` option. 

Certain options in this section are exposed in the `vic-machine create` help if you run `vic-machine create --extended-help`, or `vic-machine create -x`.

### vSphere User Credentials <a id="credentials"></a>

A vSphere user account with which the VCH runs after deployment, which has fewer permissions than the vSphere administrator account that you use during deployment. 

#### Create VCH Wizard

If you are using the Create VCH Wizard, it is **mandatory** to specify an operations user.

1. In the **vSphere user credentials** text box, enter the user name for an existing vSphere user account.
2. Enter the password for the specified user account.

#### vic-machine Options 

`--ops-user`, no short name

`--ops-password`, no short name

If you do not specify `--ops-user`, the VCH runs with the vSphere Administrator credentials with which you deploy the VCH, that you specify in either `--target` or `--user`. 

If you specify `--ops-user` but you do not specify `--ops-password`, `vic-machine create` prompts you to enter the password for the `--ops-user` account.

<pre>--ops-user <i>user_name</i>
--ops-password <i>password</i></pre>

### Grant Any Necessary Permissions <a id="perms"></a>

The operations user account must exist before you create a VCH. If you are deploying the VCH to a cluster, vSphere Integrated Containers Engine can configure the operations user account with all of the necessary permissions for you.

**IMPORTANT**: The option to grant any necessary permissions automatically only applies when deploying VCHs to clusters. If you are deploying the VCH to a standalone host that is managed by vCenter Server, you must configure the operations user account manually. For information about manually configuring the operations user account, see [Manually Create a User Account for the Operations User](ops_user_manual.md).

#### Create VCH Wizard

- Select the **Grant this user any necessary permissions** check box. 
- If you manually added the necessary permissions to the operations user account, do not select the check box.

#### vic-machine Option

`--ops-grant-perms`, no short name

If you specify `--ops-user`, you can also specify `--ops-grant-perms` so that `vic-machine` automatically grants the necessary vSphere permissions to the operations user account. If you specify `--ops-user` but do not specify `--ops-grant-perms`, you must configure the permissions on the operations user account manually.

The `--ops-grant-perms` option takes no arguments.

<pre>--ops-grant-perms</pre>

## Example <a id="example"></a>

This example uses the user account `vic-ops@vsphere.local` as the operations user, and automatically grants the necessary permissions to that account.

### Prerequisite

Follow the instructions in [Create the Operations User Account](create_ops_user.md) to create a vSphere user account, `vic-ops@vsphere.local`.

### Create VCH Wizard

1. In the **vSphere user credentials** text box, enter `vic-ops@vsphere.local`.
2. Enter the password for `vic-ops@vsphere.local`.
3. Select the **Grant this user any necessary permissions** check box.

### vic-machine Command

This example `vic-machine create` command deploys a VCH with the following options:

- Specifies the account `Administrator@vsphere.local` in the `--target` option, to identify the user account with vSphere administrator privileges with which to deploy the VCH.
- Specifies the existing `vic-ops@vsphere.local` user account and its password in the `--ops-user` and `--ops-password` options, to identify the user account with which the VCH runs after deployment. 
- Specifies `--ops-grant-perms` to automatically grant the necessary permissions to the `vic-ops@vsphere.local` user account.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local:<i>vsphere_admin_password</i>'@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--ops-user vic-ops@vsphere.local
--ops-password <i>password</i>
--ops-grant-perms
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>

## What to Do Next <a id="whatnext"></a>

If you are using the Create Virtual Container Host wizard, click **Next** to review the configuration that you have made.