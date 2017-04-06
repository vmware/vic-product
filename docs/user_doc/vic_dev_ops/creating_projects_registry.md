# Creating and Managing Projects #

A project in vSphere Integrated Containers Registry contains all of the repositories of an application. You cannot push images to vSphere Integrated Containers Registry until you have created a project. 

RBAC is applied to a project. There are two types of projects in vSphere Integrated Containers Registry:  

* **Public**: All users have the read privilege to a public project, it's convenient for you to share some repositories with others in this way.  Users do not need to run `docker login` before pulling images under this project. 
* **Private**: A private project can only be accessed by users with the appropriate privileges.  

**Procedure**

1. Log in as `admin` user to the vSphere Integrated Containers Registry interface at https://<i>vic_appliance_address</i>:443.
2. Click **Projects** on the left, then click the **+ Project** button.
3. Provide a name for the project.
4. (Optional) Check the **Public** check box to make the project public.
5. Click **OK**.



After the project is created, you can browse repositories, users and logs using the navigation tab.  

![browse project](img/new_browse_project.png)  

All logs can be listed by clicking "Logs". You can apply a filter by username, or operations and dates under "Advanced Search".  

![browse project](img/new_project_log.png)  

##Managing members of a project 
###Adding members
You can add members with different roles to an existing project.  

![browse project](img/new_add_member.png)

###Updating and removing members
You can update or remove a member by clicking the icon on the right.  

![browse project](img/new_remove_update_member.png)