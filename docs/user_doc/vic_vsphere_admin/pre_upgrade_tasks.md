# Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance #

To ensure a successful upgrade, you must perform several tasks before upgrading the vSphere Integrated Containers appliance. 

- Make sure that the previous version of the vSphere Integrated Containers appliance allows SSH connections.

  1. Select the appliance VM in the Hosts and Clusters view of the vSphere client
  2. Select **Edit Settings** > **vApp Options**.
  3. Expand **Appliance Security** and make sure that **Permit Root Login** is set to `True`.
  4. If **Permit Root Login** is set to `False`, power off the appliance VM, and edit the settings to enable it.


- Ensure that all vCenter Server instances and ESXi hosts in the environment in which you are deploying the appliance have network time protocol (NTP) running. Running NTP prevents problems arising from clock skew between the vSphere Integrated Containers appliance, virtual container hosts, and the vSphere infrastructure.
- Back up the appliance by using your usual backup tools. For information about backing up the appliance, see [Back Up and Restore the vSphere Integrated Containers Appliance](backup_vic_appliance.md).

    **IMPORTANT**: If you use snapshots to back up the appliance, you must clone the disk snapshots to a different location and remove the snapshots from the appliance VM. Upgrading the appliance requires you to remove disks from the appliance VM, and you cannot remove disks if the VM has snapshots.