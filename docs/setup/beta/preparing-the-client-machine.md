The client machine where you will kick off the deployment of VIC Virtual Container Hosts, the Harbor virtual appliance and more generally how you will interact with VIC from a management and operational perspective.

In this brief tutorial we will also use this client machine to "consume" VIC as well (e.g. by instantiating containerVMs).

Generally speaking, the client machine could be your laptop running your choice of Mac, Windows or Linux. Alternatively it can be a linux VM that you will use and customize specifically for these actions.

You could of course decide to have more than one machine to carry on these tasks (e.g. a Linux VM to run scripts and a Windows / Mac laptop with a browser).

For the remaining of this document it is assumed that a Linux machine (Photon OS 1.0) is being used.

If you intend to use a Mac the instructions are going to be fairly similar. For Windows they may be formatted a little bit differently depending on the tools being used at any point in time.

### Install Docker

Note that Photon OS 1.0 comes with Docker 1.11 pre-installed.

Once you are up and running with Photon OS, you only need to start Docker:
```
systemctl start docker
```
Make sure you make the docker daemon start at reboot by using:
```
systemctl enable docker
```
At this point, this is what you should see running `docker version`:
```
root@photonOSvm1 [ ~ ]# docker version
Client:
 Version:      1.11.0
 API version:  1.23
 Go version:   go1.5.4
 Git commit:   4dc5990
 Built:        Wed Apr 13 19:36:04 2016
 OS/Arch:      linux/amd64

Server:
 Version:      1.11.0
 API version:  1.23
 Go version:   go1.5.4
 Git commit:   4dc5990
 Built:        Wed Apr 13 19:36:04 2016
 OS/Arch:      linux/amd64
```
You can upgrade to 1.11.2 with the following command:
```
tdnf update docker
```
Note: For the purpose of this document this is all you need. However, if you want to get the latest version of Docker available in the Photon OS development repository, you can follow [these instructions](https://github.com/vmware/photon/wiki/Frequently-Asked-Questions#q-where-can-i-get-the-latest-version-of-a-package)

This is the output of `docker info`:
```
root@photonOSvm1 [ ~ ]# docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 1.11.2
Storage Driver: overlay
 Backing Filesystem: extfs
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: null host bridge
Kernel Version: 4.4.8-esx
Operating System: VMware Photon/Linux
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 1.958 GiB
Name: photonOSvm1
ID: MOKN:SZ5O:RVP5:WG6L:JDZ4:TWLE:QPHP:27SZ:WQDK:WSAD:KTTC:KDVQ
Docker Root Dir: /var/lib/docker
Debug mode (client): false
Debug mode (server): false
Registry: https://index.docker.io/v1/
WARNING: No kernel memory limit support
```

If you are using a Mac as your client you may want to install [Docker for Mac](https://docs.docker.com/engine/installation/mac/).

If you are using Windows as your client you may want to install [Docker for Windows]https://docs.docker.com/engine/installation/windows/.


### Other tooling

Throughout the document, we will be performing a number of additional tasks that require linux utilities that are not available out of the box. You have to install them as well:
```
tdnf install git tar
```

Optionally, you may also want to install Docker Compose.

Full documentation is located [here](https://docs.docker.com/compose/install/)

These are the two commands you really need to run:
```
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
