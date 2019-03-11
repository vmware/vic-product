# Back Up and Restore the vSphere Integrated Containers Appliance

The vSphere Integrated Containers appliance runs various services, such as vSphere Integrated Containers Management Portal, vSphere Integrated Containers Registry, the API for the vSphere Client plug-in, and the Web server for the appliance welcome page and vSphere Integrated Containers Engine download. The appliance has four virtual disks attached to it:

|Disk No.|Path|Node|Description|
|---|---|---|---|
|1|`/`|SCSI(0:0)|The root disk, that contains the operating system and application state of the vSphere Integrated Containers appliance.|
|2|`/storage/data/`|SCSI(0:1)|A data disk that contains, among other things, the vSphere Integrated Containers Registry instance that is running in the appliance.|
|3|`/storage/db/`|SCSI(0:2)|A database disk that contains the MYSQL, Clair, and Notary databases for vSphere Integrated Containers Registry.|
|4|`/storage/log/`|SCSI(0:3)|A logging disk that contains the logs for the different vSphere Integrated Containers components.|

The separation of different types of data between disks allows you to upgrade the appliance with an existing data disk from a previous installation. It also allows you to back up and restore the different disks separately, if necessary.

The recommended way to back up the appliance is to copy the base disks. You can then restore the appliance by attaching the cloned disks to a new instance of the appliance.

<!--

## Copy the OVF Environment Configuration

You can create a backup of the appliance VM by copying and safeguarding the OVF environment file, `ovfEnv`.

### Procedure

HTML5 vSphere Client (vSphere 6.7u1 and later):

1. In the Hosts and Clusters view of the vSphere Client, select the appliance VM and click **Configure**.
1. Expand Settings and select **vApp Options**.
1. Scroll down to OVF Settings and click **View OVF Environment**.
1. Copy the contents of the `ovfEnv` file and save it to a safe location.
    
Flex-based vSphere Web Client:

1. In the Hosts and Clusters view of the vSphere Client, right-click the appliance VM and select **Edit Settings**.
1. Select **vApp Options** and ensure that **Enable vApp Options** is selected.
1. Expand **OVF Settings** and click the **View** button in the OVF Environment row.
1. Copy the contents of the `ovfEnv` file and save it to a safe location.

## Restoring the Appliance from the OVF Environment File

You can restore the appliance VM by importing an OVF environment file that you have saved as a backup. You can use the vCenter Server Managed Object Browser (MOB), PowerCLI, or `govc` to import the backup of an `ovfEnv` file into the appliance.

-->

## Copy the Base Disks 

You can copy the base disks manually by copying the VMDK files in the vSphere Client. 

### Procedure

1. Right-click the appliance VM and elect **Power** > **Shut Down Guest OS** to shut down the appliance VM.  

  **IMPORTANT**: Do not select **Power Off**.   

  You must shut down the VM in order to quiesce the database before the backup. Also, if you use NFS datastores, you cannot copy disk files while the VM is powered on.    
1. Go to the **Storage** view of the vSphere Client and navigate to the datastore and datastore folder that contain the VM files for the version of the appliance that you want to back up.
2. Use ctrl-click to select the following VMDK disk files from the old version of the appliance.

    <table>
    <tr>
    <td><b>File to Select</b></td>
    <td><b>Description</b></td>
    </tr>
    <tr>
    <td><code>&lt;appliance_name&gt;.vmdk</code></td>
    <td>Hard disk 1, root disk</td>
    </tr>
    <tr>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>Hard disk 2, data disk</td>
    </tr>
    <tr>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>Hard disk 3, database disk</td>
    </tr>
    <tr>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>Hard disk 4, log disk. Migrating logs is optional.</td>
    </tr>
    </table>

4. Click **Copy to**, select a target datastore folder in which to copy the backup disk files, and click **OK**.
  
Alternatively, you can use `vmkfstools` to clone the disks and manually copy the VM configurations. For information about using `vmkfstools`, see [Using vmkfstools
](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.storage.doc/GUID-A5D85C33-A510-4A3E-8FC7-93E6BA0A048F.html) in the vSphere documentation.

## Restoring Cloned Disks ##

To restore the appliance from cloned disks, deploy a new instance of the vSphere Integrated Containers appliance of the same version as the one you backed up. You then copy the cloned VMDK files into the new appliance datastore and attach them to the appropriate virtual device nodes on the new appliance VM. 

**IMPORTANT**: After you deploy the new instance of the appliance, do not power it on. If you do power it on, power off without filling in the Complete VIC appliance installation panel, that registers the appliance with vCenter Server.

### Procedure

1. Right-click the new appliance VM and select **Edit Settings**.
2. Remove the hard disks from the new appliance.

    <table>
  <tr>
    <td><b>Disk to Remove</b></td>
    <td><b>Description</b></td>
  </tr>
    <tr>
    <td>Hard disk 1</td>
    <td>Root disk</td>
  </tr>
  <tr>
    <td>Hard disk 2</td>
    <td>Data disk</td>
  </tr>
  <tr>
    <td>Hard disk 3</td>
    <td>Database disk</td>
  </tr>
  <tr>
    <td>Hard disk 4</td>
    <td>Log disk.</td>
  </tr>
</table>

   1.  Hover your pointer over each hard disk and click the **Remove** button on the right-hand side of the row.
   2.  For each disk, select the **Delete files from this datastore** checkbox.
   3. When you have marked the disks for removal, click **OK**.
1. Go to the **Storage** view of the vSphere Client and navigate to the datastore and datastore folder that contain the backup disk files that you copied from the old appliance.
1. Select the appropriate VDMK files and click **Copy to** to copy the backup VMDK files to the datastore folder of the new appliance.
1. Attach the backup VMDK files to the appropriate nodes on the new  appliance.

    <table>
  <tr>
    <td><b>VMDK File</b></td>
    <td><b>Virtual Device Node</b></td>
  </tr>
    <tr>
    <td><code>&lt;appliance_name&gt;.vmdk</code></td>
    <td>SCSI(0:0)</td>
  </tr>
  <tr>
    <td><code>&lt;appliance_name&gt;_1.vmdk</code></td>
    <td>SCSI(0:1)</td>
  </tr>
  <tr>
    <td><code>&lt;appliance_name&gt;_2.vmdk</code></td>
    <td>SCSI(0:2)</td>
  </tr>
  <tr>
    <td><code>&lt;appliance_name&gt;_3.vmdk</code></td>
    <td>SCSI(0:3)</td>
  </tr>
</table>

   1. In the **Hosts and Clusters** view, right-click the  appliance and select **Edit Settings**.
   2. Select the option to add a new disk:
     - HTML5 vSphere Client: Click the **Add New Device** button and select **Existing Hard Disk**.
     - Flex-based vSphere Web Client: Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**. 
   3. Navigate to the datastore folder for the appliance, select the backup version of the <code>&lt;appliance_name&gt;.vmdk</code> disk file, and click **OK**.
   4. Expand **New Hard Disk** and make sure that the Virtual Device Node for the disk is set to **SCSI(0:0)**.
   5. Repeat the procedure to attach <code>&lt;appliance_name&gt;_1.vmdk</code> to **SCSI(0:1)**,  <code>&lt;appliance_name&gt;_2.vmdk</code> to **SCSI(0:2)**, and <code>&lt;appliance_name&gt;_3.vmdk</code> to **SCSI(0:3)**.
   6. Click **OK**.
1. Power on the new appliance VM.   

## Take Snapshots of the Appliance VM

The appliance disks are not independent of the appliance VM, so if you take a snapshot of the appliance VM, it also takes snapshots of all of the disks. 

You must shut down the appliance VM before you take the snapshot. Taking snapshots while the appliance is running can result in the appliance coming back up in an inconsistent state if you restore it from a snapshot.

**IMPORTANT**: It is not recommended to use snapshots as your main backup method. Use snapshots only for short-term, temporary backups. For more information see the best practices for using snapshots in [VMware KB 1025279](https://kb.vmware.com/s/article/1025279).

### Procedure

1. Right-click the appliance VM and elect **Power** > **Shut Down Guest OS** to shut down the appliance VM.  

  **IMPORTANT**: Do not select **Power Off**.
1. Take a snapshot of the appliance VM.
1. Power on the appliance VM.