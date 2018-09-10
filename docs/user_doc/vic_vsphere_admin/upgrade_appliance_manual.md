# Upgrade the vSphere Integrated Containers Appliance by Manually Moving Disks

By default, the upgrade script copies the relevant disk files from the old appliance to the new appliance. As an alternative, you can perform the upgrade by manually moving disks from the old appliance to the new appliance rather than by copying them. 

**IMPORTANT**: The recommended method of upgrading the appliance is to follow the procedure in [Upgrade the vSphere Integrated Containers Appliance](upgrade_appliance.md). Use the manual method if the fully automatic method fails.

Manually upgrading the vSphere Integrated Containers appliance requires you to remove disks from the old appliance VM and move them to a new instance of the appliance. In vSphere Integrated Containers 1.2.x, the appliance has two disks. In vSphere Integrated Containers 1.3.x, the appliance has four disks. As a consequence, you must move different disks between the VMs depending on whether you are upgrading from 1.2.x to 1.4.x, or from 1.3.x to 1.4.x.

During a manual upgrade, all configurations that you made in vSphere Integrated Containers Management Portal and Registry in the previous installation transfer to the upgraded appliance. The old appliance is no longer functional after you move the disks.

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

2. Depending on the type of upgrade you are performing, remove the appropriate disks from the older appliance.
  
   1. Right-click the older vSphere Integrated Containers appliance, and select **Edit Settings**. 
   2. Hover your pointer over the appropriate disk and click the **Remove** button on the right.
   3. **IMPORTANT**: Do not check the **Delete files from this datastore** checkbox for any of the disks that you remove.
   4. When you have marked the appropriate disks for removal, click **OK**.
 
  <table>
<tr>
<td><b>Upgrading From</b></td>
<td><b>Disk to Remove</b></td>
<td><b>Description</b></td>
</tr>
<tr>
<td>1.2.1 and 1.3.x</td>
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

3. Depending on the type of upgrade you are performing, remove the corresponding disks from the new appliance.

   1. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
   2. Hover your pointer over the appropriate disk and click the **Remove** button.
   3. For each disk that you remove, select the **Delete files from this datastore** checkbox.
   4. When you have marked the appropriate disks for removal, click **OK**.

  <table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>Disk to Remove</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.1 and 1.3.x</td>
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

4. Move the appropriate VMDK files for the disk or disks from the older appliance into the datastore folder of the new appliance.

   1. In the **Storage** view of the vSphere Client, navigate to the folder that contains the VDMK files of the older appliance.
   2. Select the appropriate VMDK file or files, click **Move to...**, and move the disk into the datastore folder of the new appliance.

  <table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>File to Move</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.1 and 1.3.x</td>
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

5. Add the appropriate disk or disks from the old appliance to the new appliance.

   1. In the **Hosts and Clusters** view of the vSphere Client, right-click the new appliance and select **Edit Settings**.
   2. Select the option to add a new disk:
     - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
     - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**. 
   3. Navigate to the datastore folder into which you moved the disk or disks, select the disk or disks from the previous appliance, and click **OK**.
   4. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:1)**.
   5. Repeat the procedure to attach <code>&lt;appliance_name&gt;_2.vmdk</code> to **SCSI(0:2)** and <code>&lt;appliance_name&gt;_3.vmdk</code> to **SCSI(0:3)**.

  <table>
  <tr>
    <td><b>Upgrading From</b></td>
    <td><b>VMDK File</b></td>
    <td><b>Virtual Device Node</b></td>
    <td><b>Description</b></td>
  </tr>
  <tr>
    <td>1.2.1 and 1.3.x</td>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>SCSI(0:1)</td>
    <td>Hard disk 2, data disk</td>
  </tr>
  <tr>
    <td>1.3.x and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>SCSI(0:2)</td>
    <td>Hard disk 3, database disk</td>
  </tr>
  <tr>
    <td>1.3.x and 1.4.x</td>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>SCSI(0:3)</td>
    <td>Hard disk 4, log disk. Migrating logs is optional.</td>
  </tr>
</table>

6. Power on the new version of the vSphere Integrated Containers appliance and wait for it to initialize. 

    Initialization can take a few minutes.

    **IMPORTANT**: After the new appliance has initialized, do not go to the Getting Started page of the appliance. Logging in to the Getting Started page for the first time initializes the appliance. Initialization is only applicable to new installations and causes upgraded appliances not to function correctly.

7. Use SSH to connect to the new appliance as root user.
    <pre>$ ssh root@<i>new_vic_appliance_address</i></pre>

    When prompted for the password, enter the appliance password that you specified when you deployed the new version of the appliance. 
8. Navigate to the upgrade script and run it with the `--manual-disks` flag. 

    <pre>$ cd /etc/vmware/upgrade</pre>
    <pre>$ ./upgrade.sh --manual-disks</pre>

    You can bypass the following steps by specifying additional optional arguments when you run the upgrade script. For information about the arguments that you can specify, see [Specify Command Line Options During Appliance Upgrade](upgrade_appliance.md#upgradeoptions).
    
    If you attempt to run the script while the appliance is still initializing and you see the following message, wait for a few more minutes, then attempt to run the script again.

    <pre>Appliance services not ready. Please wait until vic-appliance-load-docker-images.service has completed.</pre>

9. Provide information about the new version of the appliance.

    1. Enter the IP address or FQDN of the vCenter Server instance on which you deployed the new appliance. 
    2. Enter the Single Sign-On user name and password of a vSphere administrator account.

    The script requires these credentials to access the disk files of the old appliance, and to register the new version of vSphere Integrated Containers with the VMware Platform Services Controller.
3. Provide information about the Platform Services Controller.

    - If vCenter Server is managed by an external Platform Services Controller, enter the IP address or FQDN of the Platform Services Controller.
    - If vCenter Server is managed by an embedded Platform Services Controller, press Enter without entering anything.
4. If applicable, provide the Platform Services Controller domain.

    - If vCenter Server is managed by an external Platform Services Controller, enter the administrator domain for the Platform Services Controller.
    - If vCenter Server is managed by an embedded Platform Services Controller, press Enter without entering anything.
5. Enter **y** if the vCenter Server certificate thumbprint is legitimate.
6. Provide information about the old version of the appliance.

    1. Enter the name of the datacenter that contains the old version of the appliance.
    2. Enter the IP address of the old version of the appliance. The upgrade script does not accept FQDN addresses for the old appliance.
    3. For the old appliance user name, enter `root`.
6. To automatically upgrade the vSphere Integrated Containers plug-in for vSphere Client, enter `y` at the prompt to `Upgrade VIC UI Plugin`.

    **NOTE**: The option to automatically upgrade the  plug-in for the vSphere Client is available in vSphere Integrated Containers 1.4.3 and later. However, if you are already running other instances of the vSphere Integrated Containers appliance that are of a different version, enter `n` to skip the plug-in upgrade. You can upgrade the plug-in manually later. If you are upgrading to a version of vSphere Integrated Containers that pre-dates 1.4.3, you must upgrade the plug-in manually.
7. Verify that the upgrade script has detected your upgrade path correctly.        
  - If the script detects your upgrade path correctly, enter `y` to proceed with the upgrade.
  - If the upgrade script detects the upgrade path incorrectly, enter `n` to abort the upgrade and contact VMware support.

**Result**

After you see confirmation that the upgrade has completed successfully, the upgraded appliance initializes. When the upgraded appliance has initialized, you can access its Getting Started page at http://<i>new_appliance_address</i>.

**What to Do Next**

- Click **Go to the vSphere Integrated Containers Management Portal** in the Getting Started page, and use vCenter Server Single Sign-On credentials to log in.

  - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
  - In the **Administration** tab, check that projects, registries, repositories, and replication configurations have migrated successfully.
- If, in the previous version, you configured vSphere Integrated Containers Registry instances as replication endpoints, upgrade the appliances that run those registry instances. Replication of images from the new registry instance to the older replication endpoint still functions, but it is recommended that you upgrade the target registry.
- Download the vSphere Integrated Containers Engine bundle and upgrade  your VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- Upgrade the vSphere Integrated Containers plug-in for the vSphere Client. For information about upgrading the vSphere Client plug-in, see [Manually Upgrade the vSphere Client Plug-In](upgrade_plugins.md).