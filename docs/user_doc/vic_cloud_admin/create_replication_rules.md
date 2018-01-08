# Create Replication Rules #

You replicate image repositories between vSphere Integrated Containers Registry instances by creating replication rules for projects. A replication rule identifies an endpoint registry to which to replicate images. 

- When you first enable a replication rule, all of the images in the project replicate to the endpoint registry. 
- If the project does not already exist on the remote registry, the rule creates a new project automatically.  
- After the initial synchronization between the registries, images that users push to the project on the source registry replicate incrementally to the endpoint registry. 
- If users delete images from the source registry, the replication rule deletes the image from the endpoint registry.
- Replication rules are unidirectional. To establish two-way replication, so that users can push images to either project and keep the projects in sync, you must create replication rules in both registry instances.

**Prerequisites**

- You have two vSphere Integrated Containers Registry instances, one that contains the images to replicate and one to act as the replication endpoint registry.
- You created at least one project, and pushed at least one image to that project.
- If the remote registry that you intend to use as the endpoint uses a self-signed or an untrusted certificate, you must disable certificate verification on the registry from which you are replicating. For example, disable certificate verification if the endpoint registry uses the default auto-generated certificates that vSphere Integrated Containers Registry created during the deployment of the vSphere Integrated Containers appliance. For information about disabling certificate verification, see [Configure System Settings](configure_system.md).

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials. 

   Use an account with Cloud Administrator privileges.
2. Select the **Administration** tab, click **Projects** on the left,  and click the name of the project to replicate.
3. Click **Registry Replication** and click the **+ Replication Rule** button.
4. Enter a suitable name for the new replication rule and optionally add a description.
5. Optionally, select the **Enable** checkbox.
5. Select or create an endpoint registry.

   - To select an existing endpoint registry, select an endpoint from the **Endpoint Name** drop-down menu.
     
    When you select an existing endpoint registry, the URL, user name and password are filled in automatically. If only one endpoint registry exists in the system, it is selected automatically. 

   - To create a new endpoint, select the **New Endpoint** check box.
     1. Enter a suitable name for the new replication endpoint.
     
     If you select **Enable**, replication starts immediately. You can track the progress of the replication in the list of **Replication Jobs**.

     2. Enter the full URL of the vSphere Integrated Containers Registry instance to set up as a replication endpoint.
 
		For example, https://<i>registry_address</i>:443.
     3. Enter the user name and password for the endpoint registry instance. 

		Use an account with Administrator privileges on that instance, or an account that has write permission on the corresponding project in the endpoint registry. If the project already exists and the replication user that you configure in the rule does not have write privileges in the target project, the replication fails.
     4. Optionally, select the **Verify Remote Cert** check box.

		Deselect if the remote registry uses a self-signed or untrusted certificate. 

6. Click **Test Connection**.
7. When you have successfully tested the connection click **OK**.
8. Click the icon in the **Logs** column for the replication job to check that replication succeeded without errors.

**Result**

Depending on the size of the images and the speed of the network connection, replication might take some time to complete. An image is not available in the endpoint registry until all of its layers have been synchronized from the source registry. If a replication job fails due to a network issue, vSphere Integrated Containers Registry reschedules the job to retry it a few minutes later.