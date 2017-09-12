# Using `dch-photon` to Build and Push Images

vSphere Integrated Containers Engine is designed as an enterprise container runtime to be used as a deployment endpoint. As such, it doesn't have its own native `docker build` or `docker push` capabilities. The job of building and pushing container images is typically part of a CI pipeline which does this using standard Docker Engine instances. vSphere Integrated Containers Engine can now deploy these Docker Engine instances for you and a version of such an image is included in the hosted vSphere Integrated Containers Registry.

- You use standard Docker Engine to build, tag, and push a container image to a registry.
- You pull the image from the registry to a vSphere Integrated Containers virtual container host (VCH) to deploy it.

This release of vSphere Integrated Containers includes an image repository named `dch-photon`, that is pre-loaded in the `default-project` in vSphere Integrated Containers Registry. The `dch-photon` image allows you to deploy a container VM running Docker Engine hosted in Photon OS. You can then deploy any number of these Docker container hosts to perform `docker build` and `docker push` operations as part of your CI infrastructure. 

In order for the `dch-photon` image to be able to authenticate with vSphere Integrated Containers Registry, it needs to have access to the certificate provided by the registry. There are two ways to achieve this. You can either manually copy it in to a `dch-photon` container running in a VCH using `docker cp` or you can build your own custom image with the certificate embedded in it. This latter method is preferable since the modification only needs to be performed once.

**Prerequisites**

- Configure your local Docker client to use the vSphere Integrated Containers Registry certificate. For information about how to obtain the registry certificate and pass it to the Docker client, see [Using vSphere Integrated Containers Registry](configure_docker_client.md#registry) in Configure the Docker Client for Use with vSphere Integrated Containers.
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image, and so that it has a default volume store. For information about how deploy a VCH for use with `dch-photon`, see the [Deploy a Virtual Container Host for Use with `dch-photon`](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *Install, Deploy, and Maintain the vSphere Integrated Containers Infrastructure*.
- This topic provides an example of using `dch-photon` to push an image to vSphere Integrated Containers Registry and then pull it into a VCH. For simplicity, the example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.  

## Adding the Registry Certificate to a Custom Image ##

This section will take you through the process of building a custom `dch-photon` image, pushing it to the vSphere Integrated Containers Registry and verifying that it worked by deploying it to a Virtual Container Host.

**Procedure**

1. Ensure that you have a known userid added to the `default-project` in VIC registry.

2. Download the registry certificate from the Mangagement Portal by going to Administration -> Configuration -> Registry Root Certificate.

3. Install the registry certificate in a local instance of Docker Engine. See prerequisites above.

    <pre>mkdir -p /etc/docker/certs.d/<i>registry_address</i>
   cp ca.crt /etc/docker/certs.d/<i>registry_address</i>
   systemctl daemon-reload
   systemctl restart docker</pre>

4. Log in to vSphere Integrated Containers Registry

    <pre>docker login <i>registry_address</i></pre> 

5. Pull the `dch-photon` image to your local image cache

    <pre>docker pull <i>registry_address</i>/default-project/dch-photon:1.13</pre> 

6. Make a new directory and copy the downloaded certificate into it

7. In the new directory, create a Dockerfile with the following format:

    <pre>FROM <i>registry_address</i>/default-project/dch-photon:1.13
    
   COPY ca.crt /etc/docker/certs.d/<i>registry_address</i>/ca.crt</pre>

8. From within the directory, build the Dockerfile as a new image and give it a meaningful new tag

    <pre>docker build -t <i>registry_address</i>/default-project/dch-photon:1.13-cert .</pre> 

9. Push the new image back to the vSphere Integrated Containers Registry

    <pre>docker push <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre> 

10. If you're using a Docker client that's already authenticated with the registry, there should be need to log in again when running commands against the VCH. If you're using a different Docker client or you've logged out, you should now log into the registry.

    <pre>docker -H <i>vch_address</i>:2376 --tls login <i>registry_address</i></pre> 

11. Pull and run the image in the VCH. 

    This example uses port mapping, but you can also use a container network. Note that the Docker container host can itself be configured to use TLS authentication, but has not in this case for simplicity.

    <pre>docker -H <i>vch_address</i>:2376 --tls run --name build-slave -d -p 12375:2375 <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre> 

**Result**

You should now have a custom `dch-photon` image in your vSphere Integrated Containers Registry which contains the correct certificate to be able to build, pull and push images to that registry.

See below for how to test the running Docker container host

## Manually Adding the Registry Certificate to a `dch-photon` VM ##

If you wish to manually add the certificate to an existing `dch-photon` container VM, this can be done using the `docker cp` support in VIC 1.2

**Procedure**

1. If a `dch-photon` container VM doesn't already exist, create one in a Virtual container host using a command similar to the one below. If one does exist, stop it using `docker stop`. 

    The container should be stopped because the Docker engine needs to be restarted in order for it to recognize the new certificate. Note that the VCH needs to be able to authenticate with the vSphere Integrated Containers Registry. See above for details. 
    
    Note also that the Docker container host can itself be configured to use TLS authentication, but has not in this case for simplicity.

    <pre>docker -H <i>vch_address</i>:2375 create --name build-slave -p 12375:2375 <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre>
    
2. Copy the certificate into the container. The simplest way to do this is to create the directory structure locally before the copy.

    <pre>mkdir -p certs.d/<i>registry_address</i>
   cp ca.crt certs.d/<i>registry_address</i>
   docker -H <i>vch_address</i>:2376  --tls cp certs.d build-slave:/etc/docker</pre>
    
3. Restart the Docker container host

    <pre>docker -H <i>vch_address</i>:2376 --tls start build-slave</pre>
    
**Result**

You should now have a running Docker container host that's configured to push and pull from vSphere Integrated Containers Registry
    
## Testing the Docker Container Host ##

Now that you have a Docker container host configured and running, it's time to test the it works as expected.

**Procedure**

1. Test that your Docker container host has started correctly, by running `docker info`. 

    Note the new port 12375 will direct the Docker client to the Docker container host running in the Virtual container host.

    <pre>docker -H <i>vch_address</i>:12375 info</pre> 

2. Test that you can authenticate and pull from the registry. You shouldn't need to log in again if your client is already authenticated, but the login command is included here for clarity.

    <pre>docker -H <i>vch_address</i>:12375 login <i>registry_address</i>
   docker -H <i>vch_address</i>:12375 pull <i>registry_address</i>/default-project/dch-photon:1.13-cert
   docker rmi <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre>
    
3. If the above test was successful, you should now be able to build a new image and push it to the registry. Create a simple `Dockerfile` and save it in the current directory.

    <pre>FROM debian:latest

   RUN apt-get update -y && apt-get install -y fortune-mod fortunes

   ENTRYPOINT ["/usr/games/fortune", "-s"]</pre>

4. Build an image from the `Dockerfile` in the `dch-photon` Docker host, and tag it with the path to a project in vSphere Integrated Containers Registry. 

    <pre>docker -H <i>vch_address</i>:12375 build -t <i>registry_address</i>/default-project/test-container .</pre>

8. If your Docker client is not already authenticated, log in to vSphere Integrated Containers Registry from the `dch-photon` Docker host. 

    <pre>docker -H <i>vch_address</i>:12375 login <i>registry_address</i></pre>

6. Push the image from the `dch-photon` Docker host to the registry. 

    <pre>docker -H <i>vch_address</i>:12375 push <i>registry_address</i>/default-project/test-container</pre>

6. Pull the image from the registry into the VCH. 

    <pre> docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/test-container</pre>

6. Run a container from this image on the VCH. 

    <pre> docker -H <i>vch_address</i>:2376 --tls run <i>registry_address</i>/default-project/test-container</pre>

6. List the containers that are running in the VCH. 

    <pre>docker -H <i>vch_address</i>:2376 --tls ps</pre>

**Result**

The container that you ran from an image that you built and pushed to vSphere Integrated Containers Registry in `dch-photon` appears in the list of containers that are running in this VCH.
