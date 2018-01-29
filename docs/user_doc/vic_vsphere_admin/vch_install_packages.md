# Install Packages in the Virtual Container Host Endpoint VM #

In certain circumstances, you might need to install a capability in the virtual container host (VCH) endpoint VM that does not exist by default. For example, you might want to install an NFS client in the endpoint VM, to test or debug connections from the VCH to an NFS server.

The VCH endpoint VM runs Photon OS. Photon OS provides a package manager named Tiny DNF, or `tdnf`, that is the default means of installing packages. For information about Tiny DNF, see [Tiny DNF for Package Management](https://github.com/vmware/photon/blob/master/docs/photon-admin-guide.md#tiny-dnf-for-package-management) in the *Photon OS Administration Guide*. 

Before you can use Tiny DNF to install packages in the endpoint VM, you must run the `rpm --rebuilddb` command to rebuild the embedded database. If you do not run `rpm --rebuilddb`, attempts to run Tiny DNF commands in the endpoint VM result in the following error:

<pre>
root@ [ ~ ]# tdnf info
Error(1304) : Hawkey - I/O error
</pre>

**Prerequisite**

Run the `vic-machine debug` command with the `--enable-ssh` and `--rootpw` options to enable SSH access to the VCH endpoint VM and to set the root password. For information about `vic-machine debug`, see [Debug Running Virtual Container Hosts](debug_vch.md).

**Procedure**

1. Use SSH to connect to the VCH endpoint VM as `root` user.
2. Run the command to rebuild the database in the endpoint VM.<pre>rpm --rebuilddb</pre>
3. Run a Tiny DNF command to test the reconfiguration.<pre>tdnf info</pre>The `tdnf info` command should display information about the installed packages. 
4. If you see the error `Failed to synchronize cache for repo 'VMware Photon Linux 1.0(x86_64)Updates'`, perform the following steps:

   1. List the repository configuration files.<pre>ls /etc/yum.repos.d/</pre>
   2. Open the Photon OS updates repository configuration file in a text editor.<pre>vi /etc/yum.repos.d/photon-updates-local.repo</pre>
   3. Update the entry for the repository URL and save the change.<pre>baseurl=http://dl.bintray.com/vmware/photon_dev_x86_64/</pre> 
   4. Open the Photon OS repository configuration file in a text editor.<pre>vi /etc/yum.repos.d/photon-local.repo</pre>
   5. Update the entry for the repository URL and save the change.<pre>baseurl=http://dl.bintray.com/vmware/photon_dev_x86_64/</pre>
   6. If additional `.repo` files exist in `/etc/yum.repos.d/`, update the `baseurl` entry for those files to point to http://dl.bintray.com/vmware/photon_dev_x86_64/.
   5. Run `tdnf info` again. 
 
        The `tdnf info` command should display information about the installed packages.

**Result**

You can now use Tiny DNF to install new packages in the VCH endpoint VM.

**IMPORTANT**: 

- Any installations and configurations that you perform by using Tiny DNF in the endpoint VM do not persist if you reboot the endpoint VM.
- Running `rpm --rebuilddb` results in an unpopulated database. Consequently, when you use Tiny DNF to install a package, it tries to install all of the dependencies for that package in the endpoint VM, even if those dependencies are already present.

**What to Do Next**

For an example of how to install a package in the VCH endpoint VM, see [Mount an NFS Share Point in the VCH Endpoint VM](vch_mount_nfsshare.md).