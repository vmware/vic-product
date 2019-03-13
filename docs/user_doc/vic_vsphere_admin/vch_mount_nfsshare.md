# Mount an NFS Share Point in the VCH Endpoint VM #

When creating an NFS client mount, the combination of permissions and settings on the server side and the number of possible combinations of options on the client side can make it very difficult to test. In addition, the question of which ports to open on firewalls can also cause connection problems.

If you deploy VCHs that use NFS share points as volume stores, you can test  the connections to these share points by mounting the NFS server from within the VCH endpoint VM. Confirming that you can mount the NFS share point from within the endpoint VM confirms that the NFS volume store configuration will also work. However, the `mount.nfs` package is not included in the VCH endpoint VM by default. You must use the [Photon OS package manager, Tiny DNF](https://vmware.github.io/photon/assets/files/html/1.0-2.0/tdnf.html), to add it manually. VCHs run Photon OS 2.0. 

## Prerequisites

- Run the `vic-machine debug` command with the `--enable-ssh` and `--rootpw` options to enable SSH access to the VCH endpoint VM and to set the root password. For information about `vic-machine debug`, see [Debug Running Virtual Container Hosts](debug_vch.md).
- Follow the instructions in [Install Packages in the Virtual Container Host Endpoint VM](vch_install_packages.md) to configure the VCH endpoint VM so that it can run Tiny DNF commands.
- You have an NFS share point that is configured for anonymous mounting. 
- Use SSH to connect to the VCH endpoint VM as root user.

## Procedure

1. Install the `nfs-utils` package.<pre>tdnf install nfs-utils</pre>
2. Install the `iana-etc` package.

    This package adds the  `/etc/services` file, which is not present by default.<pre>tdnf install iana-etc</pre>
3. Start the `rpcbind` service.<pre>systemctl start rpcbind</pre>
4. Check the status of the `rpcbind` service.<pre>systemctl status rpcbind</pre>If `rpcbind` is running correctly, you should see the message:<pre>* rpcbind.service - RPC Bind Service
   Loaded: loaded (/usr/lib/systemd/system/rpcbind.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2018-03-06 16:15:17 UTC; 10s ago
  Process: 1025 ExecStart=/usr/sbin/rpcbind $RPCBIND_OPTIONS -w (code=exited, status=0/SUCCESS)
 Main PID: 1028 (rpcbind)
    Tasks: 1
   CGroup: /system.slice/rpcbind.service
           `-1028 /usr/sbin/rpcbind -w
Mar 06 16:15:17 Linux systemd[1]: Starting RPC Bind Service...
Mar 06 16:15:17 Linux systemd[1]: Started RPC Bind Service.</pre>
5. Mount the NFS share point in the VCH endpoint VM.<pre>mount -t nfs <i>nfs_sharepoint_url</i> -o vers=3</pre>For information about how to specify the NFS sharepoint URL, see the description of the `vic-machine create --volume-store` option in [Specify Volume Datastores](volume_stores.md#nfsoptions).

## Result

If the mount operation was successful, the NFS share point is correctly configured for use as a volume store by this VCH.