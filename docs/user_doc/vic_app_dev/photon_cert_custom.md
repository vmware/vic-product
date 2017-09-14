## Add the Registry Certificate to a Custom Image ##

This section will take you through the process of building a custom `dch-photon` image, pushing it to the vSphere Integrated Containers Registry and verifying that it worked by deploying it to a Virtual Container Host.

For simplicity, this example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch).

**Prerequisites**

- Ensure that you have a known user ID that has at least the Developer role in the `default-project` in vSphere Integrated Containers Management Portal.
- You have an instance of Docker Engine running on your local sytem.
- You installed the CA certificate for vSphere Integrated Containers Registry in your local Docker client. For information about how to install the registry certificate in a Docker client, see [Install the  vSphere Integrated Containers Registry Certificate](configure_docker_client.md#registry).


**Procedure**

4. Log in to vSphere Integrated Containers Registry from your local Docker client.

    <pre>docker login <i>registry_address</i></pre> 

5. Pull the `dch-photon` image into the image cache in your local Docker client.

    <pre>docker pull <i>registry_address</i>/default-project/dch-photon:1.13</pre> 

6. Make a new folder and copy the vSphere Integrated Containers Registry certificate into it.

7. In the new folder, create a Dockerfile with the following format:

    <pre>FROM <i>registry_address</i>/default-project/dch-photon:1.13
    
    COPY ca.crt /etc/docker/certs.d/<i>registry_address</i>/ca.crt</pre>

8. In the same folder, build the Dockerfile as a new image and give it a meaningful new tag.

    <pre>docker build -t <i>registry_address</i>/default-project/dch-photon:1.13-cert .</pre> 

9. Push the new image into vSphere Integrated Containers Registry.

    <pre>docker push <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre> 

10. (Optional) Log in to vSphere Integrated Containers Registry from the VCH.

    If you use the same Docker client as in the preceding steps it is already authenticated with the registry. In this case, you do not need to log in again when you run commands against the VCH. If you use a different Docker client to run commands against the VCH, or you logged out, you must log in to the registry.

    <pre>docker -H <i>vch_address</i>:2376 --tls login <i>registry_address</i></pre> 

11. Pull the image from vSphere Integrated Containers Registry into the VCH and run it. 

    This example runs `dch-photon` behind a port mapping, but you can also use a container network. 

    <pre>docker -H <i>vch_address</i>:2376 --tls run --name build-slave -d -p 12375:2375 <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre> 

**Result**

- You have a custom `dch-photon` image in your vSphere Integrated Containers Registry that contains the correct certificate so that it can build, pull, and push images to and from that registry.
- You deployed a `dch-photon` container from that image, that is running in your VCH. 