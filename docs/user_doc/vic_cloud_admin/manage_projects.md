# Manage Projects #

After you have created a project, you can toggle the project between the public and private states as well as turning security options on and off. When you no longer require a project, you can delete it.

**Prerequisites**

You have a created project.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.
2. Navigate to **Administration** > **Projects** > **Your_project**.
4. Click the **Configuration** tab to change the project settings.
	1. If you want to make all repositories of that project public, select the **Public** check box.
	2. If you want to prevent unsigned images from the project repositories of being run, select the **Enable content trust** check box.
	3. If you want to prevent vulnerable images from your project repository to run, select the **Prevent vulnerable images from running** check box.
	4. (Optional) Change the severity level of vulnerabilities found that prevents an image to run.
	
		Images cannot be run if their level equals the currently selected level or higher.
	5. If you want to activate an immediate vulnerability scan on new images that are pushed to the project registry, select the **Automatically scan images on push** check box.

5.  To delete a project, on the Projects page, click the three dots next to a project and click **Delete**.

  


