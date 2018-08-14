## Manually Add the Registry Certificate to a `dch-photon` Container VM ##

To manually add the vSphere Integrated Containers CA certificate to  `dch-photon`, you can create a `dch-photon` container VM, then use `docker cp` to copy the certificate into it. 

**NOTE**: This method requires you to copy the certificate to every `dch-photon` container VM that you deploy. To avoid having to copy the certificate every time, the recommended method is to create a custom `dch-photon` image. For information about creating a custom image, see [Add the Registry Certificate to a Custom Image](photon_cert_custom.html).

**Prerequisites**

- You have a known user ID that has at least the Developer role in the `default-project` in vSphere Integrated Containers Management Portal.
- You have an instance of Docker Engine running on your local sytem.
- You installed the CA certificate for vSphere Integrated Containers Registry in your local Docker client. For information about how to install the registry certificate in a Docker client, see [Install the  vSphere Integrated Containers Registry Certificate](configure_docker_client.md#registry).
- For simplicity, this example uses a virtual container host (VCH) that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.

**Procedure**

1. Create a `dch-photon` container VM named `build-slave` in a VCH, but do not start it. 

    The container should be stopped because the Docker Engine instance that it runs must restart so that it can recognize the new certificate and you have copied it to the container. If you have already deployed `dch-photon`, use `docker stop` to stop it. 

    This example runs `dch-photon` behind a port mapping.

    <pre>docker -H <i>vch_address</i>:2376 --tls create --name build-slave -p 12375:2375 <i>registry_address</i>/default-project/dch-photon:1.13</pre>
    
2. Create the required folder structure on your local machine.

    Docker Engine stores registry certificates in a folder named <code>etc/docker/certs.d/<i>registry_address</i></code>.

    <pre>mkdir -p certs.d/<i>registry_address</i></pre>

3. Copy the certificate into the new folder.<pre>cp <i>path_to_cert</i>/ca.crt certs.d/<i>registry_address</i></pre> 
4. Use `docker cp` to copy the certificate from your local system into the `dch-photon` container VM that is running in the VCH.<pre>
    docker -H <i>vch_address</i>:2376  --tls cp certs.d build-slave:/etc/docker</pre>
    
3. Restart the Docker container host to load the certificate.

    <pre>docker -H <i>vch_address</i>:2376 --tls start build-slave</pre>
    
**Result**

You have a running Docker container host that you configured to push and pull from vSphere Integrated Containers Registry.

**What to Do Next**

To test the Docker container host, see [Build, Push, and Pull an Image with `dch-photon`](test_photon.md).
    
