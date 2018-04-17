# Upgrade the vSphere Integrated Containers Appliance

If you have a 1.2.1 or 1.3.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.4.x. You can also upgrade a 1.4.x release to a later 1.4.y update release.

Upgrading the vSphere Integrated Containers appliance requires you to deploy an instance of the new version of the appliance, use SSH to log in to the new appliance, and run an upgrade script. The script copies the relevant disk files from the old appliance to the new appliance. All configurations from the previous installation transfer to the upgraded appliance. 

Because disk files are copied rather than moved, the old appliance is not affected by the upgrade process. You can keep it as a backup. If you prefer to perform the upgrade by manually moving disks from the old appliance to the new appliance rather than by copying them, see [Upgrade the vSphere Integrated Containers Appliance by Manually Moving Disks](upgrade_appliance_manual.md).

**Prerequisites**

- You have completed the pre-upgrade tasks listed in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).
- Deploy the latest version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).

    **IMPORTANT:** Do not disable SSH access to the new appliance. You require SSH access to the appliance during the upgrade procedure.
- Use the Flex-based vSphere Web Client to deploy the appliance. You cannot deploy OVA files from the HTML5 vSphere Client or from the legacy Windows client.
- Deploy the appliance to the same vCenter Server instance as the one on which the previous version is running, or to a vCenter Server instance that is managed by the same Platform Services Controller.
- Log in to the vSphere Client for the vCenter Server instance on which the previous version is running and on which you deployed the new version. 
- Power on the new version of the vSphere Integrated Containers appliance and wait for it to initialize. Initialization can take a few minutes.

    **IMPORTANT**: After the new appliance has initialized not go to the Getting Started page of the appliance. Logging in to the Getting Started page for the first time initializes the appliance. Initialization is only applicable to new installations and causes upgraded appliances not to function correctly.
- Do not power off the older version of the appliance.

**Procedure**

1. Use SSH to connect to the new appliance as root user.

    <pre>$ ssh root@<i>new_vic_appliance_address</i></pre>

    When prompted for the password, enter the appliance password that you specified when you deployed the new version of the appliance. 

8. Navigate to the upgrade script and run it. 

    <pre>$ cd /etc/vmware/upgrade</pre>
    <pre>$ ./upgrade.sh</i></pre>

    If you attempt to run the script while the appliance is still initializing and you see the following message, wait for a few more minutes, then attempt to run the script again.

    <pre>Appliance services not ready. Please wait until vic-appliance-load-docker-images.service has completed.</pre>

1. Provide information about the new version of the appliance.

    1. Enter the address of the vCenter Server instance on which you deployed the new appliance.
    2. Enter the Single Sign-On user name and password of a vSphere administrator account.

    The script requires these credentials to access the disk files of the old appliance, and to register the new version of vSphere Integrated Containers with the VMware Platform Services Controller.
3. Provide information about the Platform Services Controller.

    - If vCenter Server is managed by an external Platform Services Controller, enter the FQDN of the Platform Services Controller.
    - If vCenter Server is managed by an embedded Platform Services Controller, press Enter without entering anything.
4. If applicable, provide the Platform Services Controller domain.

    - If vCenter Server is managed by an external Platform Services Controller, enter the administrator domain for the Platform Services Controller.
    - If vCenter Server is managed by an embedded Platform Services Controller, press Enter without entering anything.
5. Enter **y** if the vCenter Server certificate thumbprint is legitimate.
6. Provide information about the old version of the appliance.

    1. Enter the name of the datacenter that contains the old version of the appliance.
    2. Enter the address of the old version of the appliance.
    3. For the old appliance user name, enter `root`.
    4. Enter the root password for the old appliance.
6. Verify that the upgrade script has detected your upgrade path correctly.        
  - If the script detects your upgrade path correctly, enter `y` to proceed with the upgrade.
  - If the upgrade script detects the upgrade path incorrectly, enter `n` to abort the upgrade and contact VMware support.

**Result**

After you see confirmation that the upgrade has completed successfully, the upgraded appliance initializes. When the upgraded appliance has initialized, you can access its Getting Started page at http://<i>new_appliance_address</i>.

**What to Do Next**

- Click **Go to the vSphere Integrated Containers Management Portal** in the Getting Started page, and use vCenter Server Single Sign-On credentials to log in.

  - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
  - In the **Administration** tab, check that projects, registries, repositories, and replication configurations have migrated successfully.
- If, in the previous version, you configured vSphere Integrated Containers Registry instances as replication endpoints, upgrade the appliances that run those registry instances. Replication of images from the new registry instance to the older replication endpoint still functions, but it is recommended that you upgrade the target registry.
- Download the vSphere Integrated Containers Engine bundle and upgrade  your VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- Upgrade the vSphere Integrated Containers plug-ins for the vSphere Client. For information about upgrading the vSphere Client plug-ins, see: 
  - [Upgrade the vSphere Client Plug-Ins on vCenter Server for Windows](upgrade_h5_plugin_windows.md)
  - [Upgrade the vSphere Client Plug-Ins on a vCenter Server Appliance](upgrade_h5_plugin_vcsa.md)
