# Add Container Hosts #

As a Management Portal administrator, you can add existing Docker hosts or vSphere Integrated Containers virtual container hosts (VCHs) to projects. After adding the hosts, you can provision containers, view live stats and manage the hosts in the Management Portal.

You must only add a given VCH to one project at a time. Adding the same VCH to multiple projects can lead to conflicts if the registry lists and content trust setttings are different in the different projects.

For more information about adding container hosts, see [Add Container Hosts to Projects](../vic_cloud_admin/vchs_and_mgmt_portal.md)

**Procedure**

1. In the management portal, navigate to **Deployments** > **Networks** and click **+ Network**.
2. On the Create Network page, select the **Advanced** check box to access all available settings.
2. Configure the following settings:
    
      - **Name**: Name of the container host in the project
      - **Description**: Description of the container host. 
      - **Type**: Type of container host. Select **VCH** or **Docker** from the list.
      - **URL**: The IP Address of the container host.
      - **Credentials**: The signed certificates that you used while creating the VCH.
 
1. Clck **Save**.

**Result**

The container host is added to your project. 