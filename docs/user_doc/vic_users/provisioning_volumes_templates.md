# Provisioning Container Volumes Using Templates

You can use templates to provision container volumes in the management portal. 

If you have some persistent data that you want to share between containers, or want to use data from non-persistent containers, you can create a named Data Volume and then mount the data from it.

## Prerequisites

- Verify that you can log in to vSphere Integrated Containers Management Portal with a vSphere administrator, Management Portal administrator, or DevOps administrator account.
 
    For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](../vic_cloud_admin/logging_in_mp.md).

- You have created a project and provisioned containers on it.

## Procedure

1.	In the management portal, navigate to **Your-project** > **Templates** 
2.	Create a blank template.
3.	Within the template, click **Add Volume** to add the required volumes.
4.	Edit the container template. In the **Storage** tab, configure the following properties:
    - **Volumes**: You can specify the volume you created earlier.
    - **Volumes From**: You can select volumes from another container that you want to use.
    - **Working Directory**: Specify the working directory where you want to run commands.
