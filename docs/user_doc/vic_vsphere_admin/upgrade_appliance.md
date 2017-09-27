# Upgrade the vSphere Integrated Containers Appliance

If you deployed a 1.1.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.2.x. You can also upgrade a 1.2.x appliance to a later 1.2.y update release.

Upgrading the vSphere Integrated Containers appliance upgrades vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal. For information about the vSphere Integrated Containers Registry and Management Portal data that migrates during upgrade, see [Data That Migrates During vSphere Integrated Containers Appliance Upgrade](upgrade_data.md).

**NOTE**: This procedure reflects changes to the upgrade procedure that were introduced in vSphere Integrated Containers 1.2.1. Do not attempt to upgrade to version 1.2.0.

**Prerequisites**

- You have completed the pre-upgrade tasks listed in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).
- Deploy the new version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

    **IMPORTANT:**
    - Do not disable SSH access to the new appliance. You require SSH access to the appliance during the upgrade procedure.
    -  When the OVA deployment finishes, do not power on the new appliance. Attempting to perform the upgrade procedure on a new appliance that you have already powered on and initialized causes vSphere Integrated Containers Management Portal and Registry not to function correctly and might result in data loss. 

- Use the Flex-based vSphere Web Client to deploy the appliance. You cannot deploy OVA files from the HTML5 vSphere Client or from the legacy Windows client.
- Deploy the appliance to the same vCenter Server instance as the one on which the previous version is running, or to a vCenter Server instance that is managed by the same Platform Services Controller.
- Log in to the vSphere Client for the vCenter Server instance on which the previous version is running and on which you deployed the new version. 

**Procedure**

2. Shut down the older vSphere Integrated Containers appliance by selecting **Shut Down Guest OS**.

     **IMPORTANT**: Do not select **Power Off**.
4. Right-click the older vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Hover your pointer over **Hard disk 2**, click the **Remove** button, and click **OK**.

     - Hard disk 2 is the larger of the two disks.
     - **IMPORTANT**: Do not check the **Delete files from this datastore** checkbox.

5. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Hover your pointer over **Hard disk 2**, click the **Remove** button, and check the **Delete files from this datastore** checkbox, and click **OK**.
6. In the **Storage** view of the vSphere Client, move the disk from the previous appliance into the datastore folder of the new appliance.

     1. Navigate to the VDMK files of the previous appliance.
     2. Select the VMDK file with the file name that ends in `_1`
     3. Click **Move to...**, and move it into the datastore folder of the new appliance.
5. In the **Hosts and Clusters** view of the vSphere Client, right-click the new appliance and select **Edit Settings** again to add the disk from the old appliance to the new appliance. 

   - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
   - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**. 
6. Navigate to the datastore folder into which you moved the disk, select the VMDK file from the previous appliance, and click **OK**.
7. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:1)**, then click **OK**.
9. Power on the new vSphere Integrated Containers appliance and note its address.

    **IMPORTANT**: Do not go to the Getting Started page of the appliance. Logging in to the Getting Started page for the first time initializes the appliance. Initialization is only applicable to new installations and causes upgraded appliances not to function correctly. 
10. Use SSH to connect to the new appliance as root user.

    <pre>$ ssh root@<i>new_vic_appliance_address</i></pre>

    When prompted for the password, enter the appliance password that you specified when you deployed the new version of the appliance. 

11. Navigate to the upgrade script and run it. 

    <pre>$ cd /etc/vmware/upgrade</pre>
    <pre>$ ./upgrade.sh</i></pre>

     As the script runs, respond to the prompts to provide the following information: 

     1. Enter the address of the vCenter Server instance on which you deployed the new appliance.
     2. Enter the Single Sign-On user name and password of a vSphere administrator account. The script requires these credentials to register the new version of vSphere Integrated Containers with the VMware Platform Services Controller.
     3. If vCenter Server is managed by an external Platform Services Controller, enter the FQDN of the Platform Services Controller. If vCenter Server is managed by an embedded Platform Services Controller, press Enter without entering anything.
     4. If vCenter Server is managed by an external Platform Services Controller, enter the administrator domain for the Platform Services Controller. If vCenter Server is managed by an embedded Platform Services Controller, press Enter without entering anything.
     5. Verify that the upgrade script has detected your upgrade path correctly.  
      
         If the upgrade script detects that you are performing an upgrade from 1.1.x to 1.2.y, it migrates 1.1.x data to the new data model for 1.2.y. If it detects an upgrade from 1.2.x to 1.2.y, the data model is the same, so no data migration is required. 
      
       - If the script detects your upgrade path correctly, enter `y` to proceed with the upgrade.
       - If the upgrade script detects the upgrade path incorrectly, for example if it asks you to proceed with an upgrade from 1.1.x to 1.2.y when you are upgrading 1.2.x to 1.2.y, enter `n` to abort the upgrade and follow the procedure in [Troubleshooting vSphere Integrated Containers Appliance Upgrade](troubleshoot_appliance_upgrade.md).

11. When you see confirmation that the upgrade has completed successfully, go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and use vCenter Server Single Sign-On credentials to log in.

     - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
     - In the **Administration** tab, check that projects, registries, repositories, and replication configurations have migrated successfully.
12. When you have confirmed that the upgrade succeeded, delete the appliance VM for the previous version from the vCenter Server inventory.

**What to Do Next**

- If, in the previous version, you configured vSphere Integrated Containers Registry instances as replication endpoints, upgrade those registry instances. Replication of images from the 1.2.x registry instance to the 1.1.x replication endpoint still functions, but it is recommended that you upgrade the target registry.
- Due to changes in the data model, user identity management, and the merging of the user interfaces for vSphere Integrated Containers Registry and Management Portal in version 1.2.x, you must perform some manual tasks after you upgrade the appliance. For information about post-upgrade tasks, see [Tasks to Perform After Upgrading the vSphere Integrated Containers Appliance](post_upgrade_tasks.md).  
- Download the vSphere Integrated Containers Engine bundle and upgrade  your VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- Upgrade the vSphere Integrated Containers plug-in for the HTML5 vSphere Client. For information about upgrading the vSphere Client plug-in, see 

   - [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md)
   - [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md)