# Configure the Docker Client for Use with vSphere Integrated Containers #

If your container development environment uses vSphere Integrated Containers, you must run Docker commands with the appropriate options, and configure your Docker client accordingly. 

- [Connecting to the VCH](#connectvch)
- [Using Docker Environment Variables](#variables)
- [Using vSphere Integrated Containers Registry](#registry)

## Connecting to the VCH {#connectvch}

How you connect to your virtual container host (VCH) depends on the security options with which the vSphere administrator deployed the VCH. 

- If the VCH implements any level of TLS authentication, you connect to the VCH at *vch_address*:2376 when you run Docker commands.
- If the VCH implements mutual authentication between the Docker client and the VCH by using both client and server certificates, you must provide a client certificate to the Docker client so that the VCH can verify the client's identity. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. You must obtain a copy of the client certificate that was either used or generated when the vSphere administrator deployed the VCH. You can provide the client certificate to the Docker client in either of the following ways:
  - By using the `--tlsverify`, `--tlscert`, and `--tlskey` options when you run Docker commands. You must also add `--tlscacert` if the server certificate is signed by a custom Certificate Authority (CA). For example:<pre>docker -H <i>vch_address</i>:2376 
  --tlsverify 
  --tlscert=<i>path_to_client_cert</i>/cert.pem 
  --tlskey=<i>path_to_client_key</i>/key.pem 
  --tlscacert=<i>path</i>/ca.pem 
  info</pre>
  - By setting Docker environment variables:
  <pre>DOCKER_CERT_PATH=<i>client_certificate_path</i>/cert.pem
  DOCKER_TLS_VERIFY=1</pre>
- If the VCH uses server certificates but does not authenticate the Docker client, no client certificate is required and any client can connect to the VCH. This configuration is commonly referred to as `no-tlsverify` in documentation about containers and Docker. In this configuration, the VCH has a server certificate and connections are encrypted, requiring you to run Docker commands with the `--tls` option. For example:<pre>docker -H <i>vch_address</i>:2376 --tls info</pre>In this case, do not set the `DOCKER_TLS_VERIFY` environment variable. Setting `DOCKER_TLS_VERIFY` to 0 or to `false` has no effect.
- If TLS is completely disabled on the VCH, you connect to the VCH at *vch_address*:2375. Any Docker client can connect to the VCH and communications are not encrypted. As a consequence, you do not need to specify any additional TLS options in Docker commands or set any environment variables. This configuration is not recommended in production environments. For example:<pre>docker -H <i>vch_address</i>:2375 info</pre>

## Using Docker Environment Variables {#variables}

If the vSphere administrator deploys the VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. You can use the `env` file to set environment variables in your Docker client. 

The contents of the `env` files are different depending on the level of authentication with which the VCH was deployed.

- Mutual TLS authentication with client and server certificates:
   <pre>DOCKER_TLS_VERIFY=1 
DOCKER_CERT_PATH=<i>client_certificate_path</i>\<i>vch_name</i> 
DOCKER_HOST=<i>vch_address</i>:2376</pre>
- TLS authentication with server certificates without client authentication:
   <pre>DOCKER_HOST=<i>vch_address</i>:2376</pre>
- No `env` file is generated if the VCH does not implement TLS authentication.

For information about how to obtain the `env` file, see [Obtain a VCH](obtain_vch.md).

## Using vSphere Integrated Containers Registry {#registry}

If your development environment uses vSphere Integrated Containers Registry or another private registry server that uses CA server certificates, you must pass the registry's CA certificate to the Docker client. The vSphere administrator must also have configured the VCH to access the registry. For information about how to obtain the CA certificate from vSphere Integrated Containers Registry and how to deploy a VCH so that it can access a private registry, see [Deploy a VCH for Use with vSphere Integrated Containers Registry](../vic_vsphere_admin/deploy_vch_registry.md).

**NOTE**: The level of security of the connection between the Docker client and the VCH is independent from the level of security of the connection between the Docker client and the registry. Connections between the Docker client and the registry can be secure while connections between the Docker client and the VCH are insecure, and the reverse.

### Docker on Linux ###

This example configures a Linux Docker client so that you can log into vSphere Integrated Containers Registry by using both its fully-qualified domain name (FQDN) and by using its IP address.
 
1. Copy the certificate file to the Linux machine on which you run the Docker client.
2. Switch to `sudo` user.<pre>$ sudo su</pre>
2. Create two subfolders in the Docker certificates folder, naming one with the registry's FQDN and one with the registry's IP address.<pre>$ mkdir -p /etc/docker/certs.d/<i>registry_fqdn</i></pre> <pre>$ mkdir -p /etc/docker/certs.d/<i>registry_ip</i></pre>
3. Copy the registry's CA certificate into both folders.<pre>$ cp ca.crt /etc/docker/certs.d/<i>registry_fqdn</i>/</pre> <pre>$ cp ca.crt /etc/docker/certs.d/<i>registry_ip</i>/</pre>
5. Restart the Docker daemon.<pre>$ sudo systemctl daemon-reload</pre> <pre>$ sudo systemctl restart docker</pre>
6. Open a new terminal and attempt to log in to the registry server by using both the FQDN and the IP address of the registry server.<pre>$ docker login <i>registry_fqdn</i></pre> <pre>$ docker login <i>registry_ip</pre>

### Docker on Windows ###

To pass the registry's CA certificate to a Docker client that is running on Windows 10, use the Windows Certificate Import Wizard. 

1. Copy the `ca.crt` file to the Windows 10 machine on which you run the Docker client.
2. Right-click the `ca.crt` file and select **Install Certificate**.
3. Follow the prompts of the wizard to install the certificate.
4. Restart the Docker daemon: 
   - Click the up arrow in the task bar to show running tasks.
   - Right-click the Docker icon and select **Settings**.
   - Select **Reset** and click **Restart Docker**.
5. Open a new terminal and attempt to log in to the registry server.<pre>docker login <i>vch_address</i></pre>