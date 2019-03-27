# Creating New Volumes #

You can create, modify, and attach volume configurations to containers and container templates. When you create a volume, you add volume datastores and image datastores that you have configured on the virtual container host (VCH).

You can also configure volume drivers. Volume drivers allow you to store volumes on remote hosts or cloud providers, to encrypt the contents of volumes, or to add other functionality. Configure one of the following volume drivers:

- local - The default built-in `local` driver. Volumes created by this driver have a local scope, which means that they can be accessed only by containers on the same host.
- vsphere - The default driver for VIC. `local` is an alias for `vsphere`.
- Third-party plugins - The Management Portal does not support third-party volume plugins officially but it is possible to create and use volumes based on such plugins.

For more information about the volumes, see [Virtual Container Host Storage Capacity](../vic_vsphere_admin/vch_storage.md)

**Procedure**

1. In the management portal, navigate to **Deployments** > **Volumes** and click **+Volume**.
2. On the Create Volume page, select the **Advanced** check box to access all available settings.
2. Configure the following settings:
    - **Name**. Enter a name for the volume.
    - **Driver**. The volume driver that you want to use for the container. 
    - **Driver Options**. Enter the capacity in megabytes, gigabytes, or terabytes.
    - **Custom Properties**. Optionally specify custom properties for the new volume configuration. 
    - **Hosts** | Select the hosts to use the new volume.
3. Click **Create**.


**Result**

The new volume is created and you can provision containers on it.