# Creating and Managing Users in vSphere Integrated Containers Registry #

##Role Based Access Control

In vSphere Integrated Containers Registry, images are grouped under projects. To access an image, a user should be added as a member into the project of the image. A member can have one of the three roles:  

* **Guest**: Guest has read-only privilege for a specified project.
* **Developer**: Developer has read and write privileges for a project.
* **ProjectAdmin**: When creating a new project, you will be assigned the "ProjectAdmin" role to the project. Besides read-write privileges, the "ProjectAdmin" also has some management privileges, such as adding and removing members.

Besides the above three roles, there are two system-wide roles:  

* **SysAdmin**: "SysAdmin" has the most privileges. In addition to the privileges mentioned above, "SysAdmin" can also list all projects, set an ordinary user as administrator and delete users. The public project "library" is also owned by the administrator.  
* **Anonymous**: When a user is not logged in, the user is considered as an "anonymous" user. An anonymous user has no access to private projects and has read-only access to public projects.  

##User account



**Procedure**

1. Log in as `admin` user to the vSphere Integrated Containers Registry interface at https://<i>vic_appliance_address</i>:443.
2. Click **Projects** on the left and click the name of a project in the project list.
7. Click **Members**, then click the **+ Member** button to add users to the project.
8. Enter the user name for an existing user account, and select the role for the user in this project:

   - **ProjectAdmin**: When creating a new project, you will be assigned the "ProjectAdmin" role to the project. Besides read-write privileges, the "ProjectAdmin" also has some management privileges, such as adding and removing members.
   - **Developer**: Developer has read and write privileges for a project.
   - **Guest**: Guest has read-only privilege for a specified project.
5. Click **OK**.
   
