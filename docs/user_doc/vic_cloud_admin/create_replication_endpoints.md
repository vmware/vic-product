# Create Replication Endpoints #

To replicate image repositories from one instance of vSphere Integrated Containers Registry to another, you first create replication endpoints. A replication endpoint is a remote registry to which you replicate the images that a project contains.

You can create replication endpoints independently of projects, or you can create new endpoints when you create replication rule for a project. This procedure describes how to create endpoints independently of projects.

**Prerequisites**

- You deployed at least two instances of vSphere Integrated Containers Registry. 
-  If the remote registry that you intend to use as the endpoint uses a self-signed or an untrusted certificate, you must disable certificate verification on the registry from which you are replicating. For example, disable certificate verification if the endpoint registry uses the default auto-generated certificates that vSphere Integrated Containers Registry created during the deployment of the vSphere Integrated Containers appliance. For information about disabling certificate verification, see [Configure System Settings](configure_system.md).

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

   Use an account with Cloud Administrator privileges.
2. Select the **Administration** tab, click **Registries** > **Replication Endpoints** and click the **+ Endpoint** button.
3. Enter a suitable name for the new replication endpoint.
4. Enter the full URL of the vSphere Integrated Containers Registry instance to set up as a replication endpoint.

   For example, https://<i>registry_address</i>:443.

5. Enter the user name and password for the endpoint registry instance. 

   Use an account with Administrator privileges on that instance, or an account that has write permission on the corresponding project in the endpoint registry. 
6. Optionally, select the **Verify Remote Cert** check box.
   Deselect if the remote registry uses a self-signed or untrusted certificate. 
6. Click **Test Connection**.
7. When you have successfully tested the connection, click **OK**.

**Result**

The endpoint registry that you created is available for selection when you create replication rules for projects.

**What to Do Next**

Create a replication rule for a project.
