# Container Networking with vSphere Integrated Containers Engine #

The following sections present examples of how to perform container networking operations when using vSphere Integrated Containers Engine as your Docker endpoint.

- [Publish a Container Port](#port)
- [Add Containers to a New Bridge Network](#newbridge)
- [Bridged Containers with an Exposed Port](#bridgeport)
- [Deploy Containers on Multiple Bridge Networks](#multibridge)
- [Connect Containers to External Networks](#external)
- [Deploy Containers That Use Multiple Container Networks](#multinet)
- [Deploy a Container with a Static IP Address](#staticip)

To perform certain networking operations on containers, your Docker environment and your virtual container hosts (VCHs) must be configured in a specific way.

- For information about the default Docker networks, see https://docs.docker.com/engine/userguide/networking/.
- For an overview of the networks that vSphere Integrated Containers Engine uses, see [Networks Used by vSphere Integrated Containers Engine](../vic_vsphere_admin/networks.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.
- For information about the networking options with which vSphere administrators can deploy VCHs, see the sections in VCH Deployment Options on [Networking Options](../vic_vsphere_admin/vch_installer_options.md#networking) and [Options for Configuring a Non-DHCP Network for Container Traffic](../vic_vsphere_admin/vch_installer_options.md#adv-container-net) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.
- For examples of how to deploy VCHs with different network configurations, see the section in Advanced Examples of Deploying a VCH on [Networking Examples](../vic_vsphere_admin/vch_installer_examples.md#networking) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.


## Publish a Container Port {#port}

Connect a container to an external mapped port on the public network of the VCH:

`$ docker run -p 8080:80 --name test1 my_container my_app`

**Result:**  You can access Port 80 on `test1` from the public network interface on the VCH at port 8080.

## Add Containers to a New Bridge Network {#newbridge}

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

## Bridged Containers with an Exposed Port {#bridgeport}

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

## Deploy Containers on Multiple Bridge Networks {#multibridge}

Create containers on multiple bridge networks by mapping ports through the VCH. The VCH must have an IP address on the relevant bridge networks. To create bridge networks, use  `network create`.

Run a container that is connected to two networks:

 `docker run -it --net net1 --net net2 busybox`

Run containers that can each only reach one of the networks:

	docker run -it --net net1 --name n1 busybox
	docker run -it --net net2 --name n2 busybox

Run a container that can reach both networks:

	docker run -it --net net1 --net net2 --name n12 busybox

**Result:**  
- `n1` and `n2` cannot communicate with each other
- `n12` can communicate with both `n1` and `n2`

## Connect Containers to External Networks {#external}

Configure two external networks in vSphere:

- `default-external` is `10.2.0.0/16` with gateway `10.2.0.1`  
- `vic-production` is `208.91.3.0/24` with gateway `208.91.3.1`  

Deploy a VCH that uses the default network at 208.91.3.2 as its public network.

`docker network ls` shows:

    $ docker network ls
    NETWORK ID          NAME                DRIVER
    e2113b821ead        none                null
    37470ed9992f        default-external    bridge
    ea96a6b919de        vic-production      bridge
    b7e91524f3e2        bridge              bridge  

You have a container that provides a Web service to expose outside of the vSphere Integrated Containers Engine environment.

Output of `docker network inspect default-external`:

    [
        {
            "Name": "default-external",
            "Id": "id",
            "Scope": "external",
            "Driver": "bridge",
            "IPAM": {
                "Driver": "default",
                "Options": {},
                "Config": [
                    {
                        "Subnet": "10.2.0.0/16",
                        "Gateway": "10.2.0.1"
                    }
                ]
            },
            "Containers": {},
            "Options": {}
        }
    ]

Output of `docker network inspect vic-production`:

    [
        {
            "Name": "vic-production",
            "Id": "id",
            "Scope": "external",
            "Driver": "bridge",
            "IPAM": {
                "Driver": "default",
                "Options": {},
                "Config": [
                    {
                        "Subnet": "208.91.3.0/24",
                        "Gateway": "208.91.3.1"
                    }
                ]
            },
            "Containers": {},
            "Options": {}
        }
    ]

Set up a server on the `vic-production` network:

    $ docker run -d --expose=80 --net=vic-production --name server my_webapp
    {% raw %}$ docker inspect 
      --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 
      server{% endraw %}
    208.91.3.2
    $ telnet 208.91.3.2 80
    Trying 208.91.3.2...
    Connected to 208.91.3.2.
    Escape character is '^]'.
    GET /
    
    Hello world!Connection closed by foreign host.

**NOTE:** You can also use `-p 80` or `-p 80:80` instead of
`--expose=80`. If you try to map to different ports with `-p`, you get a configuration error.

**Result:**  The `server` container port is exposed on the external `vic-production` network.

## Deploy Containers That Use Multiple Container Networks {#multinet}

Create multiple container networks by using `vic-machine create --container-network`. 

**NOTE**: The networks known as container networks in vSphere Integrated Containers Engine terminology correspond to external networks in Docker terminology.

Example:

    ./vic-machine-darwin create --target 172.16.252.131 --image-store datastore1 --name vic-demo --user root --password 'Vmware!23' --compute-resource /ha-datacenter/host/*/Resources --container-network pg1:pg1 --container-network pg2:pg2 --container-network pg3:pg3

`pg1-3` are port groups on the ESX Server that are now mapped into `docker network ls`.

    $ docker -H 172.16.252.150:2376 --tls network ls
    NETWORK ID   NAME   DRIVER
    903b61edec66 bridge bridge
    95a91e11b1a8 pg1    external
    ab84ba2a326b pg2    external
    2df4101caac2 pg3    external


If a container is connected to a container network, the traffic to and from that network does not go through the VCH.

You also can create more bridge networks via the Docker API. These are all backed by the same port group as the default bridge, but those networks are isolated via IP address management.

    Example:
    $ docker -H 172.16.252.150:2376 --tls network create mike
    0848ee433797c746b466ffeb57581c301d8e96b7e82a4d524e0fa0222860ba44
    $ docker -H 172.16.252.150:2376 --tls network create bob
    316e34ff3b7b19501fe14982791ee139ce98e62d060203125c5dbdc8543ff641
    $ docker -H 172.16.252.150:2376 --tls network ls
    NETWORK ID   NAME   DRIVER
    316e34ff3b7b bob    bridge
    903b61edec66 bridge bridge
    0848ee433797 mike  bridge
    95a91e11b1a8 pg1    external
    ab84ba2a326b pg2    external
    2df4101caac2 pg3    external

**Result:**  You can create containers with `--net mike` or `--net pg1` and be on the correct network. With Docker you can combine them and attach multiple networks.

## Deploy a Container with a Static IP Address {#staticip}

Deploy a container that has a static IP address on the container network. For you to be able to deploy containers with static IP addresses, the vSphere administrator must have specified the [`--container-network-ip-range`](../vic_vsphere_admin/vch_installer_options.md#container-network-ip-range) option when they deployed the VCH. The IP address that you specify in `docker network connect --ip` must be within the specified range. If you do not specify `--ip`, the VCH assigns an IP address from the range that the vSphere administrator specified in `--container-network-ip-range`.

<pre>$ docker network connect --ip <i>ip_address</i> container-net container1</pre>

**Result:**  The container `container1` runs with the specified IP address on the `container-net` network.