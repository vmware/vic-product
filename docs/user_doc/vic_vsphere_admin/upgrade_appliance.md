# Upgrade the vSphere Integrated Containers Appliance # 

If you deployed a 1.1.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.2.x.

To upgrade an instance of vSphere Integrated Containers Registry 0.5 (Harbor) that you deployed with vSphere Integrated Containers 1.0, see [Upgrade vSphere Integrated Containers Registry 0.5 to 1.2.x](upgrade_registry.md).

**Prerequisites**

- You have an existing vSphere Integrated Containers 1.1.x appliance that you deployed by using the official OVA installer.
- Back up the previous appliance by using your usual backup tools.
- Deploy the new version of the vSphere Integrated Containers appliance to a location in which it can access the VMDK files of the previous appliance. For information about using the OVA installer, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md). 

   **IMPORTANT**: In the **Registry Configuration** section of the installer, make sure that you provide the same passwords in the **Registry Admin Password** and **Database Password** as the previous appliance uses. 

- Log in to a vSphere Web Client instance from which you can access both versions of the vSphere Integrated Containers appliance. If you use vSphere 6.5, log in to the Flex-based vSphere Web Client, not the HTML5 vSphere Client.

**Procedure**

1. Shut down both of the previous and new vSphere Integrated Containers appliances by selecting **Shut Down Guest OS**.

   **IMPORTANT**: Do not select **Power Off**.
4. Right-click the previous vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Hover your mouse over **Hard disk 2**, click the **Remove** button, and click **OK**.

   Hard disk 2 is the larger of the two disks.
   
   **IMPORTANT**: Do not check the **Delete files from this datastore** checkbox.
5. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
5. Hover your mouse over **Hard disk 2**, click the **Remove** button, and check the **Delete files from this datastore** checkbox.
5. Click the **New device** drop-down menu at the bottom of the Edit Settings wizard, select **Existing Hard Disk**, and click **Add**.
6. Navigate to the VDMK files of the previous appliance, select the VMDK file with the file name that ends in `_1`, and click **OK**.
7. Click **OK** again to update the VM settings.
9. Power on the new appliance to complete the upgrade.

**What to Do Next**

Log into the new versions of vSphere Integrated Containers Registry and vSphere Integrated Containers Management Portal to verify that the data from your previous vSphere Integrated Containers installation has migrated successfully.