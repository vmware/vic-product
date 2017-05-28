```
Mirrored from: https://blogs.vmware.com/vsphere/2017/02/connecting-containers-directly-external-networks.html
Author: Hasan Mahmood
Posted: February 6, 2017
```

# Connecting Containers Directly to External Networks

With vSphere Integrated Containers (VIC), containers can be connected to any existing vSphere network, allowing for services running on those containers to be exposed directly, and not through the container host, as is the case with Docker today. vSphere networks can be specified during a VIC Engine deployment, and they show up as regular docker networks.

Connecting containers directly to networks this way allows for a clean separation between internal networks that are used for deployment from external networks that are only used for publishing services. Exposing a service in docker requires port forwarding through the docker host, forcing use of network address translation (NAT) as well as making separating networks somewhat complicated. With VIC, you can use your existing networks (and separation that is already there) seamlessly through a familiar docker interface.

## Setup

To add an existing vSphere network to a VIC Engine install, use the collection of –container-network options for the vic-machine tool. Here is an example run:

```
$ vic-machine-linux create --target administrator@vsphere.local:password@vc --no-tlsverify --thumbprint C7:FB:D5:34:AA:B3:CD:B3:CD:1F:A4:F3:E8:1E:0F:88:90:FF:6F:18 --bridge-network InternalNetwork --public-network PublicNetwork --container-network PublicNetwork:public
```

The above command installs VIC adding an additional network for containers to use called public. The notation _PublicNetwork:public_ maps an existing distributed port group called _PublicNetwork_ to the name _public_. After installation, we can see that the public network is visible to docker:

```
$ docker -H 10.17.109.111:2376 --tls network ls
 NETWORK ID          NAME                DRIVER              SCOPE
 62d443e3f5c1        bridge              bridge                                  
 b74bb80d92ad        public              external
```

To connect this network, use the _-net_ option to the _docker create_ or _run_ command:

```
$ docker -H 10.17.109.111:2376 --tls run -itd --net public nginx
 Unable to find image 'nginx:latest' locally
 Pulling from library/nginx
 386a066cd84a: Pull complete 
 a3ed95caeb02: Pull complete 
 386dc9762af9: Pull complete 
 d685e39ac8a4: Pull complete 
 Digest: sha256:e56314fa645f9e8004864d3719e55a6f47bdee2c07b9c8b7a7a1125439d23249
 Status: Downloaded newer image for library/nginx:latest
 4c17cb610a3ce9651288699ed18a9131022eb95b0eb54f4cd80b9f23fa994a6c
```

Now that a container is connected to the public network, we need to find out its IP address to access any exported services, in this case, the welcome page for the nginx web server. This can be done by the _docker network inspect_ command, or the _docker inspect_ command. We will use _docker network inspect_ here since the output is more concise:

```
$ docker -H 10.17.109.111:2376 --tls network inspect public
 [
     {
         "Name": "public",
         "Id": "b74bb80d92adf931209e691d695a3c133fad49496428603fff12d63416c5ed4e",
         "Scope": "",
         "Driver": "external",
         "EnableIPv6": false,
         "IPAM": {
             "Driver": "",
             "Options": {},
             "Config": [
                 {
                     "Subnet": "10.17.109.0/24",
                     "Gateway": "10.17.109.253"
                 }
             ]
         },
         "Internal": false,
         "Containers": {
             "4c17cb610a3ce9651288699ed18a9131022eb95b0eb54f4cd80b9f23fa994a6c": {
                 "Name": "serene_carson",
                 "EndpointID": "4c17cb610a3ce9651288699ed18a9131022eb95b0eb54f4cd80b9f23fa994a6c",
                 "MacAddress": "",
                 "IPv4Address": "10.17.109.125/24",
                 "IPv6Address": ""
             }
         },
         "Options": {},
         "Labels": {}
     }
 ]
```

We now know that our running container’s IP address is 10.17.109.125. Next, we can try reaching nginx via the browser.

![Image of nginx in Firefox](https://blogs.vmware.com/vsphere/files/2017/01/nginx.png)

This example only offers a very simple example of how to make vSphere networks available to VIC containers.  You can learn more about the different networks that the VIC container host connects to.  Download vSphere Integrated Containers today!
