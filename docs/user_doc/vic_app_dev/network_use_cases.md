# Container Networking with vSphere Integrated Containers Engine #

The following sections present examples of how to perform container networking operations when using vSphere Integrated Containers Engine as your Docker endpoint.

- [Publish a Container Port](#port)
- [Container VM Port Forwarding](#portforwarding)
- [Add Containers to a New Bridge Network](#newbridge)
- [Bridged Containers with an Exposed Port](#bridgeport)
- [Deploy Containers on Multiple Bridge Networks](#multibridge)
- [Deploy Containers That Combine Bridge Networks with a Container Network](#containerbridge)
- [Deploy a Container with a Static IP Address](#staticip)

To perform certain networking operations on containers, your Docker environment and your virtual container hosts (VCHs) must be configured in a specific way.

- For information about the default Docker networks, see https://docs.docker.com/engine/userguide/networking/.
- For information about the networking options with which vSphere administrators can deploy VCHs and examples, see [Virtual Container Host Networks](../vic_vsphere_admin/vch_networking.md) in *vSphere Integrated Containers for vSphere Administrators*.

**NOTE**: The default level of trust on VCH container networks is `published`. As a consequence, if the vSphere administrator did not configure `--container-network-firewall` on the VCH, you must specify `-p 80` in `docker run` and `docker create` commands to publish port 80 on a container. Alternatively, the vSphere administrator can configure the VCH to set [`--container-network-firewall`](../vic_vsphere_admin/container_networks.md#container-network-firewall) to a different level. 


## Publish a Container Port <a id="port"></a>

Connect a container VM to an external mapped port on the public network of the VCH:

`$ docker run -p 8080:80 --name test1 my_container my_app`

**Result:**  You can access Port 80 on `test1` from the public network interface on the VCH at port 8080.

## Container VM Port Forwarding <a id="portforwarding"></a>

You can forward a port within a container VM, in the same way you can via NAT on the endpoint VM:

`$ docker run --net=published-container-net -p 80:8080 -d tomcat:alpine`

The above example allows you to access the Tomcat webserver via port 80 on the container VM, via `published-container-net`, instead of being fixed to port 8080 as defined in the Tomcat Dockerfile. This makes it significantly simpler for you to expose services directly via container networks, without having to modify images.

## Add Containers to a New Bridge Network <a id="newbridge"></a>

Create a new non-default bridge network and set up two containers on the network. Verify that the containers can locate and communicate with each other:

    $ docker network create -d bridge my-bridge-network
    $ docker network ls
    ...
    NETWORK ID          NAME                DRIVER
    615d565d498c        my-bridge-network   bridge
    ...
    $ docker run -d --net=my-bridge-network \
                    --name=server my_server_image server_app
    $ docker run -it --name=client --net=my-bridge-network busybox
    / # ping server
    PING server (172.18.0.2): 56 data bytes
    64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.073 ms
    64 bytes from 172.18.0.2: seq=1 ttl=64 time=0.092 ms
    64 bytes from 172.18.0.2: seq=2 ttl=64 time=0.088 ms

**Result:**  The `server` and `client` containers can ping each other by name.

**Note**: Containers created on the default bridge network don't get name resolution by default in the way described above. This is consistent with docker bridge network behavior.

## Bridged Containers with an Exposed Port <a id="bridgeport"></a>

Connect two containers on a bridge network and set up one of the containers to publish a port via the VCH. Assume that `server_app` binds to port 5000.

    $ docker network create -d bridge my-bridge-network
    $ docker network ls
    ...
    NETWORK ID          NAME                DRIVER
    615d565d498c        my-bridge-network   bridge
    ...
    $ docker run -d -p 5000:5000 --net=my-bridge-network \
                    --name=server my_server_image server_app
    $ docker run -it --name=client --net=my-bridge-network busybox
    / # ping -c 3 server
    PING server (172.18.0.2): 56 data bytes
    64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.073 ms
    64 bytes from 172.18.0.2: seq=1 ttl=64 time=0.092 ms
    64 bytes from 172.18.0.2: seq=2 ttl=64 time=0.088 ms
    / # telnet server 5000
    GET /

    Hello world!Connection closed by foreign host
    $ telnet vch_public_interface 5000
    Trying 192.168.218.137...
    Connected to 192.168.218.137.
    Escape character is '^]'.
    GET /

    Hello world!Connection closed by foreign host.

**Result:**  The `server` and `client` containers can ping each other by name. You can connect to  `server` on port 5000 from the `client` container and to port 5000 on the VCH public network.

## Deploy Containers on Multiple Bridge Networks <a id="multibridge"></a>

You can use multiple bridge networks to isolate certain types of application network traffic. An example may be containers in a data tier communicating on one network and containers on a web tier communicating on another. In order for this to work, at least one of the containers needs to be on both networks.

Docker syntax does not allow for the use of multiple `--net` arguments for `docker run` or `docker create`, so to connect a container to multiple networks, you need to use:

`docker network connect [network-id] [container-id]`

**Note**: With VIC containers, networks can only be added to a container when it's in its created state. They can't be added while the container is running.

Create two bridge networks, one for data traffic and one for web traffic

	docker network create --internal bridge-db
	docker network create bridge-web

Create and run the data container(s)

	docker run -d --name db --net bridge-db myrepo/mydatabase

Create and run the web container(s) and make sure one is on both networks. Expose the web front end on port 8080 of the VCH.

	docker create -d --name model --net bridge-db myrepo/web-model
	docker network connect bridge-web web-model
	docker start model
	docker run -d -p 8080:80 --name view --net bridge-web myrepo/web-view

**Result:**  
- `db` and `web-view` cannot communicate with each other
- `web-model` can communicate with both `db` and `web-view`
- `web-view` exposes a service on port 8080 of the VCH

**Note**: A container on multliple bridge networks will not get a distinct network interface for each network, rather it will get multiple IP addresses on the same interface. Use `ip addr` to see the IP addresses.

## Deploy Containers That Combine Bridge Networks with a Container Network <a id="containerbridge"></a>

A "container" network is a vSphere port group that a container can be connected to directly and which allows the container to have an external identity on that network. This can be combined with one or more private bridge networks for intra-container traffic.

**NOTE**: Multiple bridge networks are backed by the same port group as the default bridge, segregated via IP address management. Container networks are strongly isolated from all other networks.

A container network is specified when the VCH is installed using `vic-machine --container-network [existing-port-group]` and should be visible when you run `docker network ls` from a Docker client.

	$ docker network ls
	NETWORK ID          NAME                DRIVER              SCOPE
	baf6919f5721        ExternalNetwork     external            
	fc41d9a86514        bridge              bridge              

The three main advantages of using a container network over exposing a port on the VCH are that:

1) The container can get its own external IP address.
2) The container is not dependent on the VCH control plane being up for network connectivity. This allows the VCH to be powered down or upgraded with zero impact on the network connectivity of the deployed container.
3) This avoids the use of NAT, which will benefit throughput performance

Let's take the above example with the web and data tiers and show how it could be achieved using a container network.

Create one private bridge network for data traffic

	docker network create --internal bridge-db

Create and run the data container(s)

	docker run -d --name db --net bridge-db myrepo/mydatabase

Create and run the web container(s) and make sure one is on both networks. In this example, we only want the web-view container to have an identity on the ExternalNetwork, so the web-model container is only in the data network.

	docker run -d --name model --net bridge-db myrepo/web-model
	docker create -d -p 80 --name view --net bridge-db myrepo/web-view
	docker network connect ExternalNetwork view
	docker start view

**Result:**  
- All the containers can communicate with each other.
- `db` and `web-model` cannot communicate externally
- `web-view` has its own external IP address and its service is available on port 80 of that IP address

**Note**: Given that a container network manifests as a vNIC on the container VM, it has its own distinct network interface in the container.

## Deploy a Container with a Static IP Address <a id="staticip"></a>

Deploy a container that has a static IP address on the container network. For you to be able to deploy containers with static IP addresses, the vSphere administrator must have specified the [`--container-network-ip-range`](../vic_vsphere_admin/container_networks.md#container-network-ip-range) option when they deployed the VCH. The IP address that you specify in `docker network connect --ip` must be within the specified range. If you do not specify `--ip`, the VCH assigns an IP address from the range that the vSphere administrator specified in `--container-network-ip-range`.

<pre>$ docker network connect --ip <i>ip_address</i> container-net container1</pre>

**Result:**  The container `container1` runs with the specified IP address on the `container-net` network.
