# Create New Volumes #

You can create, modify, and attach volume configurations to containers and container templates. When you create a volume, you add a volume that you have configured on the virtual container host (VCH).

You can create the following types of volumes:

- Image datastore
- Volume datastore

For more information about the volumes, see [Virtual Container Host Storage Capacity](../vic_vsphere_admin/vch_storage.md)

**Procedure**

1. In the management portal, navigate to **Deployments** > **Volumes** and click **+Volume**.
2. On the Create Volume page, select the **Advanced** check box to access all available settings.
2. Configure the following settings:
    - **Name**. Enter a name for the volume.
    - **Driver**. The vSphere Integrated Containers Backend Engine. When using a vSphere Integrated Containers Engine VCH as your Docker endpoint, the storage driver is always the vSphere Integrated Containers Engine Backend Engine.
    - **Driver Options**. Enter the capacity in megabytes, gigabytes, or terabytes.
    - **Custom Properties**. Optionally specify custom properties for the new volume configuration. 
    - **Hosts** | Select the hosts to use the new volume.
3. Click **Create**.


**Result**

The new volume is created and you can provision containers on it.