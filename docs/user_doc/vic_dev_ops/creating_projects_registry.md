# Creating and Managing Projects #

##Managing projects
A project in vSphere Integrated Containers Registry contains all repositories of an application. No images can be pushed to vSphere Integrated Containers Registry before the project is created. RBAC is applied to a project. There are two types of projects in vSphere Integrated Containers Registry:  

* **Public**: All users have the read privilege to a public project, it's convenient for you to share some repositories with others in this way.
* **Private**: A private project can only be accessed by users with proper privileges.  

You can create a project after you signed in. Enabling the "Public" checkbox makes the project public.  

![create project](img/new_create_project.png)  

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