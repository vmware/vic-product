## Manually Add the Registry Certificate to a `dch-photon` VM ##

If you wish to manually add the certificate to an existing `dch-photon` container VM, this can be done using the `docker cp` support in VIC 1.2.


For simplicity, this example uses a VCH that was deployed with the `--no-tlsverify` option. If your VCH implements TLS verification of clients, you must import the VCH certificates into your Docker client and adapt the Docker commands accordingly. For information about how to connect a Docker client to a VCH that uses full TLS authentication, see [Connecting to the VCH](configure_docker_client.md#connectvch) in Configure the Docker Client for Use with vSphere Integrated Containers.

**Procedure**

1. If a `dch-photon` container VM doesn't already exist, create one in a Virtual container host using a command similar to the one below. If one does exist, stop it using `docker stop`. 

    The container should be stopped because the Docker engine needs to be restarted in order for it to recognize the new certificate. Note that the VCH needs to be able to authenticate with the vSphere Integrated Containers Registry. See above for details. 
    
    Note also that the Docker container host can itself be configured to use TLS authentication, but has not in this case for simplicity.

    <pre>docker -H <i>vch_address</i>:2376 --tls create --name build-slave -p 12375:2375 <i>registry_address</i>/default-project/dch-photon:1.13-cert</pre>
    
2. Copy the certificate into the container. The simplest way to do this is to create the directory structure locally before the copy.

    <pre>mkdir -p certs.d/<i>registry_address</i>
   cp ca.crt certs.d/<i>registry_address</i>
   docker -H <i>vch_address</i>:2376  --tls cp certs.d build-slave:/etc/docker</pre>
    
3. Restart the Docker container host

    <pre>docker -H <i>vch_address</i>:2376 --tls start build-slave</pre>
    
**Result**

You should now have a running Docker container host that's configured to push and pull from vSphere Integrated Containers Registry
    
