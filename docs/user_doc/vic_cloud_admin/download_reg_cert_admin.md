# Download the vSphere Integrated Containers Registry Certificate

To configure a VCH or Docker client so that it can connect to vSphere Integrated Containers Registry, you must obtain the registry certificate and pass it to the VCH when you create that VCH, or to the Docker client.

When you deployed the vSphere Integrated Containers appliance, vSphere Integrated Containers Registry auto-generated a Certificate Authority (CA) certificate. You can download the registry CA certificate from the vSphere Integrated Containers Management Portal.

**Procedure**

1. Log in with a vSphere administrator or Management Portal administrator user account.

    vSphere administrator accounts for the Platform Service Controller with which vSphere Integrated Containers is registered are automatically granted the Management Portal administrator role.
2. You can download the certificate from different locations.

    - Go to **Administration** > **Configuration**, and click the link to download the **Registry Root Certificate**. This option is only available to vSphere administrators and Management Portal administrator.
    - Go to **Administration** > **Projects** > *project* > **Internal Repositories** and click the **Registry Certificate** button. This option is available to Management Portal administrators and users with the DevOps Administrator role.
    - Go to **Home** > **Library** > **Built-in Repositories** and click the **Registry Certificate** button. This option is available to Management Portal administrators and users with the DevOps Administrator or Developer roles.
    
**What to Do Next**

- For information about how vSphere administrators deploy VCHs so that they can access a private registry, see [Configure Registry Access](../vic_vsphere_admin/vch_registry.md) in *vSphere Integrated Containers for vSphere Administrators*.
- For information about how to configure the Docker client to use the certificate, see the [Install the vSphere Integrated Containers Registry Certificate](../vic_app_dev/configure_docker_client.md#registry) in *Developing Applications with vSphere Integrated Containers*.
