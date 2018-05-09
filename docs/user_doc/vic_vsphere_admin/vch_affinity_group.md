# Add Virtual Container Hosts to a DRS Affinity Group #

When you deploy a virtual container host, you can optionally instruct vSphere Integrated Containers to automatically create a DRS VM group in vSphere for the VCH endpoint VM and its container VMs. If you use this option, you can  use the resulting VM group in DRS VM-Host affinity rules, to restrict the set of hosts on which the VCH endpoint VM and its container VMs can run.

You might want to restrict the set of hosts on which the VCH and container VMs run for the following reasons:

- Software licensing, for example if your organization is billed based on the number of physical hosts, sockets, or cores that run a particular piece of software.
- Compliance with internal policies.
- Latency-sensitivity, for workloads that run in an environment with stretched clusters.

You can address each of these use cases by using DRS VM-host affinity groups.

- [Usage](#usage)
- [vic-machine Option](#option)
- [Example `vic-machine` Command](#example)

## Usage <a id="usage"></a>

vSphere allows you to express VM-Host affinity rules either as a requirement (*must*/*must not* rules) or a preference (*should*/*should not* rules).

  - If you define *must* rules, DRS does not allow the VMs to run on other hosts, even in extreme circumstances. For example, vSphere HA does not perform failovers to hosts that are not in the DRS host group. 
  - If you define *should* rules, violations produce a log event and are reported as faults on the **Configure** > **vSphere DRS** view for the cluster.

To set VM-Host affinity rules on a VCH, you perform the following steps:

- In vSphere, create a DRS host group that includes the set of hosts to which to limit VCH and container VM workloads.
- Deploy a VCH with the `vic-machine create --affinity-vm-group` option, which automatically creates a DRS VM group in vSphere for the VCH and its container VMs.
- In vSphere, create a VM-Host affinity rule that includes the VM group and the host group. This ensures that the VCH and container VMs in the VM group only run on the hosts that you specified in the host group.

**IMPORTANT**: Because you define VM-host affinity rules on clusters, all of the hosts in a DRS host group must be reside in the same cluster.

For more information about DRS affinity rules, see [Using DRS Affinity Rules](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.resmgmt.doc/GUID-FF28F29C-8B67-4EFF-A2EF-63B3537E6934.html) in the vSphere documentation.
                          
## vic-machine Option <a id="option"></a>

This option is only available with the `vic-machine create` command. It is not available in the Create Virtual Container Host wizard in the vSphere Client.

`--affinity-vm-group`, no short name

The `--affinity-vm-group` option takes no arguments. You can only use this option when deploying a VCH to a cluster with DRS enabled.

<pre>--affinity-vm-group</pre>

When deployment of the VCH finishes, go to **Hosts & Clusters**, *cluster* > **Configure** > **VM/Host Groups** in the vSphere Client. You see a VM group that has the same name as the VCH. You can associate this VM group with a set of specific hosts by creating a host group and adding both the VM group and the host group to a DRS VM-Host affinity rule.

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH that specifies `--affinity-vm-group`. After deployment, the VCH and all of its container VMs belong to an automatically created DRS VM affinity group that has the same name as the the VCH.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--public-network vic-public
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
--affinity-vm-group
</pre> 