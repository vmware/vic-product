A Linux VM with the Docker daemon installed is the way to run containers using vanilla Docker. It wont't be long before you can provision Linux Docker hosts using VIC engine. 

For now though, this doc will take you through the process of getting set up with Photon or Ubuntu Linux in a regular VM.

### Photon OS 1.0 

Photon is VMware's Linux distro for running containers. You can grab the OVA for Photon OS 1.0 [here](https://vmware.github.io/photon/) or alternatively, you can download an ISO.

Additional information on getting Photon OS up and running on your platform of choice can be found [here](https://github.com/vmware/photon/wiki)

Note the default `root` password is `changeme`. You will be prompted to change it. 

#### Install Docker

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
Throughout the document, we will be performing a number of additional tasks that require linux utilities that are not available out of the box. You have to install them as well:
```
tdnf install git tar 
```

### Ubuntu 14.04.5

For convenience, we will be running as root. The simplest way to do this in Ubuntu without enabling the root user is to type:
```
sudo bash
```

#### Install Docker

The official procedure is [here](https://docs.docker.com/engine/installation/linux/ubuntulinux/)

This is a short list of all the commands you need to run:
```
apt-get update
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```
create a file called `/etc/apt/sources.list.d/docker.list` and insert `deb https://apt.dockerproject.org/repo ubuntu-trusty main`
```
apt-get update
apt-get install linux-image-extra-$(uname -r)
apt-get install docker-engine
```
If you have any problem, please follow the complete procedure at the link above. 

If everything was installed correctly, this is what you should see: 
```
root@lab-vic01:~/vic# docker version
Client:
 Version:      1.12.x
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   8eab29e
 Built:        Thu Jul 28 22:00:36 2016
 OS/Arch:      linux/amd64

Server:
 Version:      1.12.x
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   8eab29e
 Built:        Thu Jul 28 22:00:36 2016
 OS/Arch:      linux/amd64
```
This is the output of `docker info`: 
```
root@lab-vic01:~/vic# docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 1.12.0
Storage Driver: aufs
 Root Dir: /var/lib/docker/aufs
 Backing Filesystem: extfs
 Dirs: 0
 Dirperm1 Supported: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: null host bridge overlay
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Security Options: apparmor
Kernel Version: 3.19.0-25-generic
Operating System: Ubuntu 14.04.3 LTS
OSType: linux
Architecture: x86_64
CPUs: 4
Total Memory: 7.797 GiB
Name: lab-vic01
ID: BPYD:IEOK:OYRL:3AKZ:D2BO:EIM5:BK7F:PQ7U:43OT:YEUQ:AMZS:3S4E
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
WARNING: No swap limit support
Insecure Registries:
 127.0.0.0/8
```

### Common for both Ubuntu and Photon OS  

#### Install docker-compose

Full documentation is located [here](https://docs.docker.com/compose/install/)

These are the two commands you really need to run:
```
curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
