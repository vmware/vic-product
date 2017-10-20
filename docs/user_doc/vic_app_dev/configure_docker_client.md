# Configure the Docker Client for Use with vSphere Integrated Containers #

If your container development environment uses vSphere Integrated Containers, you must run Docker commands with the appropriate options, and configure your Docker client accordingly. 

vSphere Integrated Containers Engine 1.2 supports Docker client 1.13.0. The supported version of the Docker API is 1.25.

- [Connecting to the VCH](#connectvch)
- [Using Docker Environment Variables](#variables)
- [Install the  vSphere Integrated Containers Registry Certificate](#registry)
  - [Obtain the vSphere Integrated Containers Registry CA Certificate](#getcert)
  - [Configure the Docker Client on Linux](#certlinux)
  - [Configure the Docker Client on Windows](#certwindows)
- [Using vSphere Integrated Containers Registry with Notary](#notary)

## Connecting to the VCH <a id="connectvch"></a>

How you connect to your virtual container host (VCH) depends on the security options with which the vSphere administrator deployed the VCH. 

- If the VCH implements any level of TLS authentication, you connect to the VCH at *vch_address*:2376 when you run Docker commands.
- If the VCH implements mutual authentication between the Docker client and the VCH by using both client and server certificates, you must provide a client certificate to the Docker client so that the VCH can verify the client's identity. This configuration is commonly referred to as `tlsverify` in documentation about containers and Docker. You must obtain a copy of the client certificate that was either used or generated when the vSphere administrator deployed the VCH. You can provide the client certificate to the Docker client in either of the following ways:
  - By using the `--tlsverify`, `--tlscert`, and `--tlskey` options when you run Docker commands. You must also add `--tlscacert` if the server certificate is signed by a custom Certificate Authority (CA). For example:<pre>docker -H <i>vch_address</i>:2376 
  --tlsverify 
  --tlscert=<i>path_to_client_cert</i>/cert.pem 
  --tlskey=<i>path_to_client_key</i>/key.pem 
  --tlscacert=<i>path</i>/ca.pem 
  info</pre>
  - By setting Docker environment variables:<pre>DOCKER_CERT_PATH=<i>client_certificate_path</i>/cert.pem
  DOCKER_TLS_VERIFY=1</pre>
- If the VCH uses server certificates but does not authenticate the Docker client, no client certificate is required and any client can connect to the VCH. This configuration is commonly referred to as `no-tlsverify` in documentation about containers and Docker. In this configuration, the VCH has a server certificate and connections are encrypted, requiring you to run Docker commands with the `--tls` option. For example:<pre>docker -H <i>vch_address</i>:2376 --tls info</pre>In this case, do not set the `DOCKER_TLS_VERIFY` environment variable. Setting `DOCKER_TLS_VERIFY` to 0 or to `false` has no effect.
- If TLS is completely disabled on the VCH, you connect to the VCH at *vch_address*:2375. Any Docker client can connect to the VCH and communications are not encrypted. As a consequence, you do not need to specify any additional TLS options in Docker commands or set any environment variables. This configuration is not recommended in production environments. For example:<pre>docker -H <i>vch_address</i>:2375 info</pre>

## Using Docker Environment Variables <a id="variables"></a>

If the vSphere administrator deploys the VCHs with TLS authentication, `vic-machine create` generates a file named `vch_name.env`. The `env` file contains Docker environment variables that are specific to the VCH. You can use the `env` file to set environment variables in your Docker client. 

The contents of the `env` files are different depending on the level of authentication with which the VCH was deployed.

- Mutual TLS authentication with client and server certificates:  <pre>DOCKER_TLS_VERIFY=1 
DOCKER_CERT_PATH=<i>client_certificate_path</i>\<i>vch_name</i> 
DOCKER_HOST=<i>vch_address</i>:2376</pre>
- TLS authentication with server certificates without client authentication:<pre>DOCKER_HOST=<i>vch_address</i>:2376</pre>
- No `env` file is generated if the VCH does not implement TLS authentication.

For information about how to obtain the `env` file, see [Obtain a VCH](obtain_vch.md).

## Install the  vSphere Integrated Containers Registry Certificate <a id="registry"></a>

If your development environment uses vSphere Integrated Containers Registry or another private registry server that uses CA server certificates, you must pass the registry's CA certificate to the Docker client. The vSphere administrator must also have configured the VCH to access the registry.  

For information about how vSphere administrators deploy VCHs so that they can access a private registry, see [Deploy a VCH for Use with vSphere Integrated Containers Registry](../vic_vsphere_admin/deploy_vch_registry.md).

The level of security of the connection between the Docker client and the VCH is independent from the level of security of the connection between the Docker client and the registry. Connections between the Docker client and the registry can be secure while connections between the Docker client and the VCH are insecure, and the reverse. 

**NOTE**: VCHs cannot to connect to vSphere Integrated Containers Registry instances as insecure registries. Connections to vSphere Integrated Containers Registry always require HTTPS and a certificate.

### Obtain the vSphere Integrated Containers Registry CA Certificate <a id="getcert"></a>

To access the vSphere Integrated Containers Registry CA certificate, you must have a user account in vSphere Integrated Containers Management Portal in that has at least the Cloud administrator role. 

1. Log in to vSphere Integrated Containers Mangagement Portal at http://<i>vic_appliance_address</i> and following the **Go to the vSphere Integrated Containers Management Portal** link.
2. Go to **Administration** -> **Configuration** and click the download link for **Registry Root Certificate**.

### Configure the Docker Client on Linux <a id="certlinux"></a>

<!--
This example configures a Linux Docker client so that you can log into vSphere Integrated Containers Registry by using both its fully-qualified domain name (FQDN) and by using its IP address.
 
1. Copy the certificate file to the Linux machine on which you run the Docker client.
2. Switch to `sudo` user.<pre>$ sudo su</pre>
2. Create two subfolders in the Docker certificates folder, naming one with the registry's FQDN and one with the registry's IP address.<pre>$ mkdir -p /etc/docker/certs.d/<i>registry_fqdn</i></pre> <pre>$ mkdir -p /etc/docker/certs.d/<i>registry_ip</i></pre>
3. Copy the registry's CA certificate into both folders.<pre>$ cp ca.crt /etc/docker/certs.d/<i>registry_fqdn</i>/</pre> <pre>$ cp ca.crt /etc/docker/certs.d/<i>registry_ip</i>/</pre>
6. Open a new terminal and attempt to log in to the registry server by using both the FQDN and the IP address of the registry server.<pre>$ docker login <i>registry_fqdn</i></pre> <pre>$ docker login <i>registry_ip</pre>
7. If the login fails with a certificate error, restart the Docker daemon.<pre>$ sudo systemctl daemon-reload</pre> <pre>$ sudo systemctl restart docker</pre>
-->

This example configures a Linux Docker client so that you can log into vSphere Integrated Containers Registry by using its IP address.

**NOTE**: The current version of vSphere Integrated Containers uses the registry's IP address as the Subject Alternate Name when auto-generating certificates for vSphere Integrated Containers Registry. Consequently, when you run `docker login`, you must use the IP address of the registry rather than the FQDN. 
 
1. Copy the certificate file to the Linux machine on which you run the Docker client.
2. Switch to `sudo` user.<pre>$ sudo su</pre>
2. Create a subfolder in the Docker certificates folder, using the registry's IP address as the folder name.<pre>$ mkdir -p /etc/docker/certs.d/<i>registry_ip</i></pre>
3. Copy the registry's CA certificate into the folder.<pre>$ cp ca.crt /etc/docker/certs.d/<i>registry_ip</i>/</pre>
6. Open a new terminal and attempt to log in to the registry server, specifying the IP address of the registry server.<pre>$ docker login <i>registry_ip</i></pre>
7. If the login fails with a certificate error, restart the Docker daemon.<pre>$ sudo systemctl daemon-reload</pre> <pre>$ sudo systemctl restart docker</pre>

### Configure the Docker Client on Windows <a id="certwindows"></a>

To pass the registry's CA certificate to a Docker client that is running on Windows 10, use the Windows Certificate Import Wizard. 

1. Copy the `ca.crt` file to the Windows 10 machine on which you run the Docker client.
2. Right-click the `ca.crt` file and select **Install Certificate**.
3. Follow the prompts of the wizard to install the certificate.
4. Restart the Docker daemon: 
   - Click the up arrow in the task bar to show running tasks.
   - Right-click the Docker icon and select **Settings**.
   - Select **Reset** and click **Restart Docker**.
5. Log in to the registry server.<pre>docker login <i>registry_ip</i></pre>

## Using vSphere Integrated Containers Registry with Notary <a id="notary"></a>

vSphere Integrated Containers Registry provides a Docker Notary server that allows you to implement content trust by signing and verifying the images in the registry. For information about Docker Notary, see [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/) in the Docker documentation.

To use the Docker Notary server from vSphere Integrated Containers Registry, you must pass the registry's CA certificate to your Docker client and set up Docker Content Trust. By default, the vSphere Integrated Containers Registry Notary server runs on port 4443 on the vSphere Integrated Containers appliance.

1. If you are using a self-signed certificate, copy the CA root certificate to the Docker certificates folder.

    To pass the certificate to the Docker client, follow the procedure in [Using vSphere Integrated Containers Registry](#registry) above.
2. If you are using a self-signed certificate, copy the CA certificate to the Docker TLS service.

    <pre>$ cp ca.crt ~/.docker/tls/<i>registry_ip</i>:4443/</pre>
2. Enable Docker Content Trust by setting environment variables.<pre>export DOCKER_CONTENT_TRUST=1
export DOCKER_CONTENT_TRUST_SERVER=https://<i>registry_ip</i>:4443
</pre>
3. (Optional) Set an alias for Notary.

    By default, the local directory for storing meta files for the Notary client is different from the folder for the Docker client. Set an alias to make it easier to use the Notary client to manipulate the keys and meta files that Docker Content Trust generates. 

    <pre>alias notary="notary -s https//<i>registry_ip</i>:4443 -d ~/.docker/trust --tlscacert  /etc/docker/certs.d/<i>registry_ip</i>/ca.crt"</pre>

4. When you push an image for the first time, define and confirm passphrases for the root key and the repository key for that image.
	
	The root key is generated at: <pre>/root/.docker/trust/private/root_keys</pre>
	The repository key is generated at: <pre>/root/.docker/trust/private/tuf_keys/[registry_name]/[image_path]</pre>

You can see that the signed image that you pushed is marked with a green tick on the Project Repositories page in the Management Portal.

	
	