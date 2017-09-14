## Build, Push, and Pull an Image with `dch-photon`  ##

Now that you have a Docker container host configured and running, it's time to test the it works as expected.

For simplicity, this example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.


**Procedure**

1. Test that your Docker container host has started correctly, by running `docker info`. 

    Note the new port 12375 will direct the Docker client to the Docker container host running in the Virtual container host.

    <pre>docker -H <i>vch_address</i>:12375 info</pre> 

2. Test that you can authenticate and pull from the registry. You shouldn't need to log in again if your client is already authenticated, but the login command is included here for clarity.

    <pre>docker -H <i>vch_address</i>:12375 login <i>registry_address</i>
   docker -H <i>vch_address</i>:12375 pull <i>registry_address</i>/default-project/dch-photon:1.13
   docker rmi <i>registry_address</i>/default-project/dch-photon:1.13</pre>
    
3. If the above test was successful, you should now be able to build a new image and push it to the registry. Create a simple `Dockerfile` and save it in the current directory.

    <pre>FROM debian:latest

   RUN apt-get update -y && apt-get install -y fortune-mod fortunes

   ENTRYPOINT ["/usr/games/fortune", "-s"]</pre>

4. Build an image from the `Dockerfile` in the `dch-photon` Docker host, and tag it with the path to a project in vSphere Integrated Containers Registry. 

    <pre>docker -H <i>vch_address</i>:12375 build -t <i>registry_address</i>/default-project/test-container .</pre>

5. Push the image from the `dch-photon` Docker host to the registry. 

    <pre>docker -H <i>vch_address</i>:12375 push <i>registry_address</i>/default-project/test-container</pre>

6. Pull the image from the registry into the VCH. 

    <pre>docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/test-container</pre>

7. Run a container from this image on the VCH. 

    <pre>docker -H <i>vch_address</i>:2376 --tls run <i>registry_address</i>/default-project/test-container</pre>

8. List the containers that are running and stopped in the VCH. 

    <pre>docker -H <i>vch_address</i>:2376 --tls ps -a</pre>

**Result**

The container that you ran from an image that you built and pushed to vSphere Integrated Containers Registry in `dch-photon` appears in the list of containers that have been run in this VCH.
