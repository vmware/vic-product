# Install Packages in the Virtual Container Host Endpoint VM #

In certain circumstances, you might need to install a capability in the virtual container host (VCH) endpoint VM that does not exist by default. For example, you might want to install an NFS client in the endpoint VM, to test or debug connections from the VCH to an NFS server.

The VCH endpoint VM runs [Photon OS 2.0](https://vmware.github.io/photon/). Photon OS provides a package manager named Tiny DNF, or `tdnf`, that is the default means of installing packages. For information about Tiny DNF, see [Tiny DNF for Package Management](https://vmware.github.io/photon/assets/files/html/1.0-2.0/tdnf.html) in the *Photon OS Administration Guide*. 

**IMPORTANT**: 

Any installations and configurations that you perform by using Tiny DNF in the endpoint VM do not persist if you reboot the endpoint VM.

## What to Do Next

For an example of how to install a package in the VCH endpoint VM, see [Mount an NFS Share Point in the VCH Endpoint VM](vch_mount_nfsshare.md).