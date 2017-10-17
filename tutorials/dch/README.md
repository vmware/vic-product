# How to deploy a Docker Container Host (DCH)

You can use the DCH docker image to deploy a native container host inside a virtual container host (VCH). 
DCH is a pre built image for application build and development purposes.

Depending on how many images you are planning to build you might need a different size root disk.
Use the "docker volume create" command to create a disk of the desired size and then mount it to dch using the "-v" option.

## Tutorial

Point your docker client to the VCH

```
export DOCKER_HOST=<VCH_IP:port>

e.g export DOCKER_HOST=10.158.204.227:2375
```

Create a volume of the desired size

```
docker volume create --opt Capacity=30GB --name mydchdisk
```

Start the DCH

```
docker run --name DCH -d -v mydchdisk:/var/lib/docker -p 12375:2375 vmware/dch-photon
```

Connect to the newly deployed docker host:

```
docker -H <VCH_IP>:12375 info
```

For more information see: [https://github.com/vmware/vic-product/tree/master/dinv](https://github.com/vmware/vic-product/tree/master/dinv).
