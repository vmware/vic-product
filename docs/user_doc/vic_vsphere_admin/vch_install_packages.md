# Install Packages in the Virtual Container Host Endpoint VM #

There are reasons why you might want to install a capability in the VIC endpoint VM that doesn't exist out of the box. An NFS client, for example, to test or debug connection to an NFS server.

Currently, tdnf doesn't work in the endpoint VM without first running rpm --rebuilddb. Stress that whatever you do, it doesn't persist.

https://github.com/vmware/tdnf/wiki

The error seen before doing the rpm --rebuilddb is 

```
root@ [ ~ ]# tdnf info
Error(1304) : Hawkey - I/O error
```


Important to also note that rpm --rebuilddb gives you an unpopulated database so it doesn't know about existing packages. That means that if you install something, tdnf will try to install every other dependency into the endpoint VM, even if that dependency is already there.

## Example: Mount an NFS Share in the VCH Endpoint VM ##

At a customer last week, I sat with them while they tried to set up NFS volume support in VIC 1.2.1.

NFS client mount isn't that helpful at the best of times, but the combination of permissions and settings on the server side and the subsequent number of possible combinations of options on the client side make it very difficult to test. Add to that the question of which ports need to be open on firewalls even if the client can ping the NFS server.

Installing / deleting the VCH and looking for errors in the VIC management portal is too clumsy to be practical and in the experience at this customer site, wasn't showing any useful info.

**Solutions**

The most obvious and simplest solution is to enable SSH on the endpoint VM using vic-machine debug and try to mount the NFS server from inside the endpoint VM. One should assume that if this works, the NFS datastore configuration should also work. However, the problem here is that mount.nfs is not included in the endpoint and it's not at all obvious how to add it.

Another option is to start a container that has an nfs client and attempt a mount from within the container. This is a better option for a VCH user that doesn't have access to vic-machine, but we should assume that setting up NFS for a datastore is a vSphere admin task that presumes vic-machine access.

Some assumptions that we are making is that the share is configured for anonymous mounting. and that if a `UID` and `GID` is not specified at create time of the volumestore then we also used `1000:1000` to attempt to create the volume store as well.

An example what to do if you want to mount a NFS share.

```
rpm --rebuilddb
tdnf --releasever 1.0 install nfs-utils
tdnf install iana-etc-2.30-2.ph1
ls -al /usr/sbin/mount.nfs
systemctl status rpcbind
mount -t nfs ...
```

The `iana-etc-2.30-2.ph1` package is needed to get the file `/etc/services` which is missing. I had to add `--releasever 1.0` to make the install command work, but I do not know if this is necessary in general. I also had to change the default Photon repo, since it was pointing to a wrong repo.
