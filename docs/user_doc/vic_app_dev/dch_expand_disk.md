# Expand the Root Disk on a `dch-photon` Docker Engine 

Depending on how many images you are planning to build in a `dch-photon` Docker Engine instance, you might need a larger root disk than the default of 2GB.

To create a larger root disk, use the `docker volume create` command to create a disk of the desired size and then mount it to the `dch-photon`  container VM by using the `-v` option.

**Prerequisites**

- You have access to a virtual container host (VCH) that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image. The VCH must also have a volume store named `default`. For information about how deploy a VCH that is suitable for use with `dch-photon`, see the [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *vSphere Integrated Containers for vSphere Administrators*. 
- You have an instance of Docker Engine running on your local sytem.
- For simplicity, this example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch).

**Procedure**

1. Log in to vSphere Integrated Containers Registry from your VCH.<pre>docker -H <i>vch_address</i>:2376 --tls login <i>registry_address</i></pre> 
5. Pull the `dch-photon` image into the image cache in your local Docker client.<pre>docker  -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/dch-photon:1.13</pre> 
1. Create a volume of the desired size in your VCH. <pre>docker -H <i>vch_address</i>:2376 --tls volume create --opt Capacity=30GB --name mydchdisk</pre>
3. Run the `dch-photon` container VM in the VCH, behind a port mapping. <pre>docker -H <i>vch_address</i>:2376 --tls run --name DCH -d -v mydchdisk:/var/lib/docker -p 12375:2376 <i>registry_address</i>/default-project/dch-photon:1.13</pre>
4. Run `docker info` on the newly deployed docker host. <pre>docker -H <i>vch_address</i>:12375 info</pre>