# Manage Replication Endpoints and Rules #

You can list, add, edit and delete replication endpoints and replication rules, depending on certain circumstances. 

- You cannot edit or delete replication endpoints that are the targets for replication rules. 
- You cannot edit replication rules that are enabled. 
- You cannot delete replication rules that have running jobs. If a rule is disabled, the running jobs under it will be stopped. 

## Prerequisites

- Log in to vSphere Integrated Containers Management Portal with a vSphere administrator or Management Portal administrator account. For information about logging in to vSphere Integrated Containers Management Portal, see [Logging In to the Management Portal](logging_in_mp.md).
- You deployed at least two instances of vSphere Integrated Containers Registry. 
- You created at least one replication endpoint.
- You created at least one replication rule.

## Procedure

1. Select the **Administration** tab, click **Global Registries**, and click **Replication Endpoints**.

    Existing endpoints appear in the **Endpoints** view.  
3. To edit or delete an endpoint, select the check box next to an endpoint name and click **Edit** or **Delete**.
4. To edit or delete a replication rule, click **Replication Rules**, select the check box next to a rule name and click **Edit** or **Delete**.


## Result

- If you enabled a rule, replication starts immediately. 
- If you disabled a rule, vSphere Integrated Containers Registry attempts to stop all running jobs. It can take some time for all jobs to finish. 
