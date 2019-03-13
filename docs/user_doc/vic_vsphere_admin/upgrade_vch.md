# Upgrade Virtual Container Hosts #

You upgrade virtual container hosts (VCHs) by downloading a new version of vSphere Integrated Containers Engine and running the `vic-machine upgrade` command. You can upgrade VCHs from 1.3.x and 1.4.x to 1.5.x, or from 1.5.x to a later 1.5.y update release.

You use `vic-machine upgrade` to upgrade VCHs to newer versions. You can run `vic-machine upgrade` on VCHs that are either running or powered off. When you upgrade a running VCH, the VCH goes temporarily offline, but container workloads continue as normal during the upgrade process. Upgrading a VCH does not affect any mapped container networks that you defined by setting the `vic-machine create --container-network` option. The following operations are not available during upgrade:

- You cannot access container logs
- You cannot attach to a container
- NAT based port forwarding is unavailable

**IMPORTANT**: Upgrading a VCH does not upgrade any existing container VMs that the VCH manages. For container VMs to boot from the latest version of `bootstrap.iso`, container developers must recreate them.

For descriptions of the options that `vic-machine upgrade` includes in addition to the [Common `vic-machine` Options](common_vic_options.md) , see [VCH Upgrade Options](upgrade_vch_options.md).

## Prerequisites

- You deployed one or more VCHs with an older version of `vic-machine`.
- You downloaded a new version of the vSphere Integrated Containers Engine bundle.
- Run the `vic-machine ls` command by using the new version of `vic-machine` to see the upgrade status of all of the VCHs that are running on a vCenter Server instance or ESXi host. For information about running `vic-machine ls`, see [List VCHs and Obtain Their IDs](list_vch.md).
- Optionally note the IDs of the VCHs.
- Obtain the vCenter Server or ESXi host certificate thumbprint. For information about how to obtain the certificate thumbprint, see [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md).


## Procedure

1. On the system on which you run `vic-machine`, navigate to the directory that contains the new version of the `vic-machine` utility.
2. Run the `vic-machine upgrade` command. 

     The following example includes the options required to upgrade a VCH in a simple vCenter Server environment. 

  - You must specify the user name and optionally the password, either in the `target` option or separately in the `--user` and `--password` options. 
  - If the VCH has a name other than the default name, `virtual-container-host`, you must specify the `--name` or `--id` option. 
  - If multiple compute resources exist in the datacenter, you must specify the `--compute-resource` or `--id` option. 
  - If your vSphere environment uses untrusted, self-signed certificates, you must also specify the thumbprint of the vCenter Server instance or ESXi host in the `--thumbprint` option. 

     Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.

     <pre>$ vic-machine-<i>operating_system</i> upgrade
  --target <i>vcenter_server_address</i>
  --user Administrator@vsphere.local
  --password <i>password</i>
  --thumbprint <i>certificate_thumbprint</i>
  --id <i>vch_id</i></pre>

3. If the upgrade operation fails with error messages, run `vic-machine upgrade` again, specifying a timeout longer than 3 minutes in the `--timeout` option.

     <pre>$ vic-machine-<i>operating_system</i> upgrade
  --target <i>vcenter_server_address</i>
  --user Administrator@vsphere.local
  --password <i>password</i>
  --thumbprint <i>certificate_thumbprint</i>
  --id <i>vch_id</i>
  --timeout 5m0s</pre>

3. If the upgrade operation continues to fail with error messages, run `vic-machine upgrade` again with the `--force` option.

    **CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments.  

     <pre>$ vic-machine-<i>operating_system</i> upgrade
  --target <i>vcenter_server_address</i>
  --user Administrator@vsphere.local
  --password <i>password</i>
  --id <i>vch_id</i>
  --timeout 5m0s
  --force</pre>

4. (Optional) To roll back an upgraded VCH to the previous version, or to revert a VCH that failed to upgrade, run `vic-machine upgrade` again with the `--rollback` option.

     <pre>$ vic-machine-<i>operating_system</i> upgrade
  --target <i>vcenter_server_address</i>
  --user Administrator@vsphere.local
  --password <i>password</i>
  --id <i>vch_id</i>
  --rollback</pre>


## Result

During the upgrade process, `vic-machine upgrade` performs the following operations:

- Validates whether the configuration of the existing VCH is compatible with the new version. If not, the upgrade fails. 
- Uploads the new versions of the `appliance.iso` and `bootstrap.iso` files to the VCH. There is no timeout for this stage of the upgrade process, so that the ISO files can upload over slow connections.
- Creates a snapshot of the VCH endpoint VM, to use in case the upgrade fails and has to roll back.
- Boots the VCH by using the new version of the `appliance.iso` file.
- Deletes the snapshot of the VCH endpoint VM once the upgrade has succeeded.
- After you upgrade a VCH, any new container VMs will boot from the new version of the `bootstrap.iso` file.
- If the upgrade times out while waiting for the VCH service to start, the upgrade fails and rolls back to the previous version.
- If the upgrade fails with the error `another upgrade/configure operation is in progress`, a previous attempt at upgrading the VCH might have been interrupted without rolling back. In this case, run `vic-machine configure` with the `--reset-progress` option. For information about `vic-machine configure --reset-progress`, see [Reset Upgrade or Configuration Progress](configure_vch.md#resetprogress).