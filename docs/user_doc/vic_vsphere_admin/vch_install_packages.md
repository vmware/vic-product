# Install Packages in the Virtual Container Host Endpoint VM #

In certain circumstances, you might need to install a capability in the virtual container host (VCH) endpoint VM that does not exist by default. For example, you might want to install an NFS client in the endpoint VM, to test or debug connections from the VCH to an NFS server.

The VCH endpoint VM runs Photon OS 2.0. Photon OS provides a package manager named Tiny DNF, or `tdnf`, that is the default means of installing packages. For information about Tiny DNF, see [Tiny DNF for Package Management](https://github.com/vmware/photon/blob/master/docs/photon-admin-guide.md#tiny-dnf-for-package-management) in the *Photon OS Administration Guide*. 

Before you can use Tiny DNF to install packages in the endpoint VM, you must run the `rpm --rebuilddb` command to rebuild the embedded database. To run `rpm --rebuilddb`, you must first modify the Photon OS configuration to satisfy certain dependencies that are not present in the VCH endpoint VM by default. If you do not successfully run `rpm --rebuilddb`, attempts to run certain Tiny DNF commands in the endpoint VM result in the following error:

<pre>
root@ [ ~ ]# tdnf info
Error(1304) : Hawkey - I/O error
</pre>

**IMPORTANT**: Any changes that you make to the VCH endpoint VM, including installing packages, are non-persistent and are lost if the endpoint VM reboots.

**Prerequisite**

- Enable SSH access to the VCH endpoint VM. For information about enabling SSH access, see [Debug Running Virtual Container Hosts](debug_vch.md).
- Ensure that the VCH can access the Photon OS repositories at https://vmware.bintray.com/, either via the Internet or via a mirror on the local network.

**Procedure**

1. Use SSH to connect to the VCH endpoint VM as `root` user.
2. Open the Photon OS updates repository configuration file in a text editor.<pre>vi /etc/yum.repos.d/photon-updates-local.repo</pre>
3.  Update the entry for the repository URL and save the change.<pre>baseurl=https://vmware.bintray.com/photon_updates_1.0_x86_64/</pre>
4.  Open the Photon OS repository configuration file in a text editor.<pre>vi /etc/yum.repos.d/photon-local.repo</pre>
5.  Update the entry for the repository URL and save the change.<pre>baseurl=https://vmware.bintray.com/photon_release_1.0_x86_64/</pre>
6. Create a folder for `rpm` and initialize the `rpm` database.

    1. `mkdir /root/rpm`
    2. `rpm --root /root/rpm -initdb`
7. Install the dependencies that Tiny DNF requires to install packages.<pre>tdnf --installroot /root/rpm --nogpgcheck install haveged systemd openssh iptables e2fsprogs procps-ng iputils iproute2 iptables net-tools sudo tdnf vim gzip lsof logrotate photon-release</pre>
8. Copy the `/root/rpm/var/lib/rpm/Packages` file to the following location.<pre>cp /root/rpm/var/lib/rpm/Packages /var/lib/rpm/Packages</pre>
9. Run the command to rebuild the database in the endpoint VM.<pre>rpm --rebuilddb</pre>
3. Run a Tiny DNF command to test the reconfiguration.<pre>tdnf list installed</pre>The `tdnf list installed` command should display information about the installed packages. 

**Result**

You can now use Tiny DNF to install new packages in the VCH endpoint VM.

**IMPORTANT**: 

- Any installations and configurations that you perform by using Tiny DNF in the endpoint VM do not persist if you reboot the endpoint VM.
- Running `rpm --rebuilddb` results in an unpopulated database. Consequently, when you use Tiny DNF to install a package, it tries to install all of the dependencies for that package in the endpoint VM, even if those dependencies are already present.

**What to Do Next**

For an example of how to install a package in the VCH endpoint VM, see [Mount an NFS Share Point in the VCH Endpoint VM](vch_mount_nfsshare.md).