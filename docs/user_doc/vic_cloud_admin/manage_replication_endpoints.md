# Manage Replication Endpoints and Rules #

You can list, add, edit and delete replication endpoints and replication rules, depending on certain circumstances. 

- You cannot edit or delete replication endpoints that are the targets for replication rules. 
- You cannot edit replication rules that are enabled. 
- You cannot delete replication rules that have running jobs. If a rule is disabled, the running jobs under it will be stopped. 

**Prerequisites**

- You deployed at least two instances of vSphere Integrated Containers Registry. 
- You created at least one replication endpoint.
- You created at least one replication rule.

**Procedure**

1. Go to http://<i>vic_appliance_address</i>, click the link to **Go to the vSphere Integrated Containers Management Portal**, and enter the vCenter Server Single Sign-On credentials. 

   Use an account with Cloud Administrator privileges.
2. Select the **Administration** tab, click **Registries**, and click **Replication Endpoints**.

   Existing endpoints appear in the **Endpoints** view.  
3. To edit or delete an endpoint, click the 3 vertical dots next to an endpoint name and select **Edit Endpoint** or **Delete Endpoint**.
4. To edit, enable or disable, or delete a replication rule, click **Replication Rules**, click the 3 vertical dots next to a rule name and select **Edit**, **Enable** or **Disable**, or **Delete**.


**Result**

- If you enabled a rule, replication starts immediately. 
- If you disabled a rule, vSphere Integrated Containers Registry attempts to stop all running jobs. It can take some time for all jobs to finish. 
