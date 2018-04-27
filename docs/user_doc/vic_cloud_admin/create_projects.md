# Create a Project in vSphere Integrated Containers #

In vSphere Integrated Containers, you create different projects to which you assign users, repositories, and infrastructure. You also set up replication of registries in projects, and configure project-specific settings. When you first deploy vSphere Integrated Containers, a default public project named default-project is created. 


**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials.

   Use an account with Cloud administrator privileges.
2. Navigate to **Administration** > **Projects** and click **+Project**.
3. Provide a name for the project.
4. (Optional) Check the **Public** check box to make the project public.

   If you set the project to **Public**, any user can pull images from this project. If you leave the project set to **Private**, only users who are members of the project can pull images. You can toggle projects from public to private, or the reverse, at any moment after you create the project.
5. Click **Save**.

**Result**

The project is added to the list of projects. You can browse existing projects and filter the list by entering text in the search box.

**What to Do Next**

You can add users to the project, push images to the project, browse the repositories that the project contains, view the project logs, and set up image replication. 
