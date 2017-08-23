# Create a Project in vSphere Integrated Containers #

In vSphere Integrated Containers Registry, you group container image repositories in projects. A project contains all of the repositories that an application requires. You cannot push images to vSphere Integrated Containers Registry until you have created a project. 

**NOTE**: The current version of vSphere Integrated Containers Engine does not support `docker push`. To push images to vSphere Integrated Containers Registry, use a regular Docker client. You can then pull the images from the registry to a vSphere Integrated Containers Engine virtual container host (VCH).

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

   Use an account with Cloud Administrator privileges.
2. Select the **Administration** tab, click **Projects** on the left, then click the **+ Project** button.
3. Provide a name for the project.
4. (Optional) Check the **Public** check box to make the project public.

   If you set the project to **Public**, any user can pull images from this project. If you leave the project set to **Private**, only users who are members of the project can pull images. You can toggle projects from public to private, or the reverse, at any moment after you create the project.
5. Click **OK**.

**Result**

When you create a new project, you are automatically assigned the Project Admin role for that project.

The project is added to the list of projects. You can browse existing projects by limiting the list to only display public projects, or filter the list by entering text in the **Filter** text box.

**What to Do Next**

You can add users to the project, push images to the project, browse the repositories that the project contains, view the project logs, and set up image replication. 