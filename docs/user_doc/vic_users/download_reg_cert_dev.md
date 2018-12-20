# Download the vSphere Integrated Containers Registry CA Certificate

To access vSphere Integrated Containers Registry from Docker clients, you need to download the CA certificate for the registry instance that is running in the vSphere Integrated Containers appliance.

**Procedure**

1. Log in to vSphere Integrated Containers Management Portal with an account that has the Developer or DevOps Administrator role.
1. Depending on your role, you can download the certificate from different places.

   - Developer and DevOps Administrator: Go to **Home** > **Library** > **Built-in Repositories**.
   - DevOps Administrator: Go to **Administration** > **Projects** > *project* > **Internal Repositories**.

2. Click the **Registry Certificate** download link.

**What to Do Next**

You must configure your Docker client to use this certificate so that you can connect to the registry. For information about configuring the Docker client, see the [Install the vSphere Integrated Containers Registry Certificate](../vic_app_dev/configure_docker_client.md#registry) in *Developing Applications with vSphere Integrated Containers*.