# Manage Replication Rules #

You can enable, disable or delete a rule in the rule list view. Only rules which are disabled can be edited. Only rules which are disabled and have no running jobs can be deleted. If a rule is disabled, the running jobs under it will be stopped.  

Click on a rule, jobs belonging to this rule will be listed. A job represents the progress of replicating a repository to the remote instance.  

You restart a rule by disabling and then reenabling it.  

If you disable a rule, vSphere Integrated Containers Registry attempts to stop all running jobs. It can take some time for all jobs to finish. 