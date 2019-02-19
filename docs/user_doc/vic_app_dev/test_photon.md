## Build, Push, and Pull an Image with `dch-photon`  ##

After you have loaded the vSphere Integrated Containers Registry certificate into a `dch-photon` container VM, you can test the `dch-photon` Docker host by building an image and pushing it to vSphere Integrated Containers Registry. Then, you can pull the image into a virtual container host (VCH) to deploy it. 

## Prerequisites

- You performed one of the procedures in either [Add the Registry Certificate to a Custom Image](photon_cert_custom.md) or [Manually Add the Registry Certificate to a `dch-photon` VM](photon_cert_manual.md) to create an instance of the `dch-photon` Docker Engine, named `build-slave`. 
  - The `build-slave` container VM includes the CA certificate of your vSphere Integrated Containers Registry instance. 
  - The `build-slave` container VM is exposed on port 12375 of the VCH.
- For simplicity, this example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.
- This procedure assumes that the VCH uses the same network for the client and public networks. If a VCH is deployed using separate client and public networks, the VCH endpoint is exposed on the client network. When you deploy a `dch-photon` Docker Engine on the VCH, it is exposed on the public network and the commands in the procedure fail.

vSphere Integrated Containers 1.5.x supports `dch-photon` version 17.06.

## Procedure

1. Run `docker info` to test that the Docker host running in the `dch-photon` container VM has started correctly. 

    By specifying port 12375 you direct the Docker client to the `dch-photon` Docker Engine that is running in the VCH, rather than to the VCH itself.

    <pre>docker -H <i>vch_address</i>:12375 info</pre> 

2. Test that you can authenticate with the registry from the `dch-photon` container VM.

    You should not need to log in if your client is already authenticated with the registry, but the `login` command is included here for clarity. You specify port 12375 to run the `login` command on the `dch-photon` Docker Engine, rather than on the VCH.

    <pre>docker -H <i>vch_address</i>:12375 login <i>registry_address</i></pre>

4. Test that you can pull images from the registry into the `dch-photon` container VM. 

    Specify port 12375 to run the `pull` command on the `dch-photon` Docker Engine.

    <pre>docker -H <i>vch_address</i>:12375 pull <i>registry_address</i>/default-project/dch-photon:17.06</pre>

5. Remove the test image from the `dch-photon` Docker Engine. 

    Specify port 12375 to run the `rmi` command on the `dch-photon` Docker Engine.
    <pre>docker -H vch_address:12375 rmi <i>registry_address</i>/default-project/dch-photon:17.06</pre>
    
3. Create a simple `Dockerfile` and save it in the current directory.

    Copy the following text into `Dockerfile`:

    <pre>FROM debian:latest

   RUN apt-get update -y && apt-get install -y fortune-mod fortunes

   ENTRYPOINT ["/usr/games/fortune", "-s"]</pre>

4. Build an image named `test-container` from the `Dockerfile`, and tag it with the path to a project in vSphere Integrated Containers Registry. 

    Specify port 12375 to run the `build` command on the `dch-photon` Docker Engine.

    <pre>docker -H <i>vch_address</i>:12375 build -t <i>registry_address</i>/default-project/test-container .</pre>

5. Push the image from the `dch-photon` Docker host to the registry. 

    Specify port 12375 to run the `push` command on the `dch-photon` Docker Engine.

    <pre>docker -H <i>vch_address</i>:12375 push <i>registry_address</i>/default-project/test-container</pre>

6. Pull the image from the registry into the VCH. 

    Specify port 2376 to run the `pull` command on the VCH.

    <pre>docker -H <i>vch_address</i>:2376 --tls pull <i>registry_address</i>/default-project/test-container</pre>

7. Instantiate a container from the `test-container` image on the VCH. 

    Specify port 2376 to run the test container on the VCH.

    <pre>docker -H <i>vch_address</i>:2376 --tls run --name test-container <i>registry_address</i>/default-project/test-container</pre>

8. List the containers that are running and stopped in the VCH.

    Specify port 2376 to run the `ps -a` command on the VCH.

    <pre>docker -H <i>vch_address</i>:2376 --tls ps -a</pre>

9. (Optional) Log in to vSphere Integrated Containers Management Portal.

    You should see the `test-container` image in the list of repositories for `default-project` and the `test-container` container VM in the list of containers.
    
## Result

You built a `test-container` image in a `dch-photon` Docker Engine and pushed it from the `dch-photon` instance to vSphere Integrated Containers Registry. You pulled the `test-container` image from the registry into a VCH and ran it. The resulting `test-container` container VM appears in the list of containers that have run in the VCH. 

**NOTE**: Each `dch-photon` Docker Engine that you run creates an anonymous volume in the `default` volume store. This anonymous volume is not deleted when you delete a `dch-photon` container VM. When you delete `dch-photon` container VMs, you must manually remove the anonymous volume from the volume store.
