###Cannot deploy from Harbor private repository to a VCH via Admiral

There is an existing limitation in deploying a docker image from a repository marked private in Harbor to a VCH via the Admiral portal. You _can_ deploy from a private repository to a VCH using `docker login` and the regular docker client. However, Admiral uses a different code path that is not yet supported by VIC engine. The workaround is to make the repository public or use the Docker client.

###No image tagging support yet in VIC 0.5.5

This means that if you pull an image into a VCH image cache using a particular path (say registry.hub.docker.com/library/busybox), you can't then subsequently pull or run the same image using a different path. Even if it's simply a port added registry.hub.docker.com:80/library/busybox - it's still an image tag and it still counts. VIC 0.5.5 doesn't yet support deleting images either, so for now, just pick a repository path and stick with it. You can edit the image path when you provision in Admiral if you want.

###Nested environments

Deploying containers to a VCH deployed in nested ESX with some forms of shared storage can lead to timeouts. This is more to do with storage latencies which is exaccerbated by the nesting. iSCSI NAS seems to work fine, but NFS performance can be limiting. This is currently being investigated. https://github.com/vmware/vic/issues/1822.

###Mapping port 8080 is not supported with VIC Engine 

Please note that, for the time being, mapping on port 8080:80 is not possible with VIC Engine: https://github.com/vmware/vic/issues/2006.

###Docker links when used in Admiral in conjunction with VIC Engine will fail

While VIC Engine (when used through the CLI) and Admiral (when used to deploy containers on Docker Engines) both support the usage of links individually, there is a known limitation when deploying linked containers via Admiral to a VIC Engine end-point. This is actively being worked on. 

###Stats not available for ContainerVMs 

For containerVMs deployed with Admiral to a VIC Engine endpoint, stats are not available. This is actively being worked on.   

###The terminal functionality in Admiral is not available for ContainerVMs 

Leveraging the terminal functionality in Admiral for a container deployed to a VIC Engine end-point is not supported.    

###Admiral can’t map the same port out on the external network

There is a limitation right now with Admiral that prevents container ports to be exposed outside on the same port. That is to say you should avoid mapping 5000 to 5000 (or 443 to 443 for that matter). This is going to be fixed soon. 

###Admiral can’t map to port 80 when used with Linux Hosts and Docker Engine

The Admiral container agent that gets instantiated on Linux hosts running Docker Engine uses port 80 and so user containers cannot be mapped out on port 80. This is being fixed by the Admiral engineering team. Admiral deploying to a VIC endpoint doesn’t experience this problem since the Admiral container agent is not instantiated on the VCH.  

###Admiral only support the exec form 

When importing Docker compose files, please note that the exec form (e.g. command: ["mongod", "--smallfiles"] is the only currently supported option. This is a known issue and should be fixed soon.

###Retired containers 

If you play with the Docker CLI behind the scene Admiral may leave some containers in “retired” state. This is by design. Note these do not get purged automatically.   
There are discussions going on re how to be able, for example, to set a flag (user choice) to show or not to show these retired containers. Note these do not get purged automatically.   
