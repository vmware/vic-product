# Using `dch-photon` to Build and Push Images

vSphere Integrated Containers Engine is designed as an enterprise container runtime to be used as a deployment endpoint. As such, it doesn't have its own native `docker build` or `docker push` capabilities. The job of building and pushing container images is typically part of a CI pipeline which does this using standard Docker Engine instances. vSphere Integrated Containers Engine can now deploy these Docker Engine instances for you and a version of such an image is included in the hosted registry.

- You use standard Docker Engine to build, tag, and push a container image to a registry.
- You pull the image from the registry to a vSphere Integrated Containers virtual container host (VCH) to deploy it.

This release of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image allows you to deploy a container VM running Docker Engine hosted in Photon OS. You can then deploy any number of these Docker container hosts to perform `docker build` and `docker push` operations as part of your CI infrastructure. 

In order for the `dch-photon` image to be able to authenticate with vSphere Integrated Containers Registry, it needs to have access to the certificate provided by the registry. There are two ways to achieve this. You can either copy it in to a `dch-photon` container running in a VCH using `docker cp` or you can build your own custom image with the certificate embedded in it. This latter method is preferable since the modification only needs to be performed once.

**Adding the Certificate to a Custom Image**

This section will take you through the process of building a custom `dch-photon` image, pushing it to the vSphere Integrated Containers Registry and verifying that it worked.

**Procedure**

1. 



**Prerequisites**

- Configure your Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to obtain the registry certificate and pass it to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry) in Configure the Docker Client for Use with vSphere Integrated Containers.
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image, and so that it has a default volume store. For information about how deploy a VCH for use with `dch-photon`, see the [Deploy a Virtual Container Host for Use with `dch-photon`](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.
- This topic provides an example of using `dch-photon` to push an image to vSphere Integrated Containers Registry and then pull it into a VCH. For simplicity, the example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.  

**Procedure**

1. Log in to vSphere Integrated Containers Registry from the VCH.

    <pre>docker -H <i>vch_address</i>:2376 --tls login <i>registry_address</i></pre> 
2. Pull the `dch-photon` image from vSphere Integrated Containers Registry into your VCH.

    <pre>docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/dch-photon:1.13</pre>

3. Run a `dch-photon` container from the image.

    <pre>docker -H <i>vch_address</i>:2376 --tls run --name dch-photon -d -p 12376:2376 <i>registry_address</i>/default-project/dch-photon:1.13 -tlsverify</pre>

    This command uses the following Docker options to run the `dch-photon` container:

    - `-d`, to run the `dch-photon` container in the background.
    - `-p` to map port 12376 on the VCH to the Docker TLS port 2376 on the `dch-photon` container
 
    This command also configures the Docker host that runs in the `dch-photon` container with the following option:

    <!-- `-tls`: Enables secure communication with no verification of the remote registry. Loads certificates from `/certs` as `/certs/docker.crt` as the server certificate and `/certs/docker.key` as the key for the server certificate.-->
    - `-tlsverify`: Verifies the client and server certificates for the connection from the Docker host running in the `dch-photon` container to the registry.
    <!-- - `-vic-ip`: Sets the IP address of the VCH for automatic certificate creation when `dch-photon` is running behind a port mapping.-->

4. Run `docker ps` on the VCH to see the status of the running `dch-photon` container.

    <pre>docker -H <i>vch_address</i>:2376 --tls ps</pre>

    In the output you see details of the port mapping from port 12376 on the VCH to port 2376/tcp on the `dch-photon` container.

4. Run `docker info` on the mapped port 12376 to obtain information about the Docker host running in the `dch-photon` container.

    Note that this command specifies port 12376, because you are running the command in the Docker host in the `dch-photon` container.

    <pre>docker -H <i>vch_address</i>:12376 --tls info</pre>

    In the output you see that this is a regular Docker 1.13.1 host.

6. Create the folder structure for the registry certificate in the `dch-photon` container. 

    The `dch-photon` container requires the CA certificate of the registry server. Note that these commands specify port 2376, because you are running them in the VCH.

    - First create a folder named `/etc/docker/certs.d`.<pre>docker -H <i>vch_address</i>:2376 --tls exec dch-photon mkdir /etc/docker/certs.d</pre>
    - Then create a subfolder with the same name as the registry address, to contain the certificate.<pre>docker -H <i>vch_address</i>:2376 --tls exec dch-photon mkdir /etc/docker/certs.d/<i>registry_address</i></pre>

7. Copy the CA certificate of the vSphere Integrated Containers Registry into the certificates folder in the `dch-photon` container. 

    Note that this command specifies port 2376.

    <pre>docker -H <i>vch_address</i>:2376 --tls cp <i>local_cert_path</i>/ca.crt dch-photon:/etc/docker/certs.d/<i>registry_address</i>/ca.crt</pre>

7. Restart the `dch-photon` container. 

    Restarting the container allows the Docker host that is running inside it to load the certificate.

    Note that this command specifies port 2376.

    <pre>docker -H <i>vch_address</i>:2376 --tls restart dch-photon</pre>

5. Create a simple `Dockerfile` and save it in the current directory.

    <pre>FROM debian:latest

    RUN apt-get update -y && apt-get install -y fortune-mod fortunes

    ENTRYPOINT ["/usr/games/fortune", "-s"]</pre>

6. Build an image from the `Dockerfile` in the `dch-photon` Docker host, and tag it with the path to a project in vSphere Integrated Containers Registry. 

    Note that this command specifies port 12376.

    <pre>docker -H <i>vch_address</i>:12376 --tls build  -t <i>registry_address</i>/default-project/test-container .</pre>

8. Log in to vSphere Integrated Containers Registry from the `dch-photon` Docker host. 

    Note that this command specifies port 12376.

    <pre>docker -H <i>vch_address</i>:12376 --tls login <i>registry_address</i></pre>

6. Push the image from the `dch-photon` Docker host to the registry. 

    Note that this command specifies port 12376.

    <pre>docker -H <i>vch_address</i>:12376 --tls push <i>registry_address</i>/default-project/test-container</pre>

6. Pull the image from the registry into the VCH. 

    Note that this command specifies port 2376.

    <pre> docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/test-container</pre>

6. Run a container from this image on the VCH. 

    <pre> docker -H <i>vch_address</i>:2376 --tls run <i>registry_address</i>/default-project/test-container</pre>

6. List the containers that are running in the VCH. 

    <pre>docker -H <i>vch_address</i>:2376 --tls ps</pre>

**Result**

The container that you ran from an image that you built and pushed to vSphere Integrated Containers Registry in `dch-photon` appears in the list of containers that are running in this VCH.
