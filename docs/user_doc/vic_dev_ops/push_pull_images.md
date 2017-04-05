#Pulling and Pushing Images to and From vSphere Integrated Containers Registry

MIGRATE MOST OF THIS INFO TO APP DEV

**NOTE: vSphere Integrated Containers Registry only supports Registry V2 API. You need to use Docker client 1.6.0 or higher.**  

vSphere Integrated Containers Registry uses HTTPS for secure communication by default. A self-signed certificate is generated at first boot based on its FQDN (Fully Qualified Domain Name) or IP address. If you use Docker client to interact with it, there are two options you can choose:  

1. Trust the certificate of vSphere Integrated Containers Registry's CA  
Refer to the "Getting Certificate of vSphere Integrated Containers Registry's CA" part of [installation guide](installation_guide_ova.md).  
2. Set "--insecure-registry" option  
Add "--insecure-registry" option to /etc/default/docker (ubuntu) or /etc/sysconfig/docker (centos) and restart Docker service.  
	
If vSphere Integrated Containers Registry is configured as using HTTP, just set the "--insecure-registry" option.  

If the certificate used by vSphere Integrated Containers Registry is signed by a trusted authority, Docker should work without any additional configuration.  

###Pulling images
If the project that the image belongs to is private, you should sign in first:  

```sh
$ docker login 10.117.169.182  
```
  
You can now pull the image:  

```sh
$ docker pull 10.117.169.182/library/ubuntu:14.04  
```

**Note: Replace "10.117.169.182" with the IP address or domain name of your vSphere Integrated Containers Registry node.**

###Pushing images
Before pushing an image, you must create a corresponding project on vSphere Integrated Containers Registry web UI. 

First, log in from Docker client:  

```sh
$ docker login 10.117.169.182  
```
  
Tag the image:  

```sh
$ docker tag ubuntu:14.04 10.117.169.182/demo/ubuntu:14.04  
``` 

Push the image:

```sh
$ docker push 10.117.169.182/demo/ubuntu:14.04  
```  

**Note: Replace "10.117.169.182" with the IP address or domain name of your vSphere Integrated Containers Registry node.**