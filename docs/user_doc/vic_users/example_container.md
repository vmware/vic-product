# Example of Provisioning a Single Container #

This section illustrates how you can provision a PostgreSQL container using templates.

## Prerequisities ##

Verify that you have perfomed the following steps:

- Deployed a virtual container host (VCH).
- Have a vCenter Server Single Sign-On user account with vSphere administrator privileges, or a user account that has been granted the Management Portal Administrator role in vSphere Integrated Containers.
- Created a project and assigned users to the project.
- Added the container host to the project.

## Create a Volume ##

Create a volume called `pgdata`.

1. In the management portal, navigate to **Deployments** > **Volumes** and click **+Volume**.
2. On the Create Volume page, select the **Advanced** check box to access all available settings.
2. Configure the following settings:
    - **Name**. Enter `pgdata` as the volume name.
    - **Hosts**. Select the host from the list.
3. Click **Create**.

## Create a Network ##

1. In the management portal, navigate to **Deployments** > **Networks** and click **+Network**.
2. On the Create Network page, configure the following settings:
    - **Name**. Enter `datanet` as the network name.
    - **Hosts**. Select the host from the list.
3. Click **Create**.

## Create a Template ##

Create a template and add the `postgres` container to it.

1. In the management portal, navigate to **Library** > **Templates** and click **+Template**.
2. On the Create a Template page, enter the container name, for example, `Postgres-container` and click **Proceed**. 
2. In the Edit Template page, click **Add Container**. 
2. In the Add Container Definition page, select the `library/postgres` container and click **Continue**.

## Configure the Template ##

2. In the Edit Container Defintion page, configure the basic details:
    2. **Image**. The image that you want to instantiate the container from. This displays `registry.hub.docker.com/library/postgres`. Select the version. For example, `9.6`.
    2. **Name**. Displays the name that you entered, `Postgres-container`.
1. On the Network tab, configure the following:
    1. Select **Publish All Ports**.
    1. In the list under **Networks**, select **Add Network**. 
    1. Select the **Existing** checkbox and click in the search field under **Name** to see a list of added networks. Select `datanet` from the list 
1. On the Storage tab, in **Volumes**, enter `pgdata` as **Host** and `/var/lib/postgresql/data` as **Container**.
1. On the Policy tab, configure the following:
    1. Select `Always` under **Restart Policy**.
    1. Enter `2` for **CPU Shares**.
    1. Enter `4 GB` for **Memory Limit**.
1. On the Environment tab, configure **Environment Variables**. Enter `POSTGRES_PASSWORD` in **Name** and the password in **Value**.
1. Click **Add** to add the container.
 
## Provision the Template ##

Once you configure the template, the container and the network and volume that you have configured appear in the Edit Template page.

Click the  ![PROVISION](ProvisionIcon.png) icon on the right hand top corner of the page to provision `Postgres-container`.
