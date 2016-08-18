###Nested environments

We have seen a high level of failures when deploying VIC Engine in nested environments that uses shared storage. The issue may potentially be due to storage performance than nested per se. This is currently being investigated:
https://github.com/vmware/vic/issues/1822.

###Mapping port 8080 is not supported with VIC Engine 

Please note that, for the time being, mapping on port 8080:80 is not possible with VIC Engine: https://github.com/vmware/vic/issues/2006.

###Docker links when used in Admiral in conjunction with VIC Engine will fail

While VIC Engine (when used through the CLI) and Admiral (when used to deploy containers on Docker Engines) both support the usage of links individually, there is a known limitation when deploying linked containers via Admiral to a VIC Engine end-point. This is actively being worked on. 

###Stats not available for ContainerVMs 

For containerVMs deployed with Admiral to a VIC Engine endpoint, stats are not available. This is actively being worked on.   

###The terminal functionality in Admiral is not available for ContainerVMs 

Leveraging the terminal functionality in Admiral for a container deployed to a VIC Engine end-point is not supported.    

###Virtual Container Hosts can’t connect to Harbor 

VIC does not yet support docker login and this is preventing VIC to connect to Harbor as a local registry. This is also true for Harbor public projects.

Technical details: Harbor is setup with authentication/authorization enabled, so the mechanism of authorization always kicks in. The Docker client always need to get a token from the registry. The registry will grant access to the client if the project is public. VIC doesn’t yet support authentication/authorization, so it cannot complete the normal flow of getting a token and get access granted. Therefore, it cannot access public projects either. 


###Admiral can’t map the same port out on the external network

There is a limitation right now with Admiral that prevents container ports to be exposed outside on the same port. That is to say you should avoid mapping 5000 to 5000 (or 443 to 443 for that matter). This is going to be fixed soon. 

###Admiral can’t map to port 80 when used with Linux Hosts and Docker Engine

The Admiral container agent that gets instantiated on Linux hosts running Docker Engine uses port 80 and so user containers cannot be mapped out on port 80. This is being fixed by the Admiral engineering team. Admiral deploying to a VIC endpoint doesn’t experience this problem since the Admiral container agent is not instantiated on the VCH.  

###VIC can’t work with the extended image path 

Admiral, by default, includes the entire path to describe the image location (e.g. registry.hub.docker.com/library/busybox). This will not work when deploying to a VIC endpoint. As a workaround you can remove the registry address (e.g. use instead library/busybox). 

###Admiral only support the exec form 

When importing Docker compose files, please note that the exec form (e.g. command: ["mongod", "--smallfiles"] is the only currently supported option. This is a known issue and should be fixed soon.

###Retired containers 

If you play with the Docker CLI behind the scene Admiral may leave some containers in “retired” state. This is by design. Note these do not get purged automatically.   
There are discussions going on re how to be able, for example, to set a flag (user choice) to show or not to show these retired containers. Note these do not get purged automatically.   
