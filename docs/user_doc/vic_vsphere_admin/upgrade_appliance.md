# Upgrade the vSphere Integrated Containers Appliance

If you have a 1.3.x or 1.4.x version of the vSphere Integrated Containers appliance, you can upgrade your existing installation to 1.5.x. You can also upgrade a 1.5.x release to a later 1.5.y update release.

Upgrading the vSphere Integrated Containers appliance requires you to deploy an instance of the new version of the appliance, use SSH to log in to the new appliance, and run an upgrade script. The script copies the relevant disk files from the old appliance to the new appliance. All configurations that you made in vSphere Integrated Containers Management Portal in the previous installation transfer to the upgraded appliance. If you configured the older version of the appliance with a static IP address, you can configure the new appliance to use the same IP address as before.

Because disk files are copied rather than moved, the old appliance is not affected by the upgrade process. You can keep it as a backup. This is the recommended procedure for performing upgrades.

You can also perform the upgrade by manually copying disks from the old appliance to the new appliance rather than by copying them. For information about manual upgrade, see [Upgrade the vSphere Integrated Containers Appliance by Manually Copying Disks](upgrade_appliance_manual.md).

For information about the supported upgrade paths for all versions of vSphere Integrated Containers, see Upgrade Paths in the [VMware Product Interoperability Matrices](https://partnerweb.vmware.com/comp_guide2/sim/interop_matrix.php#upgrade&solution=149).

**NOTE**: You cannot upgrade between untagged, open source builds of the same release. For example, you cannot upgrade from an earlier,  open source build of 1.5.0 to the official 1.5.0 release. You can only upgrade from one official release to another. Upgrading from one tagged open source build to another is possible but is not supported.

## Prerequisites

- You have completed the pre-upgrade tasks listed in [Tasks to Perform Before Upgrading the vSphere Integrated Containers Appliance](pre_upgrade_tasks.md).
- If you deployed the old version of the vSphere Integrated Containers appliance with a static IP address, and you want the new appliance to retain the same IP address after the upgrade, reconfigure the old appliance to use a temporary IP address before you start the upgrade procedure. For information about how to reconfigure the old appliance, see [Reconfigure the vSphere Integrated Containers Appliance](reconfigure_appliance.md).
- Deploy the latest version of the vSphere Integrated Containers appliance. For information about deploying the appliance, see [Deploy the vSphere Integrated Containers Appliance](deploy_vic_appliance.md).  
  - If you use vCenter Server 6.7 update 1 or later, you can use the HTML5 vSphere Client to deploy the appliance. If you use an older version of vCenter Server, you must use the Flex-based vSphere Web Client to deploy the appliance. You cannot deploy OVA files from versions of the HTML5 vSphere Client that pre-date vCenter Server 6.7 update 1. 
  - When you deploy the new version of the apppliance, you can optionally configure the network settings to use the same static IP address as you used on the old version.
  - The upgrade process copies data, including the certificates, from the old appliance to the new appliance. Consequently, if you deployed the appliances to a cluster, the virtual disks for the two appliances must be located in the same datastore cluster.
  - **IMPORTANT:** Do not disable SSH access to the new appliance. You require SSH access to the appliance during the upgrade procedure.
  - Deploy the new version of the appliance to the same vCenter Server instance as the one on which the previous version is running, or to a vCenter Server instance that is managed by the same Platform Services Controller.
  - Power on the new version of the vSphere Integrated Containers appliance and wait for it to boot up. Booting up can take a few minutes. Go to  https://<i>vic_appliance_address</i>:9443 and wait until the **Complete VIC appliance installation** panel appears.
  - **IMPORTANT**: After the new appliance has booted up, do not fill in the **Complete VIC appliance installation** panel. This step is only applicable to new installations, not to upgrades.
- Log in to the vSphere Client for the vCenter Server instance on which the previous version is running and on which you deployed the new version. 
- Do not power off the older version of the appliance.

## Procedure

1. Use SSH to connect to the new appliance as root user.

    <pre>$ ssh root@<i>new_vic_appliance_address</i></pre>

    When prompted for the password, enter the appliance password that you specified when you deployed the new version of the appliance. 

2. Navigate to the upgrade script and run it. 

    <pre>$ cd /etc/vmware/upgrade</pre>
    <pre>$ ./upgrade.sh</i></pre>

	**NOTE**: You can bypass some or all of the following steps by specifying additional optional arguments when you run the upgrade script. For information about the arguments that you can specify, see [Specify Command Line Options During Appliance Upgrade](#upgradeoptions) below.	

    If you attempt to run the script while the appliance is still initializing and you see the following message, wait for a few more minutes, then attempt to run the script again.

    <pre>Appliance services not ready. Please wait until vic-appliance-load-docker-images.service has completed.</pre>

3. Enter the IP address or FQDN of the vCenter Server instance on which you deployed the new appliance.
4. Enter the Single Sign-On user name and password of a vSphere administrator account.

    The script requires these credentials to access the disk files of the old appliance, and to register the new version of vSphere Integrated Containers with the VMware Platform Services Controller.
4. If vCenter Server is managed by an external Platform Services Controller, enter the IP address or FQDN and the administrator domain of the Platform Services Controller.

    If vCenter Server is managed by an embedded Platform Services Controller, press Enter at both prompts without entering anything.
6. Enter `y` if the vCenter Server certificate thumbprint is legitimate.
6. Enter the root password of the new version of the appliance.
7. Provide information about the old version of the appliance.

    1. Enter the name of the datacenter that contains the old version of the appliance.
    2. Enter the IP address of the old version of the appliance.The upgrade script does not accept FQDN addresses for the old appliance.
    3. For the old appliance user name, enter `root`.
8. To automatically upgrade the vSphere Integrated Containers plug-in for vSphere Client, enter `y` at the prompt to `Upgrade VIC UI Plugin`.

    **NOTE**: If you enter `n` to skip the plug-in upgrade, for example because you have multiple appliances of a different version, you can upgrade the plug-in later. You can see version information about the plug-in and the appliance in the Summary tab of the vSphere Integrated Containers plug-in.
10. Enter the root password for the old appliance.
10. Verify that the upgrade script has detected your upgrade path correctly.        
  - If the script detects your upgrade path correctly, enter `y` to proceed with the upgrade.
  - If the upgrade script detects the upgrade path incorrectly, enter `n` to abort the upgrade and contact VMware support.

## Result

After you see confirmation that the upgrade has completed successfully, the upgraded appliance initializes. When the upgraded appliance has initialized, you can access its appliance welcome page at http://<i>new_appliance_address</i>.

## What to Do Next

- If you answered `y` at the prompt to `Upgrade VIC UI Plugin`, access the  vSphere Integrated Containers plug-in for vSphere Client:
   1. Log out of the HTML5 vSphere Client and log back in again. You should see a banner that states `There are plug-ins that were installed or updated`.
      2. If you use vSphere 6.7u1 or later, click the button in the banner to refresh the vSphere Client.
      2. On versions of vSphere that pre-date 6.7u1, log out of the HTML5 vSphere Client a second time and log back in again.
   3. Click the **vSphere Client** logo in the top left corner. 
   4. Under Inventories, click **vSphere Integrated Containers** to access the vSphere Integrated Containers plug-in.
   5. In the **vSphere Integrated Containers** > **Summary** tab, check that the plug-in is at the correct version.
- Click **Go to the vSphere Integrated Containers Management Portal** in the appliance welcome page, and use vCenter Server Single Sign-On credentials to log in.

  - In the **Home** tab of the vSphere Integrated Containers Management Portal, check that all existing applications, containers, networks, volumes, and virtual container hosts have migrated successfully.
  - In the **Administration** tab, check that projects, registries, repositories, and replication configurations have migrated successfully.
- If, in the previous version, you configured vSphere Integrated Containers Registry instances as replication endpoints, upgrade the appliances that run those registry instances. Replication of images from the new registry instance to the older replication endpoint still functions, but it is recommended that you upgrade the target registry.
- Download the new vSphere Integrated Containers Engine bundle and upgrade  your VCHs. For information about upgrading VCHs, see [Upgrade Virtual Container Hosts](upgrade_vch.md).
- If you answered `n` at the prompt to `Upgrade VIC UI Plugin`, and you want to upgrade the plug-in later, see [Reinitialize the vSphere Integrated Containers Appliance](reinitialize_appliance.md). 

## Troubleshooting

If upgrade fails, generate a log bundle and obtain the upgrade log to provide to VMware support. For information about obtaining the logs, see [Access and Configure Appliance Logs](appliance_logs.md).

## Specify Command Line Options During Appliance Upgrade <a id="upgradeoptions"></a>

When you run the script to upgrade the vSphere Integrated Containers appliance, you are prompted to enter information about the environment in which you are running the old and new versions of the appliance. 

To bypass these prompts, you can specify command line arguments when you run the `/etc/vmware/upgrade/upgrade.sh` script. All arguments are optional. If you omit a required argument, the script prompts you to enter the information. These arguments also allow you to automate the upgrade of the appliance.

<table width="100%" border="1">
        <tr>
          <th width="25%" scope="col">Option</th>
          <th width="75%" scope="col">Description</th>
        </tr>
        <tr>
          <td><code>--target</code></td>
          <td>Specify the address of the vCenter Server instance on which you deployed the new appliance.</td>
        </tr>
        <tr>
          <td><code>--username</code></td>
          <td> Specify the Single Sign-On user name of a vSphere administrator account.</td>
        </tr>
        <tr>
          <td><code>--password</code></td>
          <td>Specify the Single Sign-On password of a vSphere administrator account.</td>
        </tr>
        <tr>
          <td><code>--fingerprint</code></td>
          <td>Specify the IP address of vCenter Server and the thumbprint of the vCenter Server certificate, in the format <code>--fingerprint '<i>vcenter_server_address</i> <i>vcenter_server_thumbprint</i>'</code>. Use upper-case letters and colon delimitation in the thumbprint. Do not use space delimitation.</td>
        </tr>
        <tr>
          <td><code>--dc</code></td>
          <td> Specify the name of the datacenter that contains the old version of the appliance.</td>
        </tr>
        <tr>
          <td><code>--embedded-psc</code></td>
          <td>Skip the prompts for information about an external Platform Services Controller. Use this option if you run vCenter Server with an embedded Platform Services Controller. </td>
        </tr>
        <tr>
          <td><code>--external-psc</code></td>
          <td> If vCenter Server is managed by an external Platform Services Controller,  specify the IP address of the Platform Services Controller.</td>
        </tr>
        <tr>
          <td><code>--external-psc-domain</code></td>
          <td>If vCenter Server is managed by an external Platform Services Controller,  specify the administrator domain for the Platform Services Controller.</td>
        </tr>

        <tr>
          <td><code>--appliance-target</code></td>
          <td> Specify the address of the old version of the appliance.</td>
        </tr>
        <tr>
          <td><code>--appliance-username</code></td>
          <td> Specify the user name for the old appliance, usually  <code>root</code>.</td>
        </tr>
        <tr>
          <td><code>--appliance-password</code></td>
          <td>Specify the password for the <code>root</code> user on the old appliance.</td>
        </tr>
        <tr>
          <td><code>--ssh-insecure-skip-verify</code></td>
          <td>Skip the host key check for SSH access to the old appliance. Use this option if you want to use the upgrade script completely non-interactively.</td>
        </tr>
        <tr>
          <td><code>--appliance-version</code></td>
          <td>Specify the version number of the old version of the appliance, in the format <code>v1.x.y</code>, to skip the upgrade path check. Upgrade fails if the version specified is incorrect. </td>
        </tr>
        <tr>
          <td><code>--destroy</code></td>
          <td>Remove the old appliance after the upgrade is finished. Use this option if you do not want to keep the old appliance as a backup. This option requires you to confirm by entering <code>y</code> or <code>n</code> before proceeding.</td>
        </tr> 
		<tr>
          <td><code>--manual-disks</code></td>
          <td>Skip the automated  disk migration. Use this option if you  manually moved the disks from the old appliance to the new appliance. * </td>
        </tr>
		<tr>
          <td><code>--upgrade-ui-plugin</code></td>
          <td>Upgrade the vSphere Integrated Containers plug-in for the vSphere Client. Specify `n` to skip plug-in upgrade. If you do not specify this option, the upgrade is performed. </td>
        </tr>
      </table>

&#42; To use the `--manual-disks` option, follow the instructions in [Upgrade the vSphere Integrated Containers Appliance by Manually Moving Disks](upgrade_appliance_manual.md).

**NOTE**: Option values that contain $ (dollar sign), ` (backquote), ' (single quote), " (double quote), and \ (backslash) are not substituted correctly. Change any input, particularly passwords, that contain these values before  you run this script.

### Example: Upgrade Appliance with Embedded Platform Services Controller

The following command upgrades a vSphere Integrated Containers 1.4.4 appliance. The new appliance runs in a vCenter Server instance with an embedded Platform Services Controller. The old appliance is removed when the upgrade finishes.

<pre>./upgrade.sh --target <i>vcenter_server_address</i>
--username 'Administrator@vsphere.local'
--password 'P@ssW0rd!'
--fingerprint '<i>vcenter_server_address</i> 49:8C:56:6B:F0:E6:54:D1:3F:77:4A:81:DE:BD:61:8B:80:CE:DF:E6'
--dc oldApplianceDatacenter
--embedded-psc
--appliance-target <i>old_appliance_address</i>
--appliance-username root
--appliance-password <i>old_appliance_root_password</i>
--appliance-version v1.4.4
--destroy
</pre>

### Example: Upgrade Appliance with External Platform Services Controller

The following command upgrades a vSphere Integrated Containers 1.3.1 appliance. The new appliance runs in a vCenter Server instance with an external Platform Services Controller. The old appliance is not removed when the upgrade finishes.

<pre>./upgrade.sh --target <i>vcenter_server_address</i>
--username 'Administrator@vsphere.local'
--password 'P@ssW0rd!'
--fingerprint '<i>vcenter_server_address</i> 49:8C:56:6B:F0:E6:54:D1:3F:77:4A:81:DE:BD:61:8B:80:CE:DF:E6'
--dc oldApplianceDatacenter
--external-psc <i>psc_address</i>
--external-psc-domain vsphere.local
--appliance-target <i>old_appliance_address</i>
--appliance-username root
--appliance-password <i>old_appliance_root_password</i>
--appliance-version v1.3.1
</pre>