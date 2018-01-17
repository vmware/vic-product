# Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance #

To ensure a successful upgrade, you must perform several tasks before upgrading the vSphere Integrated Containers appliance. These pre-upgrade tasks are necessary due to differences in implementation between versions 1.2 and 1.3 of the vSphere Integrated Containers Registry and Management Portal, in particular the merging of the user interfaces and the transition to the Platform Services Controller for identity management.

- Make sure that the previous version of the vSphere Integrated Containers appliance allows SSH connections.

  1. Select the appliance VM in the Hosts and Clusters view of the vSphere client
  2. Select **Edit Settings** > **vApp Options**.
  3. Expand **Appliance Security** and make sure that **Permit Root Login** is set to `True`.
  4. If **Permit Root Login** is set to `False`, power off the appliance VM, and edit the settings to enable it.


- Ensure that all vCenter Server instances and ESXi hosts in the environment in which you are deploying the appliance have network time protocol (NTP) running. Running NTP prevents problems arising from clock skew between the vSphere Integrated Containers appliance, virtual container hosts, and the vSphere infrastructure.
- Back up the appliance by using your usual backup tools.