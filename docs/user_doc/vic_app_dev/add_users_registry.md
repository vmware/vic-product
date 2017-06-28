# Assign Users to a Project #

To be able to pull images from a private vSphere Integrated Containers Registry project, a user must be a member of that project. In the case of public projects, any user can pull images from the project, but only members of the project with at least Developer privileges can push images to the project.

**Prerequisites**

You have a created project. If the registry uses local user management, there must be at least one user in the system in addition to the user who created the project.

**Procedure**

1. Log in to the vSphere Integrated Containers Registry interface at https://<i>vic_appliance_address</i>:443.

   Use the `admin` account, an account with the system-wide Administrator role, or an account that has the Project Admin role for this project. If the vSphere Integrated Containers appliance uses a different port for vSphere Integrated Containers Registry, replace 443 with the appropriate port.
2. Click **Projects** on the left and click the name of a project in the project list.
7. Click **Members**, then click the **+ Member** button to add users to the project.
8. Enter the user name for an existing user account, and select a role for the user in this project.

   - **Project Admin**: Read and write privileges for the project, with management privileges such as adding and removing members.
   - **Developer**: Can pull images from and push images to the project.
   - **Guest**: Can pull images from the project, but cannot push images to the project.
5. Click **OK**.