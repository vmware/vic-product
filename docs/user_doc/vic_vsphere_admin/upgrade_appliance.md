# Upgrade the vSphere Integrated Containers Appliance

If you deployed a 1.1.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.2.x. You can also upgrade a 1.2.x appliance to a later 1.2.y update release.

Upgrading the vSphere Integrated Containers appliance upgrades vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal. For information about the vSphere Integrated Containers Registry and Management Portal data that migrates during upgrade, see [Data That Migrates During vSphere Integrated Containers Appliance Upgrade](upgrade_data.md).

**Prerequisites**

- You have completed the pre-upgrade tasks listed in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).
- Deploy the new version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

    **IMPORTANT:** When the OVA deployment finishes, do not power on the new appliance. Attempting to perform the upgrade procedure on a new appliance that you have already powered on and initialized causes vSphere Integrated Containers Management Portal and Registry not to function correctly and might result in data loss. 

- You can only deploy one vSphere Integrated Containers appliance per vCenter Server instance. However, when upgrading, you should deploy the appliance to the same vCenter Server instance as the one on which the previous version is running.
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
5. Right-click the new appliance and select **Edit Settings** again to add the disk from the old appliance to the new appliance. 

   - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
   - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**. 
6. Navigate to the VDMK files of the previous appliance, select the VMDK file with the file name that ends in `_1`, and click **OK**.
7. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:1)**, then click **OK**.
9. Power on the new vSphere Integrated Containers appliance and note its address.

    **IMPORTANT**: Do not go to the Getting Started page of the appliance. Logging in to the Getting Started page for the first time initializes the appliance. Initialization is only applicable to new installations and causes upgraded appliances not to function correctly. 
10. Use SSH to connect to the new appliance as root user.

    <pre>$ ssh root@<i>new_vic_appliance_address</i></pre>

11. Navigate to the upgrade script and run it. 

    <pre>$ cd /etc/vmware/upgrade</pre>
    <pre>$ ./upgrade_1.1_to_1.2.sh</i></pre>

     When prompted, enter the address of the vCenter Server instance on which you deployed the new appliance and the Single Sign-On credentials of a vSphere administrator account. The script requires these credentials to register the new version of vSphere Integrated Containers with the vSphere Platform Services Controller.

11. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and use vCenter Server Single Sign-On credentials to log in.

     - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
     - In the **Administration** tab, check that projects and registries have migrated successfully.
        
        **IMPORTANT**: If you added vSphere Integrated Containers Registry to the previous version of the vSphere Integrated Containers Management Portal,  and if the address of the appliance changed during the upgrade, two instances of vSphere Integrated Containers Registry appear in the **Administration** > **Registries** > **Source Registries** view. The registry named `default-vic-registry` is the new registry instance, that is running in the new appliance. Data from the old registry has migrated to this instance. Another registry instance with the address of the old appliance is also present in the list of registries. You must delete this instance.
   


**What to Do Next**

- Download the vSphere Integrated Containers Engine bundle and upgrade VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- Upgrade the vSphere Integrated Containers plug-in for the HTML5 vSphere Client. For information about upgrading the vSphere Client plug-in, see [Upgrade the HTML5 vSphere Client Plug-In on vCenter Server for Windows](upgrade_h5_plugin_windows.md) or [Upgrade the HTML5 vSphere Client Plug-In on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md), depending on the type of vCenter Server that you use.
