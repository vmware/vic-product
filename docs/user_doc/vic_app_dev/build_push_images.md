# Using `dch-photon` to Build and Push Images

The current version of vSphere Integrated Containers Engine does not support `docker build` or `docker push`. As a consequence, the workflow for developing container images and pushing them to a registry server is slightly different to the workflow in a regular Docker environment.

- You use standard Docker to build, tag, and push a container image to a registry.
- You pull the image from the registry to a vSphere Integrated Containers virtual container host (VCH) to use it.

This release of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image allows you to deploy a standard Docker container host that runs in a Photon OS container. You can then use this Docker container host to perform `docker build` or `docker push` operations.

This topic provides an example of using `dch-photon` to push an image to vSphere Integrated Containers Registry and then pull it into a VCH. For simplicity, the example uses the `busybox` container image instead of building a new image. 

**Prerequisites**

- Configure your Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to pass the registry certificate to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry) in Configure the Docker Client for Use with vSphere Integrated Containers.
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image, and so that it has a default volume store. For information about how deploy a VCH for use with `dch-photon`, see the [Deploy a Virtual Container Host for Use with `dch-photon`](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*
- In the example, connections to the registry are secured by TLS, but for simplicity the connection between the Docker client and the VCH is not. As a consequence, the Docker commands to run in the VCH do not include any TLS options. If your VCH uses TLS authentication, adapt the Docker commands accordingly, and use port 2376 instead of 2375 when connecting to the VCH. For information about how to connect a Docker client to a VCH that uses TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.  

**Procedure**

1. Log in to vSphere Integrated Containers Registry.

    <pre>$docker login <i>registry_address</i></pre> 
2. Pull the dch-photon image from vSphere Integrated Containers Registry into your VCH.

    <pre>$ docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/dch-photon:1.13</pre>

3. Run a `dch-photon` container from the image.

    <pre>docker -H <i>vch_address</i>:2376 --tls run -d -p 12376:2376 <i>registry_address</i>/default-project/dch-photon:1.13 -tls -vic-ip <i>vch_address</i> -insecure-registry <i>registry_address</i></pre>

    This command runs the `dch-photon` container with the following options:

    - `-tls`: Enables secure communication with no verification of the remote registry. Loads certificates from `/certs` as `/certs/docker.crt` as the server certificate and `/certs/docker.key` as the key for the server certificate.
    - `-vic-ip`: Sets the IP address of the VCH for automatic certificate creation when `dch-photon` is running behind a port mapping.
    - `-insecure-registry`: Enables insecure registry communication with the vSphere Integrated Containers Registry instance at that address.

4. Run `docker ps` on the VCH to see the status of the running `dch-photon` container.

    <pre>docker -H <i>vch_address</i>:2376 --tls ps</pre>

    In the output you see details of the port mapping from port 12376 on the VCH to port 2376/tcp on the `dch-photon` container.

4. Run `docker info` on the mapped port to obtain information about the Docker host running in the `dch-photon` container.

    <pre>docker -H <i>vch_address</i>:12376 --tls info</pre>

    In the output you see that this is a regular Docker host.

5. Create a simple `Dockerfile` and save it in the current directory.

    <pre>FROM debian:latest

    RUN apt-get update -y && apt-get install -y fortune-mod fortunes

    ENTRYPOINT ["/usr/games/fortune", "-s"]</pre>

6. Build an image from the `Dockerfile` in the `dch-photon` Docker host, and tag it with the path to a project in vSphere Integrated Containers Registry. 

    <pre>docker -H <i>vch_address</i>:12376 --tls build <i>registry_address</i>/default-project/test-container .</pre>

6. Log in to vSphere Integrated Containers Registry from the `dch-photon` Docker host. 

    <pre>docker -H <i>vch_address</i>:12376 --tls login <i>registry_address</i></pre>

6. Push the image from the `dch-photon` Docker host to the registry. 

    <pre>docker -H <i>vch_address</i>:12376 --tls push <i>registry_address</i>/default-project/test-container</pre>

6. Pull the image from the registry into the VCH. 

    <pre> docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/test-container</pre>

6. Run a container from this image on the VCH. 

    <pre> docker -H <i>vch_address</i>:2376 --tls run <i>registry_address</i>/default-project/test-container</pre>

6. List the containers that are running in the VCH. 

    <pre>docker -H <i>vch_address</i>:2376 --tls ps</pre>

**Result**

The container that you ran from an image that you built and pushed to vSphere Integrated Containers Registry in `dch-photon` appears in the list of images that are running in this VCH.
