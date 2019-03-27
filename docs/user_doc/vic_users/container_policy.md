# Policy Configuration #

You can create container clusters by using Policy settings to specify cluster size.

When you configure a cluster, a specified number of containers is provisioned. Requests are load balanced among all containers in the cluster. You can modify the cluster size on a provisioned container or application to increase or decrease the size of the cluster by one. When you modify the cluster size at runtime, all affinity filters and placement rules are considered.

Configure the following cluster settings on the **Policy** tab of the Provision a Container page:

- Cluster Size. The number of nodes that you want to provision.
- Restart Policy. The restart behavior that should be applied when the container exits. You can select one of the following options:
    - None. Default behavior. 
    - On-failure. Indicates that the container must restart only when the process running on it fails. If you select this, you must specify the maximum number of restarts.
    - Always. Indicates that the container must restart when the process it is running completes. 
- Max Restarts. The maximum number of times that the container tries to restart when it fails.
- CPU shares. An integer value that specifies the CPU shares for this container in relation to the other container VMs in the VCH resource pool.
- Memory Limit. The quantity of memory for use by the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool. Specify the memory reservation value in MB.
- Memory Swap Limit. The total amount of RAM that the container must use. When the container runs out of RAM, it swaps to disk or physical storage.
- Affinity Constraints. Specify VM-Host affinity rules either as a requirement (must/must not rules) or a preference (should/should not rules). 

For more information, see [Virtual Container Host Compute Capacity](../vic_vsphere_admin/vch_compute.md).
