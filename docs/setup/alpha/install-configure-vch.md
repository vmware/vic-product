### Installing VIC Engine

A [Virtual Container Host](https://github.com/vmware/vic/blob/master/doc/design/arch/vic-container-abstraction.md) is a Docker endpoint installed into a vSphere cluster that runs Docker Images as lightweight "containerVMs". This document will explain how to install a VCH into your virtual infrastructure.

#### Preparing the VIC Engine binaries and tools

We will use a [Linux Docker host](setup-linux-docker-host.md) as a launch-pad for vic-machine (the CLI utility that allows for VCHs lifecycle). In particular vic-machine allows us to create and delete Virtual Container Hosts.
There are a couple of ways to get ready to launch vic-machine:
- Using an [official release](https://github.com/vmware/vic/releases)
- [Build yourself](https://github.com/vmware/vic/blob/master/README.md) from the source code

For the purpose of this document we are going to use a vic release (namely [0.6.0](https://github.com/vmware/vic/releases/tag/v0.6.0) which is the latest at the time of this writing).

The link to the [Bintray download](https://bintray.com/vmware/vic/Download/v0.6.0) is also available by scrolling down the GitHub release page referenced above.

Right click with your browser on the vic_0.6.0.tar.gz file and copy the link address.

Now move onto the Linux VM we prepared (for convenience just login as root and stay in the /root directory) and run the following command to download the release:
```
curl -L -o vic_0.6.0.tar.gz https://bintray.com/vmware/vic/download_file?file_path=vic_0.6.0.tar.gz
```
Un-tar the package with:
```
tar -zxvf vic_0.6.0.tar.gz
```
Now you should have a directory called vic and inside vic you have all the tools and binaries you need.

Note: if you took the path of [compiling VIC yourself](https://github.com/vmware/vic/blob/master/README.md) you ended up with a new directory in the repo you downloaded. That new directory is called _bin_ and it contains the same tools and binaries that are being shipped with the official release.

You are now ready to deploy your first Virtual Container Host

#### Preparing the vSphere environment

VIC Engine can install a VCH to either a single ESX host or a vSphere cluster. In practical terms, a VCH is a vApp running a small appliance VM that representes the Docker "endpoint" - the engine that the Docker client connects to. ContainerVMs spun up by that appliance are contained within the context of the vApp.

A VCH installed to a single ESX host is functionally equivalent to a Linux host running a Docker engine. A VCH installed to a vSphere cluster is similar in functionality to a Docker Swarm cluster, except that DRS is used to schedule the containerVMs onto hosts.

#### Infrastructure dependencies

##### Compute

If you're deploying to a single ESX host, you can choose to place the VCH in a resource pool, but that's about the only compute option available. On vSphere however, you can choose a vSphere cluster and optionally a resource pool within the cluster. The simplest configuration is to have DRS enabled on the cluster and a shared datastore.

##### Networking

Just like regular Docker, ContainerVMs can have identities on multiple networks. At a minimum, there needs to be an external network defined for containers to access the outside world and a bridge network defined for them to talk to each other. Optionally a management network (exclusively for vSphere management traffic) and a client network (restriced access to the DOCKER_API) can be defined.

Networks are backed by distributed PortGroups, which need to be pre-configured before the VCH is installed.

Please note: VIC Engine supports more granularity in network configurations but this is beyond the scope of this document. If you want to read more about these network options, you can look [here](https://vmware.github.io/vic/assets/files/html/vic_admin/networks.html) and [here](https://vmware.github.io/vic/assets/files/html/vic_app_dev/network_use_cases.html).

##### Storage

Just like a Docker host, a VCH has a local image cache and can create and store volumes. Images, volumes and containers are VMDKs stored on a vSphere datastore. The location of each of these stores can be defined. The container datastore will default to the image datastore if not defined. If you're VCH is installed on a vSphere cluster, the visibility of the storage by the hosts in that cluster is an important consideration. For a host to be an eligible target, it has to be able to access the datastore specified.

#### Summmary of requirements for VIC Engine

- If deploying to a vSphere cluster, you need to have DRS enabled
- The network PortGroups the VCH connects to need to be on a distributed virtual switch
- A dedicated PortGroup (aka layer 2 isolated network) per each VCH being deployed. This is where ContainerVMs provisioned against the VCH will be connected.
- A PortGroup with a DHCP service available that is designated as the “External Network” for the VCH (the VCH only supports DHCP at the time of this writing). This network can be shared with different VCHs.
- A shared datastore (deploying on dedicated datastores work for test purposes but limits features such as DRS, HA, etc)
- Other [pre-requisites](https://vmware.github.io/vic/assets/files/html/vic_installation/vic_installation_prereqs.html) such as having having the appropriate ports open on the firewall for the Docker client

### Installation of the Virtual Container Host (VCH)

Now that you have the tools and binaries as well as your vSphere environment ready, the next step is to start deploying your first VCH. To do so we go on our Linux VM and launch the following commands from the previously unpacked file (vic_0.6.0.tar.gz):

First, run `./vic-machine-linux` to see the options available. You'll see the sub-options, `create, delete, ls, inspect and version`. These options allow you to control the lifecycle of your VCHs. `./vic-machine-linux create --help` will show you all the available options for creating a VCH. There's quite a few, but the example below will simplify this significantly.

```
./vic-machine-linux create --name <name> --target <address of vCenter or ESX> --user <vCenter/ESX uid> --password <pwd> --compute-resource <cluster/optional resource pool> --external-network <external network name> --bridge-network <bridge network name> --image-store <datastore name>
```
Here's now it looks on my system (note I only have a single cluster, so `--compute-resource` didn't need to be specified):
```
./vic-machine-linux create --name VCH1 --target msbu-vc-lab.mgmt.local --user mreferre@vmware.com --password xxxxxxxx --bridge-network vds10g-lab-446-vmnet --external-network vds10g-lab-506-vmnet-eph --image-store vsan-lab
```
Note: if you need more details about the various options that vic-machine supports, please refer to the [official documentation](
vmware.github.io/vic/assets/files/html/vic_installation/vch_installer_options.html)

This is the output you are supposed to be seeing on the screen:
```
INFO[2016-08-16T01:54:31-07:00] ### Installing VCH ####                      
INFO[2016-08-16T01:54:31-07:00] Generating certificate/key pair - private key in ./VCH1-key.pem
INFO[2016-08-16T01:54:32-07:00] Validating supplied configuration            
INFO[2016-08-16T01:54:32-07:00] vDS configuration OK on "vds10g-lab-446-vmnet"
INFO[2016-08-16T01:54:32-07:00] Firewall status: ENABLED on "/lab-dc/host/lab-clus1/w2-sm-c4b1.mgmt.local"
INFO[2016-08-16T01:54:32-07:00] Firewall status: ENABLED on "/lab-dc/host/lab-clus1/w2-sm-c4b2.mgmt.local"
INFO[2016-08-16T01:54:32-07:00] Firewall status: ENABLED on "/lab-dc/host/lab-clus1/w2-sm-c4b3.mgmt.local"
INFO[2016-08-16T01:54:32-07:00] Firewall status: ENABLED on "/lab-dc/host/lab-clus1/w2-sm-c4b4.mgmt.local"
INFO[2016-08-16T01:54:32-07:00] Firewall configuration OK on hosts:          
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b1.mgmt.local"
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b2.mgmt.local"
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b3.mgmt.local"
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b4.mgmt.local"
INFO[2016-08-16T01:54:32-07:00] License check OK on hosts:                   
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b1.mgmt.local"
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b2.mgmt.local"
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b3.mgmt.local"
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/w2-sm-c4b4.mgmt.local"
INFO[2016-08-16T01:54:32-07:00] DRS check OK on:                             
INFO[2016-08-16T01:54:32-07:00]   "/lab-dc/host/lab-clus1/Resources"         
INFO[2016-08-16T01:54:32-07:00] Creating virtual app "VCH1"                  
INFO[2016-08-16T01:54:32-07:00] Creating appliance on target                 
INFO[2016-08-16T01:54:32-07:00] Network role "client" is sharing NIC with "external"
INFO[2016-08-16T01:54:32-07:00] Network role "management" is sharing NIC with "external"
INFO[2016-08-16T01:54:36-07:00] Uploading images for container               
INFO[2016-08-16T01:54:36-07:00] 	"appliance.iso"                             
INFO[2016-08-16T01:54:36-07:00] 	"bootstrap.iso"                             
INFO[2016-08-16T01:54:39-07:00] Registering VCH as a vSphere extension       
INFO[2016-08-16T01:54:44-07:00] Waiting for IP information                   
INFO[2016-08-16T01:54:55-07:00] Waiting for major appliance components to launch
INFO[2016-08-16T01:54:55-07:00] Initialization of appliance successful       
INFO[2016-08-16T01:54:55-07:00]                                              
INFO[2016-08-16T01:54:55-07:00] vic-admin portal:                            
INFO[2016-08-16T01:54:55-07:00] https://10.140.51.101:2378                   
INFO[2016-08-16T01:54:55-07:00]                                              
INFO[2016-08-16T01:54:55-07:00] DOCKER_HOST=10.140.51.101:2376               
INFO[2016-08-16T01:54:55-07:00]                                              
INFO[2016-08-16T01:54:55-07:00] Connect to docker:                           
INFO[2016-08-16T01:54:55-07:00] docker -H 10.140.51.101:2376 --tls info      
INFO[2016-08-16T01:54:55-07:00] Installer completed successfully             
```

Note how we chose (for now) to deploy the VCH on the root of the cluster. It is possible to deploy the VCH inside an existing RP using the appropriate options in the vic-machine command.

VCH1 is both the name of the vApp as well as the name of the endpoint VM that acts as a proxy to the Docker control plane.

In the text shown during the deployment of the VCH, you may have noted the IP of the VCH1 VM on the external network (grabbed from DHCP). If you missed that, you can always check what the IP of the VM is in the vSphere UI:

### Verify connectivity to your VCH

We will now use our Linux VM as the Docker client to connect to the VCH (our new docker end-point).

So far the Docker runtime on our Linux VM has been configured to just talk to the local daemon. We are now going to tell the docker CLI to point to another docker daemon (specifically the one that the VCH1 proxy exposes).

While you can always interactively point to a different host when you run the docker client command, for convenience we are going to set it in an environment variable so that every time you run the docker command you are going to point to the VCH1. To do so just run this command on your Linux VM:
```
export DOCKER_HOST=tcp://10.140.51.101:2376
```
Ideally this is all you’d need to do.

However, note that VIC implements the version 1.23 of the docker API interface. If the docker client you are running on the Linux VM is beyond that version, we also need to tell the client to use the 1.23 version of the APIs.

You do so by running:
```
export DOCKER_API_VERSION=1.23  
```
### Deploying a first container

We are now going to pull the busybox image.  Note we need to use the --tls option to allow secure communication between the Docker client and the Docker host. (This can be disabled by adding `--no-tls` to vic-machine create):
```
root@lab-vic01:~/vic# docker --tls pull busybox
Using default tag: latest
Pulling from library/busybox
a3ed95caeb02: Pull complete
8ddc19f16526: Pull complete
Digest: sha256:65ce39ce3eb0997074a460adfb568d0b9f0f6a4392d97b6035630c9d7bf92402
Status: Downloaded newer image for library/busybox:latest
```
And we are going to instantiate said busybox docker image:
```
root@lab-vic01:~/vic# docker --tls run -it --name mybusybox busybox
/ #
```
As you can see, the VCH took the busybox docker image and instantiated it **as** a VM (as opposed to **in** a VM):

This newly created VM is basically a standard vSphere VM that happens to have been created using docker command lines and that has a Guest OS that is the content of the Docker image. For everything else, it’s just one of the VMs you know and love.

Note this VM sits on the dedicated PortGroup we selected for this VCH and has been assigned IP 172.16.0.3. This is the in-host network bridge Docker uses and VIC emulates. This is the reason why each VCH needs to have a dedicated PortGroup for this network (that is because the 172.16.0.0/16 network is always the same and the various VCHs would step over each others if we connect them to the same ContainerVMs PortGroup).   

Now you can exit from the busybox shell and you are back to your shell.

If you run `docker --tls ps -a` you will see the docker containerVM stopped (that is expected).
You can remove it by typing `docker --tls rm mybusybox`

### Setup of a more meaningful docker image

To exercise and familiarize a bit further with how basic networking works with Docker (and ultimately VIC), we will now instantiate an nginx docker image and expose it on port 80.

***Please note: In the following examples we are going to emulate a traditional Docker host configuration where containers get exposed on the “external network” via port mapping performed by the VCH. As we alluded above VIC supports (and promotes) [alternative ways](https://github.com/vmware/vic/tree/master/doc/design/networking) to configure networks and how containerVMs can be connected and reached***

Now run the following command:
```
root@lab-vic01:~/vic# docker --tls run -d -p 80:80 --name mynginx nginx
Unable to find image 'nginx:latest' locally
Pulling from library/nginx
a3ed95caeb02: Pull complete
51f5c6a04d83: Pull complete
51d229e136d0: Pull complete
bcd41daec8cc: Pull complete
Digest: sha256:9dff4680bc81db31be8f4d6a3323080948282048c432b36c2593d8d8014255bf
Status: Downloaded newer image for library/nginx:latest
167634511cd0b22357b79e65ca47e51755eb55161e5c3619a073a52895e5a842
root@lab-vic01:~/vic#

root@lab-vic01:~/vic# docker --tls ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
167634511cd0        nginx               "nginx -g daemon off;"   2 minutes ago       Running                                 mynginx
```

As you can see the nginx image didn’t exist so, first thing first, it pulled it from Docker hub.

It then instantiated said image as a VM in vSphere behind the scenes. You can see the NGINX ContainerVM if you expand the VCH1 vApp in the vSphere UI.

Note that, with the build we are using at the time of this writing, `docker ps` doesn’t show the ports being mapped (albeit they are).
You can check them explicitly by typing:
```
root@lab-vic01:~/vic# docker --tls port mynginx
80/tcp -> 0.0.0.0:80
```

As a matter of fact, if everything worked correctly, should you now point your browser to port 80 of your Endpoint VM (i.e. your docker endpoint) you can see nginx serving web pages.

This is because the Endpoint VM acts as a NAT between the external world and the inner 172.16.0.0/16 docker defined network.

If you got to this point congratulations, it looks like you have your VIC Engine setup running fine and you are good to move to the next step!

Feel free to continue to play around VIC Engine but mind the limitations we currently have at the time of this writing. An up to date list of supported operations is available [here](https://vmware.github.io/vic/assets/files/html/vic_app_dev/container_operations.html)

### Deleting the VCH

If you want to delete the VCH you installed, you use a vic-machine command like the create one above. Here's an example:

```
./vic-machine-linux delete --force --name VCH1 --target msbu-vc-lab.mgmt.local --user mreferre@vmware.com --password xxxxxxxx
```
