## Add the Registry Certificate to a Custom `dch-photon` Image ##

The recommended method of passing the vSphere Integrated Containers Registry CA certificate to `dch-photon` is to create a custom `dch-photon` image that includes the certificate. You can then push the image to the vSphere Integrated Containers Registry and verify that it works by deploying it to a virtual container host (VCH).

By creating a custom image, you can deploy multiple instances of `dch-photon` that have the correct registry certificate, without having to manually copy the certificate into each `dch-photon` container VM.

**Prerequisites**

- You have a known user account that has at least the Developer role in the `default-project` in vSphere Integrated Containers Management Portal.
- You have an instance of Docker Engine running on your local sytem.
- You installed the CA certificate for vSphere Integrated Containers Registry in your local Docker client. For information about how to install the registry certificate in a Docker client, see [Install the  vSphere Integrated Containers Registry Certificate](configure_docker_client.md#registry).
- You have access to a VCH that the vSphere administrator configured so that it can connect to the registry to pull the `dch-photon` image. The VCH must also have a volume store named `default`. For information about how deploy a VCH that is suitable for use with `dch-photon`, see the [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](../vic_vsphere_admin/deploy_vch_dchphoton.md) in *vSphere Integrated Containers for vSphere Administrators*. 
- For simplicity, this example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch).


**Procedure**

1. Log in to vSphere Integrated Containers Registry from your local Docker client.

    <pre>docker login <i>registry_address</i></pre> 

5. Pull the `dch-photon` image into the image cache in your local Docker client.

    vSphere Integrated Containers 1.4.x supports `dch-photon` version 1.13.

    <pre>docker pull <i>registry_address</i>/default-project/dch-photon:1.13</pre> 

6. Make a new folder and copy the vSphere Integrated Containers Registry certificate into it.

7. In the new folder, create a Dockerfile with the following format:

    <pre>
    FROM <i>registry_address</i>/default-project/dch-photon:1.13
    
    COPY ca.crt /etc/docker/certs.d/<i>registry_address</i>/ca.crt</pre>

8. In the same folder, build the Dockerfile as a new image and give it a meaningful new tag.

    <pre>docker build -t <i>registry_address</i>/default-project/dch-photon:1.13-cert .</pre> 

9. Push the new image into vSphere Integrated Containers Registry.

    <pre>docker push <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre> 

10. (Optional) Log in to vSphere Integrated Containers Registry from the VCH.

    If you use the same Docker client as in the preceding steps it is already authenticated with the registry. In this case, you do not need to log in again when you run commands against the VCH. If you use a different Docker client to run commands against the VCH, or you logged out, you must log in to the registry.

    <pre>docker -H <i>vch_address</i>:2376 --tls login <i>registry_address</i></pre> 

11. Pull the image from vSphere Integrated Containers Registry into the VCH and run it with the name `build-slave`. 

    This example runs `dch-photon` behind a port mapping, but you can also use a container network. 

    <pre>docker -H <i>vch_address</i>:2376 --tls run --name build-slave -d -p 12375:2375 <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre> 

**Result**

- You have a custom `dch-photon` image in your vSphere Integrated Containers Registry that contains the correct certificate so that it can build, pull, and push images to and from that registry.
- You deployed a `dch-photon` container VM from that image, that is running in your VCH. 

**What to Do Next**

To test the  `dch-photon` Docker host, see [Build, Push, and Pull an Image with `dch-photon`](test_photon.md).