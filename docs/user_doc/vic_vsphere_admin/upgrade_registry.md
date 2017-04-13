# Upgrade vSphere Integrated Containers Registry #

If you deployed version 0.5 of vSphere Integrated Containers Registry with vSphere Integrated Containers 1.0, you can upgrade your existing installation to version 1.1.

**Prerequisites**

- You have a vSphere Integrated Containers Registry 0.5 installation that you deployed by using the official OVA installer from vSphere Integrated Containers 1.0.
- Deploy the new vSphere Integrated Containers 1.1 appliance by using the OVA installer. For information about using the OVA installer, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md). 

    **IMPORTANT**: 
    - Deploy the  1.1 appliance in a location in which it can access the VMDK files of the 0.5 appliance.
    - In the **Registry Configuration** section of the **Customize template** page of the installer, make sure that you provide the same passwords in the **Registry Admin Password** and **Database Password** as the vSphere Integrated Containers Registry 0.5 appliance uses.
    - When the OVA deployment is complete, do not log in to any of the new vSphere Integrated Containers components. The upgrade does not work if there is any fresh data in the new appliance.

**Procedure**

2. Log in to a vSphere Web Client instance from which you can access both of the vSphere Integrated Containers Registry 0.5 and 1.1 vSphere Integrated Containers appliances. 

    If you use vSphere 6.5, log in to the Flex-based vSphere Web Client, not the HTML5 vSphere Client.
1. Shut down both appliances.
4. Right-click the new vSphere Integrated Containers 1.1 appliance, and select **Edit Settings**.
5. Click the **New device** drop-down menu, select **Existing Hard Disk**, and click **Add**.
6. Navigate to the VDMK files of the 0.5 appliance, select one of the VMDK files, and click **OK**.

    You can select either VMDK file. The order of selection is not important.
7. Expand the entry for **New Hark disk** and make sure that the new disk is attached as **Virtual Device Node** `SCSI(0:2)`.
8. Click **Existing Hard Disk** > **Add** again, navigate to the VDMK files of the 0.5 appliance, select the other VMDK file, and click **OK**.
9. Expand the second **New Hark disk** entry and make sure that the new disk is attached as **Virtual Device Node** `SCSI(0:3)`.
10. Click **OK** to close the Edit Settings window.
11. Power on the vSphere Integrated Containers 1.1 appliance and launch a VM console to monitor the upgrade process.
8. When prompted in the VM console, shut down the vSphere Integrated Containers 1.1 appliance, and edit its settings to detach the two VDMK files that you attached above.
9. Power on the vSphere Integrated Containers 1.1 appliance to complete the upgrade.

**What to Do Next**

Log into the new version of vSphere Integrated Containers Registry at https://<i>vic_1.1_appliance_address</i>:443 to verify that the data from your vSphere Integrated Containers Registry 0.5 installation has migrated successfully.

