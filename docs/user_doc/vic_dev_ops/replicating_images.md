# Replicating Images with vSphere Integrated Containers Registry

You can replicate images between vSphere Integrated Containers Registry instances. You can use image replication to transfer images from one data center to another, or to transfer them from an on-premises registry to a registry instance in the cloud.  

To set up image replication between registry instances, you create replication endpoints and replication rules. vSphere Integrated Containers Registry performs image replication at the project level. When you set a replication rule on a project, all of the image repositories in that project replicate to the remote replication endpoint that you designate in the rule. vSphere Integrated Containers Registry schedules a replication job for each repository. 

**IMPORTANT**: vSphere Integrated Containers Registry only replicates image repositories. It does not replicate users, roles, replication rules, or any other information that does not relate to images. Each vSphere Integrated Containers Registry instance manages its own user, role, and rule information.

* [Create Replication Endpoints](create_replication_endpoints.md)
* [Create Replication Rules](create_replication_rules.md)
* [Manage Replication Endpoints](manage_replication_endpoints.md)
* [Manage Replication Rules](manage_replication_rules.md)