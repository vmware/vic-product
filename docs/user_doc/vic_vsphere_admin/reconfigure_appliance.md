# Reconfigure the vSphere Integrated Containers Appliance #

After you have deployed the vSphere Integrated Containers appliance, you can reconfigure the settings that you provided to the OVA installer during deployment. You can also reconfigure the appliance VM itself, for example to expand the size of the different disks, or to increase memory and processing power.

**Prerequisites**

Log in to the vSphere Client:

- If you use vCenter Server 6.7 update 1 or later, you can use the HTML5 vSphere Client to reconfigure the appliance.
- If you use a version of vCenter Server that pre-dates 6.7 update 1, you must use the Flex-based vSphere Web Client. You cannot reconfigure the appliance in the HTML5 vSphere Client .

**Procedure**

1. Shut down the vSphere Integrated Containers appliance by selecting **Shut Down Guest OS**.

   **IMPORTANT**: Do not select **Power Off**.
4. Right-click the vSphere Integrated Containers appliance VM, and select **Edit Settings**.
5. In the **Virtual Hardware** tab, reconfigure the appliance VM as necessary.

   - Increase the number of CPUs
   - Increase the amount of RAM
   - Increase the size of any of the hard disks, as necessary

6. Modify the settings that you provided when you deployed the appliance.

  In the Flex-based vSphere Web Client, stay in the Edit Settings window and select **vApp Options**. 
  
  In the HTML5 vSphere Client (vCenter Server 6.7 update 1 and later), you access the vApp Options as follows:
  
  1. Exit the Edit Settings window.
  1. Select the appliance VM and select the **Configure** tab.
  1. Select **vApp Options** and scroll to the Properties section.
  1. Click **Category** to sort the settings into the order in which they appear in the OVA installer.
  1. For each setting that you want to change, select the corresponding row and click **Set Value**.
 
  You can modify the following settings:

   - In **Appliance Configuration**, update the password for the appliance root account, enable or disable SSH log in, and add or update certificates.
   - Reconfigure **Networking Properties** to set a static IP address, update the network configuration, or remove all settings to enable DHCP.
   - Reconfigure **Registry Configuration** to change the ports on which the registry publishes services, or to enable or disable garbage collection.
   - Reconfigure **Management Portal Configuration** to change the port on which the portal publishes services.
   - Reconfigure **Create Example Users** to enable or disable the creation of example users, update the user name prefix, or change the password.

   **NOTE**: It is not recommended to modify the **Deployment** and **Authoring** settings.

**Result**

When you power the appliance back on, the new settings are automatically applied. If you resized one or more of the hard disks, the appliance automatically handles the partitioning of the disks during the boot process.  