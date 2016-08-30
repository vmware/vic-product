
This page is intended to guide you through setting up a complete vSphere Integrated Containers (VIC) stack. 

##Components Overview

The setup architecture that is described in this page may change for future releases. For the time being we are going to use VIC Engine to deploy only “user workloads”. 

For all other purposes, we will use a Linux VM.

###The Linux VM 

As mentioned earlier, to setup VIC (at the current stage) you need a working vSphere environment as well as a Linux VM that we are going to use to achieve various tasks including: 

1. A system to run vic-machine to deploy and manage VCH endpoints in vSphere.
2. A Docker client to exercise VIC Engine and the other components.  
3. A Docker Host to run Harbor (delivered as a set of containers).
4. A Docker Host to run Admiral (delivered as a container).

This Linux VM can ideally be hosted on the same vSphere Infrastructure used to deploy deploy the user workloads. 

*Please note: For #1 and #2 you can also use your laptop (Linux, Windows, Mac), but throughout this document, for convenience, we assume all of them are executed on this Linux VM.*  

##Pre-requisites 

Before you start, make sure you have a vSphere environment that satisfy [these requirements](https://vmware.github.io/vic/assets/files/html/vic_installation/vic_installation_prereqs.html).

##Setup instructions

These instructions will guide you through the process of setting up vSphere Integrated Containers (all three components) and deploy various sample containers to exercise the behaviour of the solution. 

- [Setting up the Linux Docker host](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/setup-linux-docker-host.md)

- [Installing and configuring the Virtual Container Host (VCH)](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/install-configure-vch.md)

- [Installing and configuring Harbor](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/install-configure-harbor.md)

- [Using Harbor](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/using-harbor.md)

- [Installing and configuring Admiral](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/install-configure-admiral.md)

- [Deploying a simple container on VCH1 via Admiral](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/deploy-simple-container-on-vch1-via-admiral.md)

- [Known Issues and Limitations](https://github.com/vmware/vic-product/blob/master/docs/setup/alpha/known-issues-limitations.md)



