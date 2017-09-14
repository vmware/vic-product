# Advanced `dch-photon` Deployment 

You do not need to specify any options when you use `docker run` to deploy `dch-photon` container VMs for use with vSphere Integrated Containers Registry. However, you can optionally specify `dch-photon` options in the `docker run` command to implement TLS authentication between virtual container hosts (VCHs) and `dch-photon` container VMs

You can also specify `dch-photon` options to connect `dch-photon` container VMs to registries other than vSphere Integrated Containers Registry.

- [`dch-photon` Options](#options)
- [Authenticate Connections from VCHs to `dch-photon` Container VMs](#authvch)
  - [With Remote Verification](#authvch_tlsverify) 
  - [Without Remote Verification](#authvch_tls)
  - [With Automatically Generated Certificates](#authvch_auto)

## `dch-photon` Options <a id="options"></a>

You can specify the following options when you deploy `dch-photon` container VMs:

- `-insecure-registry`: Enable insecure registry communication. Set this option multiple times to create a list of registries to which `dch-photon` applies no security considerations. You cannot use this option when connecting to vSphere Integrated Containers Registry.
- `-local`: Do not bind the Docker API to external interfaces. Set this option to prevent the Docker API endpoint from binding to the external interface. Docker Engine only listens on `/var/run/docker.sock`.
- `-storage`: Sets the Docker storage driver that Docker Engine uses. By default, the storage driver is `overlay2`, which is the recommended driver when running Docker Engine as a container VM.
- `-tls`: Use TLS authentication for all connections. Implied by `-tlsverify`. This option enables secure communication with no verification of the remote end. To use custom certificates, copy them into the `/certs` folder in the `dch-photon` container. Certificates are generated automatically in `/certs` if you do not provide them. 

   -  Server certificate: `/certs/docker.crt`
   -  Key for the server certificate: `/certs/docker.key`
- `-tlsverify`: Use TLS and authentication for all connections and verify the remote end. To use custom certificates, copy them into the `/certs` folder in the `dch-photon` container. Certificates are generated automatically in `/certs` if you do not provide them. 

  - Server certificate: `/certs/docker.crt`
  - Key for the server certificate: `/certs/docker.key`
  - CA certificate: `/certs/ca.crt` 
  - CA key: `/certs/ca-key.pem` 
  - Client certificate: `/certs/docker-client.crt`
  - Client key: `/certs/docker-client.key` 
- `vic-ip`: Set the IP address of the virtual container host for  use in automatic certificate generation when running `dch-photon` containers behind a port mapping.


## Authenticate Connections from VCHs to `dch-photon` Container VMs <a id="authvch"></a>

To implement TLS authentication between VCHs and `dch-photon` container VMs, you specify the `-tls` or `-tlsverify` option when you create the container VM. You then copy the VCH certificates into the `dch-photon` container VM.

### With Remote Verification <a id="authvch_tlsverify"></a>

1. Create a `dch-photon` container without starting it.

    This example runs `dch-photon` behind a port mapping and specifies the `-tlsverify` option.<pre>docker create -p 12376:2376 --name dch-photon-tlsverify <i>registry_address</i>/default-project/dch-photon:1.13 -tlsverify</pre>

2. Copy the VCH certificates into the `dch-photon` container.<pre> docker cp <i>vch_cert_folder</i>/ca.pem dch-photon-tlsverify:/certs/ca.crt</pre><pre> docker cp <i>vch_cert_folder</i>/server-cert.pem dch-photon-tlsverify:/certs/docker.crt</pre><pre> docker cp <i>vch_cert_folder</i>/server-key.pem dch-photon-tlsverify:/certs/docker.key</pre>   
3. Start the `dch-photon` container.<pre>docker start dch-photon-tlsverify</pre>
4. Connect to the `dch-photon` container.<pre>docker -H <i>vch_adress</i>:12376 --tlsverify info</pre>

### Without Remote Verification <a id="authvch_tls"></a>

1. Create a `dch-photon` container without starting it.

    This example runs `dch-photon` behind a port mapping and specifies the `-tls` option.<pre>docker create -p 12376:2376 --name dch-photon-tls <i>registry_address</i>/default-project/dch-photon:1.13 -tls</pre>

2. Copy the VCH certificates into the `dch-photon` container.<pre> docker cp <i>vch_cert_folder</i>/server-cert.pem dch-photon-tls:/certs/docker.crt</pre><pre> docker cp <i>vch_cert_folder</i>/server-key.pem dch-photon-tls:/certs/docker.key</pre>   
3. Start the `dch-photon` container.<pre>docker start dch-photon-tls</pre>
4. Connect to the `dch-photon` container.<pre>docker -H <i>vch_adress</i>:12376 --tls info</pre>

### With Automatically Generated Certificates <a id="authvch_auto"></a>

To generate certificates automatically, specify either `-tls` or `-tlsverify`. If the `dch-photon` container runs behind a port mapping, specify the address of the VCH in the `-vic-ip` option. This address is used during certificate generation.

<pre>docker run -p 12376:2376 --name dinv-build -v mycerts:/certs vmware/dch-photon -tlsverify -vic-ip <i>vch_adress</i></pre>

You can then use `docker cp` to copy the automatically generated certificates to your local Docker client.