# Upgrade the vSphere Integrated Containers Appliance # 

If you deployed a 1.1.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to a later 1.1.y update release.

**Prerequisites**

- You have a previous vSphere Integrated Containers Registry 1.1.x installation that you deployed by using the official OVA installer.
- Deploy the new version of the vSphere Integrated Containers appliance by using the OVA installer for that version. For information about using the OVA installer, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md). 

   - Deploy the new version of the appliance in a location in which it can access the VMDK files of the previous appliance.
   - In the **Appliance Security** section of the **Customize template** page of the installer for the the 1.1.y appliance, do not disable SSH access.
   - In the **Registry Configuration** section of the installer, make sure that you provide the same passwords in the **Registry Admin Password** and **Database Password** as the previous appliance uses. 
- Log in to a vSphere Web Client instance from which you can access both versions of the vSphere Integrated Containers appliance. 
- If you use vSphere 6.5, log in to the Flex-based vSphere Web Client, not the HTML5 vSphere Client.

**Procedure**

1. Shut down the previous vSphere Integrated Containers Registry appliance by selecting **Shut Down Guest OS**.

   **IMPORTANT**: Do not select **Power Off**.
4. Right-click the previous vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
6. Navigate to the VDMK files of the previous appliance, select one of the VMDK files, and click **OK**.

    You can select either VMDK file. The order of selection is not important.
7. Expand the entry for **New Hark disk** and make sure that the new disk is attached as **Virtual Device Node** `SCSI(0:2)`.
8. Click **Existing Hard Disk** > **Add** again, select the other VMDK file, and click **OK**.
9. Make sure that the new disk is attached as **Virtual Device Node** `SCSI(0:3)` and click **OK** to close the Edit Settings window.
11. Power on the vSphere Integrated Containers 1.1 appliance, then use SSH to connect to it as root user.<pre>$ ssh root@<i>vic_appliance_address</i></pre>
13. Run the upgrade script and respond to the prompts until you see confirmation that the upgrade is complete.<pre>$ /etc/vmware/harbor/upgrade_from_0.5.sh</pre>
9. Shut down the vSphere Integrated Containers 1.1 appliance, and edit its settings to detach the two VDMK files that you attached above.
9. Power on the vSphere Integrated Containers 1.1 appliance to complete the upgrade.

**What to Do Next**

Log into the new versions of vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal to verify that the data from your previous vSphere Integrated Containers installation has migrated successfully.