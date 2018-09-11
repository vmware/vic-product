## Build, Push, and Pull an Image with `dch-photon`  ##

After you have loaded the vSphere Integrated Containers Registry certificate into a `dch-photon` container VM, test the `dch-photon` Docker host by building an image and pushing it to vSphere Integrated Containers Registry. Then, pull the image into a VCH to deploy it. 

**Prerequisites**

- You performed one of the procedures in either [Add the Registry Certificate to a Custom Image](photon_cert_custom.md) or [Manually Add the Registry Certificate to a `dch-photon` VM](photon_cert_manual.md) to create an instance of the `dch-photon` container VM that includes the CA certificate of your vSphere Integrated Containers Registry instance. 
- For simplicity, this example uses a virtual container host (VCH) that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.
- vSphere Integrated Containers 1.4.x supports `dch-photon` version 1.13.


**Procedure**

1. Run `docker info` to test that the Docker host running in the `dch-photon` container VM has started correctly. 

    By specifying port 12375 you direct the Docker client to the Docker host that is running in the VCH.

    <pre>docker -H <i>vch_address</i>:12375 info</pre> 

2. Test that you can authenticate with the registry.

    You should not need to log in if your client is already authenticated with the registry, but the `login` command is included here for clarity.

    <pre>docker -H <i>vch_address</i>:12375 login <i>registry_address</i></pre>

4. Test that you can pull images from the registry. 

    <pre>docker -H <i>vch_address</i>:12375 pull <i>registry_address</i>/default-project/dch-photon:1.13</pre>

5. Remove the test image that you just pulled. 
    <pre>docker rmi <i>registry_address</i>/default-project/dch-photon:1.13</pre>
    
3. Create a simple `Dockerfile` and save it in the current directory.

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

**NOTE**: Each `dch-photon` container VM that you run creates an anonymous volume in the `default` volume store. This anonymous volume is not deleted when you delete a `dch-photon` container VM. When you delete `dch-photon` container VMs, you must manually remove the anonymous volume from the volume store.
