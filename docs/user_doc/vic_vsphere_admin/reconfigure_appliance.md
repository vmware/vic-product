# Reconfigure the vSphere Integrated Containers Appliance #

After you have deployed the vSphere Integrated Containers appliance, you can reconfigure the settings that you provided to the OVA installer during deployment. You can also reconfigure the appliance VM itself, for example to expand the size of the different disks, or to increase memory and processing power.

**Prerequisites**

- Log in to a vSphere Web Client instance for the vCenter Server instance on which the vSphere Integrated Containers appliance is running.
- If you use vSphere 6.5, log in to the Flex-based vSphere Web Client, not the HTML5 vSphere Client.

**Procedure**

1. Shut down the vSphere Integrated Containers appliance by selecting **Shut Down Guest OS**.

   **IMPORTANT**: Do not select **Power Off**.
4. Right-click the new vSphere Integrated Containers appliance, and select **Edit Settings**.
5. In the **Virtual Hardware** tab, reconfigure the appliance VM as necessary.

   - Increase the number of CPUs
   - Increase the amount of RAM
   - Increase the size of any of the hard disks, as necessary

6. Click **vApp Options** to modify the settings that you provided when you used the OVA installer to deploy the appliance.

   - In **Appliance Security**, update the password for the appliance root account, enable or disable SSH log in.
   - Reconfigure **Networking Properties** to set a static IP address, update the network configuration, or remove all settings to enable DHCP.
   - Reconfigure **Registry Configuration** to enable or disable vSphere Integrated Containers Registry, change the ports on which the registry publishes services, update the admin and database passwords, enable or disable garbage collection, or update the certificate and key.
   - Reconfigure **Management Portal Configuration** to enable or disable vSphere Integrated Containers Management Portal, change the port on which the portal publishes services, or update the certificate and key.
   - Reconfigure **File Server Configuration** to change the port on which the file server publishes the vSphere Integrated Containers Engine download, or update the certificate and key.

   **NOTE**: It is not recommended to modify the **Deployment** and **Authoring** settings.

7. Click **OK** to close the Edit Settings window.
8. Power on the vSphere Integrated Containers appliance to complete the reconfiguration.

**Result**

When the appliance powers on, the new settings are automatically applied. If you resized one or more of the hard disks, the appliance automatically handles the partitioning of the disks during the boot process.  