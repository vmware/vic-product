
This page is intended to guide you through setting up a complete vSphere Integrated Containers (VIC) stack.

##Components Overview

VIC is comprised of three major components:

- VIC Engine: this is responsible for exposing vSphere constructs as Docker constructs
- Harbor: this is a Docker compatible enterprise registry
- Admiral: this provides a portal on top of the Virtual Container Hosts.   

The setup architecture that is described in this page may change for future releases.

##vSphere pre-requisites

Before you start, make sure you have a vSphere environment that satisfy [these requirements](https://vmware.github.io/vic/assets/files/html/vic_installation/vic_installation_prereqs.html).

###The client machine  

To setup VIC you only need a working vSphere environment as well as a client machine from where you will install and then interact with all the VIC components:

1. A system to run vic-machine to deploy and manage VCH endpoints in vSphere.
2. A Docker client to exercise VIC Engine and the other components.  
3. A Docker Host to run Harbor (delivered as a set of containers).
4. A Docker Host to run Admiral (delivered as a container).

This Linux VM can ideally be hosted on the same vSphere Infrastructure used to deploy deploy the user workloads.

*Please note: For #1 and #2 you can also use your laptop (Linux, Windows, Mac), but throughout this document, for convenience, we assume all of them are executed on this Linux VM.*  


##Setup instructions

These instructions will guide you through the process of setting up vSphere Integrated Containers (all three components) and deploy various sample containers to exercise the behaviour of the solution.

- [Preparing the client machine](preparing-the-client-machine.md)

- [Installing and configuring Harbor](install-configure-harbor.md)

- [Installing and configuring the Virtual Container Host (VCH)](install-configure-vch.md)

- [Installing and configuring Admiral](install-configure-admiral.md)

- [Using Harbor](using-harbor.md)

- [Deploying a simple container via Admiral](deploy-simple-container-via-admiral.md)

- [Known Issues and Limitations](known-issues-limitations.md)
