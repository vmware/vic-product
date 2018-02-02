# Upgrade the vSphere Integrated Containers Appliance

If you have a 1.2.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.3.x. You can also upgrade a 1.3.x release to a later 1.3.y update release.

During the upgrade, all configurations transfer to the upgraded appliance.

**Prerequisites**

- You have completed the pre-upgrade tasks listed in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).
- Deploy the latest version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

    **IMPORTANT:**
    - Do not disable SSH access to the new appliance. You require SSH access to the appliance during the upgrade procedure.
    -  When the OVA deployment finishes, do not power on the new appliance. Attempting to perform the upgrade procedure on a new appliance that you have already powered on and initialized causes vSphere Integrated Containers Management Portal and Registry not to function correctly and might result in data loss. 
- Use the Flex-based vSphere Web Client to deploy the appliance. You cannot deploy OVA files from the HTML5 vSphere Client or from the legacy Windows client.
- Deploy the appliance to the same vCenter Server instance as the one on which the previous version is running, or to a vCenter Server instance that is managed by the same Platform Services Controller.
- Log in to the vSphere Client for the vCenter Server instance on which the previous version is running and on which you deployed the new version. 

**Procedure**

1. Shut down the older vSphere Integrated Containers appliance by selecting **Shut Down Guest OS**.

     **IMPORTANT**: Do not select **Power Off**.

5. Depending on the type of upgrade you are performing, remove the appropriate disks from the older appliance.<table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>Disk to Remove</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.x and 1.3.x</td>
    <td>Hard disk 2</td>
    <td>Data disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td>Hard disk 3</td>
    <td>Database disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td>Hard disk 4</td>
    <td>Log disk. Migrating logs is optional.</td>
  </tr>
</table>
    1. Right-click the older vSphere Integrated Containers appliance, and select **Edit Settings**. 
    2. Hover your pointer over the appropriate disk and click the **Remove** button on the right.
    
        **IMPORTANT**: Do not check the **Delete files from this datastore** checkbox for any of the disks that you remove.
    3. When you have marked the appropriate disks for removal, click **OK**. 

5. Depending on the type of upgrade you are performing, remove the corresponding disks from the new appliance.<table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>Disk to Remove</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.x and 1.3.x</td>
    <td>Hard disk 2</td>
    <td>Data disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td>Hard disk 3</td>
    <td>Database disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td>Hard disk 4</td>
    <td>Log disk. Migrating logs is optional.</td>
  </tr>
</table>

    1. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
    2. Hover your pointer over the appropriate disk and click the **Remove** button.
    2. For each disk that you remove, select the **Delete files from this datastore** checkbox.
    3. When you have marked the appropriate disks for removal, click **OK**.

6. Move the appropriate VMDK files for the disk or disks from the older appliance into the datastore folder of the new appliance.<table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>File to Move</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.x and 1.3.x</td>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>Hard disk 2, data disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>Hard disk 3, database disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>Hard disk 4, log disk. Migrating logs is optional.</td>
  </tr>
</table>

     1. In the **Storage** view of the vSphere Client, navigate to the folder that contains the VDMK files of the older appliance.
     2. Select the appropriate VMDK file or files, click **Move to...**, and move the disk into the datastore folder of the new appliance.

5. Add the appropriate disk or disks from the old appliance to the new appliance.<table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>VMDK File</b></td>
    <td><b>Virtual Device Node</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.x and 1.3.x</td>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>SCSI(0:1)</td>
    <td>Hard disk 2, data disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>SCSI(0:2)</td>
    <td>Hard disk 3, database disk</td>
  </tr>
  <tr>
    <td>1.3.x</td>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>SCSI(0:3)</td>
    <td>Hard disk 4, log disk. Migrating logs is optional.</td>
  </tr>
</table>

   1. In the **Hosts and Clusters** view of the vSphere Client, right-click the new appliance and select **Edit Settings**.
   2. Select the option to add a new disk:
      - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
      - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**. 
   2. Navigate to the datastore folder into which you moved the disk or disks, select <code>&lt;appliance_name&gt;_1.vmdk</code> from the previous appliance, and click **OK**.
   3. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:1)**.
   4. Repeat the procedure to attach <code>&lt;appliance_name&gt;_2.vmdk</code> to **SCSI(0:2)** and <code>&lt;appliance_name&gt;_3.vmdk</code> to **SCSI(0:3)**.

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
       - If the script detects your upgrade path correctly, enter `y` to proceed with the upgrade.
       - If the upgrade script detects the upgrade path incorrectly, enter `n` to abort the upgrade and contact VMware support.

11. When you see confirmation that the upgrade has completed successfully, go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and use vCenter Server Single Sign-On credentials to log in.

     - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
     - In the **Administration** tab, check that projects, registries, repositories, and replication configurations have migrated successfully.

12. When you have confirmed that the upgrade succeeded, delete the appliance VM for the previous version from the vCenter Server inventory.

**What to Do Next**

- If, in the previous version, you configured vSphere Integrated Containers Registry instances as replication endpoints, upgrade those registry instances. Replication of images from the 1.3.x registry instance to the 1.2.x replication endpoint still functions, but it is recommended that you upgrade the target registry.
- Download the vSphere Integrated Containers Engine bundle and upgrade  your VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- Upgrade the vSphere Integrated Containers plug-ins for the vSphere Client. For information about upgrading the vSphere Client plug-ins, see 

   - [Upgrade the vSphere Client Plug-Ins on vCenter Server for Windows](upgrade_h5_plugin_windows.md)
   - [Upgrade the vSphere Client Plug-Ins on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md)
