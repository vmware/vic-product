```
Mirrored from: https://blogs.vmware.com/vsphere/2017/01/basic-network-configuration-with-vsphere-integrated-containers-engine.html
Author: Andrew Chin
Posted: January 16, 2017
```

# Basic Network Configuration with vSphere Integrated Containers Engine

This post will discuss how to configure some of the basic networking options when deploying a
Virtual Container Host (VCH) to use vSphere Integrated Containers Engine (VICE).

## VCH Static IP Address

A common use case is to give the VCH a static IP address. There are several networks used by the VCH
detailed in [Networks Used by vSphere Integrated Containers
Engine](https://vmware.github.io/vic-product/assets/files/html/0.8/vic_installation/networks.html).
For this we will use a basic configuration where all of the networks share the same port group.

The VCH is created with the following command to specify the static IP for the Public Network. Since the other
VCH networks don't have a port group specified, they default to the same value as the Public Network.

```
⇒  vic-machine-linux create --name oceanlab --target root:password@10.17.109.132 --tls-cname 10.17.109.218 \
--thumbprint DC:5F:3C:3B:57:37:25:A0:84:C8:4E:31:48:00:C0:14:62:D9:95:E2 --compute-resource ib-aus-office-132.eng.vmware.com \
--public-network docker-network \
--public-network-ip 10.17.109.218/24 \
--public-network-gateway 10.17.109.253 \
--bridge-network "VM Network"
```

The end of the `vic-machine create` output shows that the static IP provided as the
`--public-network-ip` was resolved to a hostname and tells us how to issue Docker commands to the VCH:

```
INFO[2017-01-04T13:14:04-08:00] Connect to docker:
INFO[2017-01-04T13:14:04-08:00] docker -H waylon.eng.vmware.com:2376 --tlsverify --tlscacert="oceanlab/ca.pem" --tlscert="oceanlab/cert.pem" --tlskey="oceanlab/key.pem" info
INFO[2017-01-04T13:14:04-08:00] Installer completed successfully
```

We can verify that Docker commands to the specified IP work as expected:

```
⇒  docker -H waylon.eng.vmware.com:2376 --tlsverify --tlscacert="oceanlab/ca.pem" --tlscert="oceanlab/cert.pem" --tlskey="oceanlab/key.pem" pull busybox
Using default tag: latest
Pulling from library/busybox
fdab12439263: Pull complete
a3ed95caeb02: Pull complete
Digest: sha256:7f76bfaeaa801c62e01403f05d713f155f8ab7ef59a1df1621c18783de730d62
Status: Downloaded newer image for library/busybox:latest
```

## Setting DNS servers

By default when you set a static IP for the VCH, the VCH uses Google Public DNS servers 8.8.8.8 and
8.8.4.4. To specify your own DNS servers, use the `--dns-server` option when creating the VCH.

```
⇒  bin/vic-machine-linux create --name oceanlab --target root:password@10.17.109.132 --tls-cname 10.17.109.218 \
--thumbprint DC:5F:3C:3B:57:37:25:A0:84:C8:4E:31:48:00:C0:14:62:D9:95:E2 --compute-resource ib-aus-office-132.eng.vmware.com \
--public-network docker-network \
--public-network-ip 10.17.109.218/24 \
--public-network-gateway 10.17.109.253 \
--bridge-network "VM Network" \
--dns-server 10.118.81.1 --dns-server 10.118.81.2
```

By using the VCH debugging mode we can see that the provided DNS servers are set:

```
root@oceanlab [ ~ ]# cat /etc/resolv.conf
nameserver 10.118.81.1
nameserver 10.118.81.2
options timeout:15
options attempts:5
```

## Setting Routing Destinations

In VICE version 0.8, `vic-machine` required a gateway to be specified when a static IP is configured
for client and management networks even though this option isn't needed if the specified network is
 L2 adjacent.

```
⇒  bin/vic-machine-linux create --name oceanlab --target root:password@10.17.109.132 \
--thumbprint DC:5F:3C:3B:57:37:25:A0:84:C8:4E:31:48:00:C0:14:62:D9:95:E2 --compute-resource ib-aus-office-132.eng.vmware.com \
--public-network docker-network \
--public-network-ip 10.17.109.218/24 \
--public-network-gateway 10.17.109.253 \
--bridge-network "VM Network" \
--dns-server 10.118.81.1 --dns-server 10.118.81.2 \
--client-network client-network \
--client-network-ip 10.17.109.217/24

INFO[2017-01-05T12:20:29-08:00] ### Installing VCH ####
WARN[2017-01-05T12:20:29-08:00] Using administrative user for VCH operation - use --ops-user to improve security (see -x for advanced help)
ERRO[2017-01-05T12:20:29-08:00] --------------------
ERRO[2017-01-05T12:20:29-08:00] vic-machine-linux create failed: client network IP and gateway must both be specified
```

A fix will be included in our next release, but until then users can apply the workaround shown below.
The workaround is to enter a fake routing destination for the client/management network.
Note that the fake destination must have a gateway on the same subnet as the client/management
network static IP that is set.

```
⇒  bin/vic-machine-linux create --name oceanlab --target root:password@10.17.109.132 \
--thumbprint DC:5F:3C:3B:57:37:25:A0:84:C8:4E:31:48:00:C0:14:62:D9:95:E2 --compute-resource ib-aus-office-132.eng.vmware.com \
--public-network docker-network \
--public-network-ip 10.17.109.218/24 \
--public-network-gateway 10.17.109.253 \
--bridge-network "VM Network" \
--dns-server 10.118.81.1 --dns-server 10.118.81.2 \
--client-network client-network \
--client-network-ip 10.17.109.217/24 \
--client-network-gateway 1.1.1.1/32:10.17.109.253

INFO[2017-01-05T13:10:29-08:00] ### Installing VCH ####
...
INFO[2017-01-05T13:10:32-08:00] Validating supplied configuration
INFO[2017-01-05T13:10:33-08:00] Using default datastore: datastore1
WARN[2017-01-05T13:10:33-08:00] Unsupported static IP configuration: Same subnet "10.17.109.0/24" is assigned to multiple port groups "client-network" and "docker-network"
INFO[2017-01-05T13:10:33-08:00] Configuring static IP for additional networks using port group "client-network"
INFO[2017-01-05T13:10:33-08:00] Configuring static IP for additional networks using port group "docker-network"
...
INFO[2017-01-05T13:10:39-08:00] Creating appliance on target
INFO[2017-01-05T13:10:39-08:00] Network role "management" is sharing NIC with "client"
INFO[2017-01-05T13:10:41-08:00] Uploading images for container
INFO[2017-01-05T13:10:41-08:00]   "/home/chin/go/src/github.com/vmware/vic/bin/bootstrap.iso"
INFO[2017-01-05T13:10:41-08:00]   "/home/chin/go/src/github.com/vmware/vic/bin/appliance.iso"
INFO[2017-01-05T13:10:51-08:00] Waiting for IP information
INFO[2017-01-05T13:11:02-08:00] Waiting for major appliance components to launch
INFO[2017-01-05T13:11:03-08:00] Checking VCH connectivity with vSphere target
INFO[2017-01-05T13:11:05-08:00] vSphere API Test: https://10.17.109.132 vSphere API target responds as expected
INFO[2017-01-05T13:11:12-08:00] Initialization of appliance successful
INFO[2017-01-05T13:11:12-08:00]
INFO[2017-01-05T13:11:12-08:00] VCH Admin Portal:
INFO[2017-01-05T13:11:12-08:00] https://snowball.eng.vmware.com:2378
INFO[2017-01-05T13:11:12-08:00]
INFO[2017-01-05T13:11:12-08:00] Published ports can be reached at:
INFO[2017-01-05T13:11:12-08:00] 10.17.109.218
INFO[2017-01-05T13:11:12-08:00]
INFO[2017-01-05T13:11:12-08:00] Docker environment variables:
INFO[2017-01-05T13:11:12-08:00] DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=/home/chin/go/src/github.com/vmware/vic/oceanlab
DOCKER_HOST=snowball.eng.vmware.com:2376
INFO[2017-01-05T13:11:12-08:00]
INFO[2017-01-05T13:11:12-08:00] Environment saved in oceanlab/oceanlab.env
INFO[2017-01-05T13:11:12-08:00]
INFO[2017-01-05T13:11:12-08:00] Connect to docker:
INFO[2017-01-05T13:11:12-08:00] docker -H snowball.eng.vmware.com:2376 --tlsverify --tlscacert="oceanlab/ca.pem" --tlscert="oceanlab/cert.pem" --tlskey="oceanlab/key.pem" info
INFO[2017-01-05T13:11:12-08:00] Installer completed successfully
```

Using the VCH debugging mode we can see the routing table:

```
root@oceanlab [ ~ ]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.17.109.253   0.0.0.0         UG    0      0        0 public
1.1.1.1         10.17.109.253   255.255.255.255 UGH   0      0        0 client
10.17.109.0     0.0.0.0         255.255.255.0   U     0      0        0 client
10.17.109.0     0.0.0.0         255.255.255.0   U     0      0        0 public
172.16.0.0      0.0.0.0         255.255.0.0     U     0      0        0 bridge
```

For more information, see the [official vSphere Integrated Containers product page](https://www.vmware.com/products/vsphere/integrated-containers.html). For more information
on how VIC works, see the [documentation](https://vmware.github.io/vic-product/).

[Download vSphere Integrated Containers](https://www.vmware.com/go/vsphereintegratedcontainers) Today!
