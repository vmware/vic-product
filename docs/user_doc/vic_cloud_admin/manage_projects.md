# Configure Project Settings #

After you have created a project, you can modify its configuration. You can perform the following actions on a project: 

- Toggle a project between the public and private states at different stages of the development process.
- Enable or disable Docker content trust. vSphere Integrated Containers Registry provides a Docker Notary server that allows you to implement content trust by signing and verifying the images in the registry. For information about Docker Notary, see [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/) in the Docker documentation.
- Configure vulnerability scanning on the images in the project. For more information about vulnerability scanning, see  [Vulnerability Scanning](vulnerability_scanning.md).
- When you no longer require a project, you can delete it.

**Prerequisites**

- Log in to vSphere Integrated Containers Management Portal with a vSphere administrator, Management Portal administrator, or DevOps administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).
- You have a created project.

**Procedure**

1. Navigate to **Administration** > **Projects** > **Your_project**.
4. Click the **Configuration** tab to change the project settings.
	1. If you want to make all repositories of that project public, select the **Public** check box.
	2. If you want to prevent unsigned images from the project repositories from being run, select the **Enable content trust** check box.
	3. If you want to prevent vulnerable images from your project repository from running, select the **Prevent vulnerable images from running** check box.
	4. (Optional) Change the severity level of vulnerabilities found that prevents an image from running.
	
		Images cannot be run if their level equals the currently selected level or higher.
	5. If you want to activate an immediate vulnerability scan on new images that are pushed to the project registry, select the **Automatically scan images on push** check box.

5.  To delete a project, on the Projects page, click the three dots next to a project and click **Delete**.

**NOTE**: If you enable content trust on a project, the developers who work on that project must configure their Docker clients so that they can connect to the Notary server running in vSphere Integrated Containers Registry. For information about how to configure Docker clients for content trust, see the section on [Using vSphere Integrated Containers Registry with Content Trust](../vic_app_dev/configure_docker_client.md#notary) in Configure the Docker Client for Use with vSphere Integrated Containers, in *Developing Applications with vSphere Integrated Containers*.

**What to Do Next**

- [Manage Internal Repositories in Projects](manage_repository_registry.md)
- [Access and Search Project Logs](access_project_logs.md)
  


