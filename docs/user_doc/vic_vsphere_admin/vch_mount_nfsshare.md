# Mount an NFS Share Point in the VCH Endpoint VM #

When creating an NFS client mount, the combination of permissions and settings on the server side and the number of possible combinations of options on the client side can make it very difficult to test. In addition, the question of which ports to open on firewalls can also cause connection problems.

If deploy VCHs that use NFS share points as volume stores, you can test  the connections to these share points by mounting the NFS server from within the VCH endpoint VM. Confirming that you can mount the NFS share point from within the endpoint VM confirms that the NFS volume store configuration will also work. However, the `mount.nfs` package is not included in the VCH endpoint VM by default, so you must use the Photon OS package manager, Tiny DNF, to add it manually.

**Prerequisites**

- Run the `vic-machine debug` command with the `--enable-ssh` and `--rootpw` options to enable SSH access to the VCH endpoint VM and to set the root password. For information about `vic-machine debug`, see [Debug Running Virtual Container Hosts](debug_vch.md).
- Follow the instructions in [Install Packages in the Virtual Container Host Endpoint VM](vch_install_packages.md) to configure the VCH endpoint VM so that it can run Tiny DNF commands.
- Use SSH to log in to the VCH endpoint VM as root user.

**Procedure**

1. Install the `nfs-utils` package.<pre>tdnf --releasever 1.0 install nfs-utils</pre>
3. Install the `iana-etc-2.30-2.ph1` package.

    This package adds the  `/etc/services` file, which is not present by default.<pre>tdnf install iana-etc-2.30-2.ph1</pre>
4. <pre>ls -al /usr/sbin/mount.nfs</pre>
5. <pre>systemctl status rpcbind</pre>
6. <pre>mount -t nfs ...</pre>


Some assumptions that we are making is that the share is configured for anonymous mounting. and that if a `UID` and `GID` is not specified at create time of the volumestore then we also used `1000:1000` to attempt to create the volume store as well.

Another option is to start a container that has an nfs client and attempt a mount from within the container. This is a better option for a VCH user that doesn't have access to vic-machine, but we should assume that setting up NFS for a datastore is a vSphere admin task that presumes vic-machine access. 