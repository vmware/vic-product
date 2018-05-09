# Create Replication Rules #

You replicate image repositories between vSphere Integrated Containers Registry instances by creating replication rules for projects. A replication rule identifies an endpoint registry to which to replicate images. 

- When you first enable a replication rule, the selected images in the project replicate to the endpoint registry. 
- If the project does not already exist on the remote registry, the rule creates a new project automatically.  
- After the initial synchronization between the registries, images that users push to the project on the source registry replicate incrementally to the endpoint registry. 
- If users delete images from the source registry, the replication rule deletes the image from the endpoint registry.
- Replication rules are unidirectional. To establish two-way replication, so that users can push images to either project and keep the projects in sync, you must create replication rules in both registry instances.

**Prerequisites**

- You have two vSphere Integrated Containers Registry instances, one that contains the images to replicate and one to act as the replication endpoint registry.
- You created at least one project, and pushed at least one image to that project.
- You configured the target registry as a replication endpoint.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials. 

   Use an account with Cloud Administrator privileges.
2. Navigate to **Administration** > **Global Registries**,  and click **New Replication Rule**.
3. In the New Replication Rule dialog box, configure the new rule.
	1. Enter a suitable name for the new replication rule and optionally add a description.
	2. Enter the name of the project that uses the images you want to replicate.
	3. If you want to limit the repositories or tags for replication, select in the Source images filter field.
	4. Select an endpoint registry.
	5. From the **Trigger Mode** drop down menu, select your desired method for pushing to the endpoint.

	You can manually push, automatically replicate and delete images in the endpoint registry by selecting immeadiate and the respective options, or configure scheduled replication per your preference.

	6. Click **Save**.


**Result**

Depending on the size of the images and the speed of the network connection, replication might take some time to complete. An image is not available in the endpoint registry until all of its layers have been synchronized from the source registry. If a replication job fails due to a network issue, vSphere Integrated Containers Registry reschedules the job to retry it a few minutes later.