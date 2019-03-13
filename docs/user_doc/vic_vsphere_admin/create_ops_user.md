# Create the Operations User Account #

A virtual container host (VCH) requires the appropriate permissions in vSphere to perform various tasks during VCH operation. Deployment of a VCH requires a user account with vSphere administrator privileges. However, day-to-day operation of a VCH requires fewer vSphere permissions than deployment.

During deployment of a VCH, vSphere Integrated Containers Engine runs all deployment operations by using the vSphere administrator account that you specify in the `vic-machine create --user` or `--target` options. If you are using the Create Virtual Container Host wizard, it uses the vSphere administrator account with which you are logged into the vSphere Client. 

By default, if you deploy a VCH by using `vic-machine`, it runs with the same user account as you used to deploy it. In this case, the VCH uses the vSphere administrator account for post-deployment operations, meaning that it runs with full vSphere administrator privileges. Running with full vSphere administrator privileges is excessive, and potentially a security risk.

To avoid this situation, you should configure a VCH so that it uses different user accounts for deployment and for post-deployment operation by specifying an *operations user* when you deploy the VCH. By specifying an operations user with reduced vSphere privileges, you limit its post-deployment privileges to only those privileges that it needs for day-to-day operation.

- [How the Operations User Works](#behavior)
  - [Default Behavior](#default)
  - [Operations User Behavior](#ops-behavior)
- [Create a User Account for the Operations User](#createuser)

## How the Operations User Works <a id="behavior"></a>

If you specify an operations user, `vic-machine` and the VCH behave differently to how they would behave in a default deployment.

### Default Behavior <a id="default"></a>

- When you create a VCH by using `vic-machine`, you provide vSphere administrator credentials to `vic-machine create`, either in `--target` or in the `--user` and `--password` options. During deployment, `vic-machine create` uses these credentials to log in to vSphere and create the VCH. The VCH safely and securely stores the vSphere administrator credentials, for use in post-deployment operation.
- When you run other `vic-machine` commands on the VCH after deployment, for example, `vic-machine ls`, `upgrade`, or `configure`, you again provide the vSphere administrator credentials in the `--target` or `--user` and `--password` options. Again, `vic-machine` uses these credentials to log in to vSphere to retrieve the necessary information or to perform upgrade or configuration tasks on the VCH.
- When a container developer creates a container in the VCH, they authenticate with the VCH with their client certificate. In other words, the developer interacts with the VCH via the Docker client, and does not need to provide any vSphere credentials. However, the VCH uses the stored vSphere administrator credentials that you provided during deployment to log in to vSphere to create the container VM and to run operations on it.

### Operations User Behavior <a id="ops-behavior"></a>

- When you create a VCH, the Create Virtual Container Host wizard uses the vSphere administrator credentials with which you logged into vSphere Client to create the VCH. If you use `vic-machine`, you provide vSphere administrator credentials either in `vic-machine create --target` or in the `--user` and `--password` options. 
- You also provide the credentials for another vSphere account in the Operations User page of the Create Virtual Container Host wizard or in the `vic-machine create --ops-user` and `--ops-password` options. 
- During deployment, vSphere Integrated Containers Engine uses the vSphere administrator credentials to log in to vSphere and create the VCH. The operations user credentials are safely and securely stored in the VCH, for later use in post-deployment operation. In this case, the VCH does not store the vSphere administrator credentials.
- When you perform operations on the VCH after deployment, for example, `vic-machine ls`, `upgrade`, or `configure`, you provide the vSphere administrator credentials in the `--target` or `--user` and `--password` options. This is the same as in the default case. The stored operations user credentials are not used for these operations.
- When a container developer creates a container in the VCH, the VCH uses the stored operations user credentials to log in to vSphere to create the container VM and to run operations on it.

## Create a User Account for the Operations User <a id="createuser"></a>

The user account that you specify as the operations user must exist before you deploy the VCH. If you are deploying the VCH to a vCenter Server cluster, vSphere Integrated Containers Engine provides an option to automatically assign all of the required roles and permissions to the operations user account. 

**IMPORTANT**: If you are deploying the VCH to a standalone host that is managed by vCenter Server, rather than to a cluster, you must assign roles and permissions manually. For information about manually configuring the operations user account, see [Manually Create a User Account for the Operations User](ops_user_manual.md).

You can use the same user account as the operations user for multiple VCHs.

### Prerequisite

Log into the vSphere Client with a vSphere administrator account.

### Procedure

1. In Home page of the vSphere Web Client, click **Administration**.
2. Click **Users and Groups** in the Navigator menu.
3. Select the appropriate domain and click the button to add a new user.
4. Enter a user name for the operations user account, for example `vic-ops`.
5. Enter and confirm the password for this account, optionally provide the additional information, and click **OK**. 

### Result

You can use the new user as the operations user account for VCHs. You must use the option to grant any necessary permissions to the user account when you deploy the VCH.