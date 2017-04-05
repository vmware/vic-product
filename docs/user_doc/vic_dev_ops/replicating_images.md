# Replicating Images with vSphere Integrated Containers Registry

Images can be replicated between vSphere Integrated Containers Registry instances. It can be used to transfer images from one data center to another, or from an on-prem registry to an instance in the cloud.  

A replication policy needs to be set up on the source instance to govern the replication process. 
One key fact about the replication is that only images are replicated between vSphere Integrated Containers Registry instances. 
Users, roles and other information are not replicated. As such, always keep in mind that the user, roles and policy information is individually managed by each vSphere Integrated Containers Registry instance.

The replication is project-based. When a system administrator sets a policy to a project, all repositories under the project will be replicated to the remote registry. A replication job will be scheduled for each repository. 
If the project does not exist on the remote registry, a new project is created automatically.
If the project already exists and the replication user configured in the policy has no write privilege to it, 
the process will fail. 

When the policy is first enabled, all images of the project are replicated to the remote registry. Images subsequently pushed to the project on the source registry
will be incrementally replicated to the remote instance. When an image is deleted from the source registry, the policy ensures that the remote registry deletes the same image as well.
Please note, the user and member information will not be replicated.  

Depending on the size of the images and the network condition, the replication requires some time to complete. On the remote registry, an image is not available until
all its layers have been synchronized from the source. If a replication job fails due to some network issue, the job will be scheduled for a retry after a few minutes.
Always checks the log to see if there is any error of the replication. When a policy is disabled (stopped), vSphere Integrated Containers Registry tries to stop all existing jobs. It may take a while
before all jobs finish. A policy can be restarted by disabling and then enabling it again.  

To enable image replication, a policy must first be created. Click "Add New Policy" on the "Replication" tab, fill the necessary fields, if there is no destination in the list, you need to create one, and then click "OK", a policy for this project will be created. If  "Enable" is chosen, the project will be replicated to the remote immediately.  

**Note:** Set **"Verify Remote Cert"** to off according to the [installation guide](installation_guide_ova.md) if the destination uses a self-signed or untrusted certificate. 

![browse project](img/new_create_policy.png)

You can enable, disable or delete a policy in the policy list view. Only policies which are disabled can be edited. Only policies which are disabled and have no running jobs can be deleted. If a policy is disabled, the running jobs under it will be stopped.  

Click on a policy, jobs belonging to this policy will be listed. A job represents the progress of replicating a repository to the remote instance.  

![browse project](img/new_policy_list.png)

##Searching projects and repositories
Entering a keyword in the search field at the top lists all matching projects and repositories. The search result includes both public and private repositories you have access privilege to.  

![browse project](img/new_search.png)
