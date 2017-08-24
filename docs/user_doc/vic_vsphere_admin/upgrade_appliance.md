# Upgrade the vSphere Integrated Containers Appliance

If you deployed a 1.1.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.2.x. You can also upgrade a 1.2.x appliance to a later 1.2.y update release.

Upgrading the vSphere Integrated Containers appliance upgrades vSphere Integrated Containers Registry and vSphere Integrated Containers Management portal.

To upgrade an older version of the appliance, you deploy a new appliance instance. The appliance upgrade process migrates vSphere Integrated Containers Registry and Management Portal data from the older appliance to the new appliance. For information about the data that migrates during upgrade, see [Data That Migrates During vSphere Integrated Containers Appliance Upgrade](upgrade_data.md).

**Prerequisites**

- You have an older version of the vSphere Integrated Containers appliance that you need to upgrade.
- Back up the older appliance by using your usual backup tools.
- Obtain the user name and password for the embedded vSphere Integrated Containers Registry database that runs in the older appliance.
- Deploy the new version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

    **IMPORTANT:** When the OVA deployment finishes, do not power on the new appliance. Attempting to perform the upgrade procedure on a new appliance that you have already powered on and initialized causes vSphere Integrated Containers Management Portal and Registry not to function correctly and might result in data loss. 

- Log in to a vSphere Client instance from which you can access both versions of the vSphere Integrated Containers appliance.

**Procedure**

2. Shut down the older vSphere Integrated Containers appliance by selecting **Shut Down Guest OS**.

     **IMPORTANT**: Do not select **Power Off**.
4. Right-click the older vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Hover your pointer over **Hard disk 2**, click the **Remove** button, and click **OK**.

     - Hard disk 2 is the larger of the two disks.
     - **IMPORTANT**: Do not check the **Delete files from this datastore** checkbox.

5. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Hover your pointer over **Hard disk 2**, click the **Remove** button, and check the **Delete files from this datastore** checkbox, and click **OK**.
5. Right-click the new appliance and select **Edit Settings** again to add the disk from the old appliance to the new appliance. 

   - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
   - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**. 
6. Navigate to the VDMK files of the previous appliance, select the VMDK file with the file name that ends in `_1`, and click **OK**.
7. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:1)**, then click **OK**.
9. Power on the new vSphere Integrated Containers appliance, note its address, and use SSH to connect to it as root user.

    <pre>$ ssh root@new_vic_appliance_address</pre>

11. Navigate to the upgrade script and run it. 

    <pre>$ cd /etc/vmware/upgrade</pre>
    <pre>$ ./upgrade_1.1_to_1.2.sh --dbuser root --dbpass <i>registry_db_password</i> --target <i>vcenter_server_address</i> --username <i>vcenter_server_sso_username</i> --password <i>vcenter_server_sso_password</i></pre>

     When you run the script you must specify the following arguments:

    - `--dbuser` and `--dbpassword`: The user name and password for the embedded database from the previous deployment of the vSphere Integrated Containers Registry. The script requires these credentials to log into the embedded database from the previous version to extract its data.
    - `--target`, `--username`, and `--password`: The address and Single Sign-On credentials of the vCenter Server instance on which you deployed the new appliance. The script requires these credentials to register the new version of vSphere Integrated Containers with the vSphere Platform Services Controller.
10. When the upgrade finishes, go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and use vCenter Server Single Sign-On credentials to log in.

**What to Do Next**

- In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
- In the **Administration** tab, check that projects, registries, and replication rules have migrated successfully.
- **IMPORTANT**: If you added vSphere Integrated Containers Registry to the previous version of the vSphere Integrated Containers Management Portal, you must update the address of that registry to reflect the address of the new vSphere Integrated Containers appliance. 
   
    1. Go to **Administration** > **Registries** > **Source Registries**
    1. Hover your pointer over an instance of vSphere Integrated Containers Registry, and click the **Edit** icon.
    1. Update the address of the registry to reflect the address of the new vSphere Integrated Containers appliance.
- Upgrade the vSphere Integrated Containers plug-in for the HTML5 vSphere Client.
- Download the vSphere Integrated Containers Engine bundle and upgrade VCHs.
- After you have verified that the upgrade succeeded, you can delete the previous version of the appliance. 