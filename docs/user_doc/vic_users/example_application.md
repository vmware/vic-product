# Example of Creating an Application from a Template #

This section illustrates how you can provision an application with a PostgreSQL container and a Tomcat container. The PostgreSQL container contains a form that use to collect data. The Tomcat container stores the data that is collected. 

## Prerequisities ##

Verify that you have perfomed the following steps:

- Deployed a virtual container host (VCH).
- Have a vCenter Server Single Sign-On user account with vSphere administrator privileges, or a user account that has been granted the Management Portal Administrator role in vSphere Integrated Containers.
- Created a project, assigned users to the project, and added the container host to the project.
- Created a volume with the name `webapp` and network with name `web`.

## Create an Application Template ##

Create an application template and add a PostgreSQL container and a Tomcat container to it.

Perform the following steps:

1. In the management portal, navigate to **Deployments** > **Applications** and click **+Application**.
2. On the Create a Template page, enter the application name `Postgres-DB-Application` and click **Proceed**.
2. In the Edit Template page, click **Add Container** and add a `postgres` container. For the steps to create the `postgres` container, see [Example of Provisioning a Single Container](example_container.md).
2. In the Edit Template page, click **Add Container**. Add a `tomacat` container.
2. Select the select the `tutum/tomcat` container and click **Continue**.
2. On the Basic tab, configure the following settings for the container:
    2. **Image**. The image that you want to instantiate the container from. This displays `registry.hub.docker.com/tutum/tomcat`. Select `latest` under tags.
    2. **Name**. Enter  `tomcat`.
    2. **Command**. Enter `curl -o https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war`.
2. On the Network tab, configure the following settings:
    2. **Port Bindings**. Enter `8080` for **Host Port** and `80` for **Container Port**.
    2. **Networks**. Select `web`.
2. On the Storage tab, in **Volumes**, enter `webapp` for **Host** and `/usr/local/tomcat/webapps` for **Container**.
2. On the Policy tab, select `Always` as the **Restart Policy**.
1. Click **Add** to add the container. 

Once you configure the two containers, they appear in the Edit Template page.

In the `tomcat` container that is created, click **+** next to **Links** and select `postgres` from the list. 

The `tomcat` container is now linked to the `postgres` container.

## Run the Application

Click the  ![PROVISION](ProvisionIcon.png) icon on the right hand top corner of the page to provision `Postgres-DB-Application`.