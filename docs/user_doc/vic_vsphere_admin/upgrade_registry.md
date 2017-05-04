# Upgrade vSphere Integrated Containers Registry 0.5 to 1.1.x #

If you deployed version 0.5 of vSphere Integrated Containers Registry (Harbor) with vSphere Integrated Containers 1.0, you can upgrade your existing installation to version 1.1.x.

**Prerequisites**

- You have a vSphere Integrated Containers Registry 0.5 installation that you deployed by using the official OVA installer from vSphere Integrated Containers 1.0.
- Back up the previous appliance by using your usual backup tools.
- Deploy the new vSphere Integrated Containers 1.1 appliance by using the OVA installer. For information about using the OVA installer, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md). 

   - Deploy the  1.1 appliance in a location in which it can access the VMDK files of the 0.5 appliance.
   - In the **Appliance Security** section of the **Customize template** page of the installer, do not disable SSH access to the 1.1 appliance.
   - In the **Registry Configuration** section of the installer, make sure that you provide the same passwords in the **Registry Admin Password** and **Database Password** as the 0.5 appliance uses. 
- Log in to a vSphere Web Client instance from which you can access both of the vSphere Integrated Containers Registry 0.5 and 1.1 vSphere Integrated Containers appliances. 
- If you use vSphere 6.5, log in to the Flex-based vSphere Web Client, not the HTML5 vSphere Client.


**Procedure**


1. Shut down the vSphere Integrated Containers Registry 0.5 appliance by selecting **Shut Down Guest OS**.

   **IMPORTANT**: Do not select **Power Off**.
4. Right-click the new vSphere Integrated Containers 1.1 appliance, and select **Edit Settings**.
5. Click the **New device** drop-down menu at the bottom of the Edit Settings wizard, select **Existing Hard Disk**, and click **Add**.
6. Navigate to the VDMK files of the 0.5 appliance, select one of the VMDK files, and click **OK**.

    You can select either VMDK file. The order of selection is not important.
7. Expand the entry for **New Hark disk** and make sure that the new disk is attached as **Virtual Device Node** `SCSI(0:2)`.
8. Click **Existing Hard Disk** > **Add** again, select the other VMDK file, and click **OK**.
9. Make sure that the new disk is attached as **Virtual Device Node** `SCSI(0:3)` and click **OK** to close the Edit Settings window.
11. Power on the vSphere Integrated Containers 1.1 appliance, then use SSH to connect to it as root user.<pre>$ ssh root@<i>vic_appliance_address</i></pre>
13. Run the upgrade script and respond to the prompts until you see confirmation that the upgrade is complete.<pre>$ /etc/vmware/harbor/upgrade_from_0.5.sh</pre>
9. Shut down the vSphere Integrated Containers 1.1 appliance, and edit its settings to detach the two VDMK files that you attached above.
9. Power on the vSphere Integrated Containers 1.1 appliance to complete the upgrade.

**What to Do Next**

Log into the new version of vSphere Integrated Containers Registry at https://<i>vic_1.1_appliance_address</i>:443 to verify that the data from your vSphere Integrated Containers Registry 0.5 installation has migrated successfully.

