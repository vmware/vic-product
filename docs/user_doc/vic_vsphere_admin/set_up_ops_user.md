# Configure the Operations User #

A virtual container host (VCH) appliance requires the appropriate permissions in vSphere to perform various tasks during VCH operation. 

During deployment of a VCH, vSphere Integrated Containers Engine runs all deployment operations by using either the vSphere administrator account that you specify in `vic-machine create --user` or `--target`, or, if you are using the Create Virtual Container Host wizard, it uses the vSphere administrator account with which you are logged into the vSphere Client. Deployment of a VCH requires a user account with vSphere administrator privileges. However, day-to-day operation of a VCH requires fewer vSphere permissions than deployment.

By default, after deployment, a VCH runs with the same user account as you used to deploy that VCH. In this case, a VCH uses the vSphere administrator account for post-deployment operations, meaning that it runs with full vSphere administrator privileges. Running with full vSphere administrator privileges is excessive, and potentially a security risk.

To avoid this situation, you configure a VCH so that it uses different user accounts for deployment and for post-deployment operation by specifying an *operations user* when you deploy the VCH. By specifying an operations user, you limit the post-deployment privileges of the VCH to only those vSphere privileges that it needs for day-to-day operation.

- [How the Operations User Works](#behavior)
- [Create a User Account for the Operations User](#createuser)
- [Options](#options)
- [Example](#example)

## How the Operations User Works <a id="behavior"></a>

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


## Options <a id="options"></a>

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

## Example <a id="example"></a>

This example `vic-machine create` command deploys a VCH with the following configuration:

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