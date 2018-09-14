# Upgrade the vSphere Integrated Containers Appliance by Manually Copying Disks

By default, the upgrade script automatically copies the relevant disk files from the old appliance to the new appliance. As an alternative, you can perform the upgrade by manually copying disks from the old appliance to the new appliance. 

**IMPORTANT**: The recommended method of upgrading the appliance is to follow the procedure in [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). Only use the manual method if the fully automatic method fails.

Manually upgrading the vSphere Integrated Containers appliance requires you to copy disks from the old appliance VM to a new instance of the appliance. In vSphere Integrated Containers 1.2.x, the appliance has two disks. In vSphere Integrated Containers 1.3.x, the appliance has four disks. As a consequence, you must copy different disks between the appliances depending on whether you are upgrading from 1.2.x to 1.4.x, from 1.3.x to 1.4.x, or from 1.4.x to 1.4.y.

Because disk files are copied rather than moved, the old appliance is not affected by the upgrade process. You can keep it as a backup.

During a manual upgrade, all configurations that you made in vSphere Integrated Containers Management Portal and Registry in the previous installation transfer to the upgraded appliance. The old appliance is no longer functional after you move the disks.

**Prerequisites**

- You have completed the pre-upgrade tasks listed in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).
- Deploy the latest version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

    **IMPORTANT:**
    - Use the Flex-based vSphere Web Client to deploy the new version of the appliance. You cannot deploy OVA files from the HTML5 vSphere Client.
    - Deploy the appliance to the same vCenter Server instance as the one on which the previous version is running, or to a vCenter Server instance that is managed by the same Platform Services Controller.
    - Do not disable SSH access to the new appliance. You require SSH access to the appliance during the upgrade procedure.
    -  When the OVA deployment finishes, do not power on or initialize the new appliance. Attempting to perform the upgrade procedure on a new appliance that you have already initialized causes vSphere Integrated Containers Management Portal and Registry not to function correctly and might result in data loss. 
- Log in to the vSphere Client for the vCenter Server instance on which the previous version is running and on which you deployed the new version. 

**Procedure**

1.  In the **Hosts and Clusters** view of the vSphere Client, right-click the new version of the appliance and select **Edit Settings**.
2.  Depending on whether you are upgrading from 1.2.x or from 1.3.x and 1.4.x, remove the following hard disks from the new appliance.

    <table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>Disk to Remove</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.1, 1.3.x, and 1.4.x</td>
    <td>Hard disk 2</td>
    <td>Data disk</td>
  </tr>
  <tr>
    <td>1.3.x and 1.4.x</td>
    <td>Hard disk 3</td>
    <td>Database disk</td>
  </tr>
  <tr>
    <td>1.3.x and 1.4.x</td>
    <td>Hard disk 4</td>
    <td>Log disk. Migrating logs is optional.</td>
  </tr>
</table>

   1.  Hover your pointer over Hard disk 2 and click the **Remove** button on the right-hand side of the row.
   2.  If you are upgrading from 1.3.x or 1.4.x, hover your pointer over Hard disk 3 and Hard disk 4 and click the **Remove**
   3. For each disk that you remove, select the **Delete files from this datastore** checkbox.
   4. When you have marked all of the appropriate disks for removal, click **OK**.
2. In the Hosts and Clusters view, right-click the old version of the appliance and select **Power** > **Shut Down Guest OS**.

    **IMPORTANT**: Do not select **Power Off**.
3. Go to the **Storage** view of the vSphere Client, navigate to the datastore and datastore folder that contain the VM files for the old version of the appliance.
2. Use ctrl-click to select the relevant VMDK disk files from the older appliance.

    The VMDK files that you select depend on the type of upgrade that you are performing. 
  
    <table>
    <tr>
    <td><b>Upgrading From</b></td>
    <td><b>File to Select</b></td>
    <td><b>Description</b></td>
    </tr>
    <tr>
    <td>1.2.1, 1.3.x, and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>Hard disk 2, data disk</td>
    </tr>
    <tr>
    <td>1.3.x and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>Hard disk 3, database disk</td>
    </tr>
    <tr>
    <td>1.3.x and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>Hard disk 4, log disk. Migrating logs is optional.</td>
    </tr>
    </table>

4. Click **Copy to**, select the datastore folder of the new appliance as the destination, and click **OK**.
5. When the copy operation finishes, attach the disks from the old appliance to the new appliance.

    <table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>VMDK File</b></td>
    <td><b>Virtual Device Node</b></td>
  </tr>
  <tr>
    <td>1.2.1, 1.3.x, and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>SCSI(0:1)</td>
  </tr>
  <tr>
    <td>1.3.x and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>SCSI(0:2)</td>
  </tr>
  <tr>
    <td>1.3.x and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>SCSI(0:3)</td>
  </tr>
</table>

   1. In the **Hosts and Clusters** view, right-click the new appliance and select **Edit Settings**.
   2. Select the option to add a new disk:
     - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**.
     - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**. 
   3. Navigate to the datastore folder for the new appliance, select the <code>&lt;appliance_name&gt;_1.vmdk</code> disk file from the old appliance, and click **OK**.
   4. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:1)**.
   5. If you are upgrading from 1.3.x or 1.4.x, repeat the procedure to attach <code>&lt;appliance_name&gt;_2.vmdk</code> to **SCSI(0:2)** and <code>&lt;appliance_name&gt;_3.vmdk</code> to **SCSI(0:3)**.
   6. Click **OK**.

6. Power on the new version of the vSphere Integrated Containers appliance and wait a few minutes for it to boot. 

    **IMPORTANT**: After the new appliance has booted, do not log in to the appliance welcome page. Logging in to the appliance welcome page initializes the appliance. Initialization is only applicable to new installations and causes upgraded appliances not to function correctly.

7. Use SSH to connect to the new appliance as root user.
    <pre>$ ssh root@<i>new_vic_appliance_address</i></pre>

    When prompted for the password, enter the appliance password that you specified when you deployed the new version of the appliance. 
8. Navigate to the `/etc/vmware/upgrade` folder.<pre>$ cd /etc/vmware/upgrade</pre>
9. Run the upgrade script, specifying the `--manual-disks` flag.<pre>$ ./upgrade.sh --manual-disks</pre>
    
    If you attempt to run the script while the appliance is still initializing and you see the following message, wait for a few more minutes, then attempt to run the script again.

    <pre>Appliance services not ready. Please wait until vic-appliance-load-docker-images.service has completed.</pre>

    You can bypass some or all of the following steps by specifying additional optional arguments when you run the upgrade script. For information about the arguments that you can specify, see [Specify Command Line Options During Appliance Upgrade](upgrade_appliance.md#upgradeoptions).

3. Enter the IP address or FQDN of the vCenter Server instance on which you deployed the new appliance.
4. Enter the Single Sign-On user name and password of a vSphere administrator account.

    The script requires these credentials to access the disk files of the old appliance, and to register the new version of vSphere Integrated Containers with the VMware Platform Services Controller.
4. If vCenter Server is managed by an external Platform Services Controller, enter the IP address or FQDN and the administrator domain of the Platform Services Controller.

    If vCenter Server is managed by an embedded Platform Services Controller, press Enter at each prompt without entering anything.

5. Enter **y** if the vCenter Server certificate thumbprint is legitimate.
6. To automatically upgrade the vSphere Integrated Containers plug-in for vSphere Client, enter `y` at the prompt to `Upgrade VIC UI Plugin`.

    **NOTE**: The option to automatically upgrade the  plug-in for the vSphere Client is available in vSphere Integrated Containers 1.4.3 and later. If you you enter `n` to skip the plug-in upgrade, you can upgrade the plug-in later. If you are upgrading to a version of vSphere Integrated Containers that pre-dates 1.4.3, you must upgrade the plug-in manually.
7. Verify that the upgrade script has detected your upgrade path correctly.        
  - If the script detects your upgrade path correctly, enter `y` to proceed with the upgrade.
  - If the upgrade script detects the upgrade path incorrectly, enter `n` to abort the upgrade and contact VMware support.

**Result**

After you see confirmation that the upgrade has completed successfully, the upgraded appliance initializes. When the upgraded appliance has initialized, you can access its appliance welcome page at http://<i>new_appliance_address</i>.

**What to Do Next**

- Click **Go to the vSphere Integrated Containers Management Portal** in the appliance welcome page, and use vCenter Server Single Sign-On credentials to log in.

  - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
  - In the **Administration** tab, check that projects, registries, repositories, and replication configurations have migrated successfully.
- If, in the previous version, you configured vSphere Integrated Containers Registry instances as replication endpoints, upgrade the appliances that run those registry instances. Replication of images from the new registry instance to the older replication endpoint still functions, but it is recommended that you upgrade the target registry.
- Download the new vSphere Integrated Containers Engine bundle and upgrade  your VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- If you upgraded to vSphere Integrated Containers 1.4.3 or later and answered `y` at the prompt to `Upgrade VIC UI Plugin`, access the  vSphere Integrated Containers plug-in for vSphere Client:
   1. Log out of the HTML5 vSphere Client and log back in again. You should see a banner that states `There are plug-ins that were installed or updated`.
   2. Log out of the HTML5 vSphere Client a second time and log back in again.
   3. Click the **vSphere Client** logo in the top left corner. 
   4. Under Inventories, click **vSphere Integrated Containers** to access the vSphere Integrated Containers plug-in.
   5. In the **vSphere Integrated Containers** > **Summary** tab, check that the plug-in is at the correct version.
- If you upgraded to vSphere Integrated Containers 1.4.3 or later and answered `n` at the prompt to `Upgrade VIC UI Plugin`, and you want to upgrade the plug-in later, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md). 
- If you upgraded to a version of vSphere Integrated Containers that pre-dates 1.4.3, manually upgrade the vSphere Integrated Containers plug-in for the vSphere Client. For information about manually upgrading the vSphere Client plug-in, see [Manually Upgrade the vSphere Client Plug-In](upgrade_plugins.md).
  
    **IMPORTANT**: vSphere Integrated Containers 1.4.2 includes version 1.4.1 of the vSphere Integrated Containers plug-in for vSphere Client. If you are upgrading vSphere Integrated Containers from version 1.4.1 to 1.4.2, you must still upgrade the client plug-in after you upgrade the appliance. This is so that the plug-in registers correctly with the upgraded appliance. If you do not upgrade the plug-in after upgrading the appliance to 1.4.2, the vSphere Integrated Containers view does not appear in the vSphere Client. 

**Troubleshooting**

If upgrade fails, generate a log bundle and obtain the upgrade log to provide to VMware support. For information about obtaining the logs, see [Access and Configure Appliance Logs](appliance_logs.md).