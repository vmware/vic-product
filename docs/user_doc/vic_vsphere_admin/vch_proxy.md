# Configure VCHs to Use Proxy Servers #

If access to the Internet or to your private image registries requires the use of a proxy server, you must configure a VCH to connect to the proxy server when you deploy it. The proxy is used only when pulling images, and not for any other purpose.

**IMPORTANT**: Configuring a VCH to use a proxy server does not configure proxy support on the containers that this VCH runs. Container developers must configure proxy servers on containers when they create them. 

### `--https-proxy` ###

Short name: None

The address of the HTTPS proxy server through which the VCH accesses image registries when using HTTPS. Specify the address of the proxy server as either an FQDN or an IP address.

<pre>--https-proxy https://<i>proxy_server_address</i>:<i>port</i></pre>

### `--http-proxy` ###

Short name: None

The address of the HTTP proxy server through which the VCH accesses image registries when using HTTP. Specify the address of the proxy server as either an FQDN or an IP address.

<pre>--http-proxy http://<i>proxy_server_address</i>:<i>port</i></pre>

### Example

If your network access is controlled by a proxy server, you must   configure a VCH to connect to the proxy server when you deploy it, so that it can pull images from external sources.

This example deploys a VCH with the following configuration:

- Specifies the user name, password, image store, cluster, bridge network, and name for the VCH.
- Configures the VCH to access the network via an HTTPS proxy server.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--https-proxy https://<i>proxy_server_address</i>:<i>port</i>
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tls
</pre>