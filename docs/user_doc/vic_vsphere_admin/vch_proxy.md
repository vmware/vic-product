# Configure VCHs to Use Proxy Servers #

If access to the Internet or to your private image registries requires the use of a proxy server, you must configure a virtual container host (VCH) to connect to the proxy server when you deploy it. The proxy is used only when pulling images, and not for any other purpose.

**IMPORTANT**: Configuring a VCH to use a proxy server does not configure proxy support on the containers that this VCH runs. Container developers must configure proxy servers on containers when they create them. 

You can add, reconfigure, or remove proxy servers after you have deployed a VCH by using the `vic-machine configure --https-proxy` and `--http-proxy` options. For information about adding, reconfiguring, or removing proxy servers, see Add, Configure, or Remove Proxy Servers in [Configure Running Virtual Container Hosts](configure_vch.md#proxies).

- [Options](#options)
  - [HTTP Proxy](#http)
  - [HTTPS Proxy](#https) 
- [Example `vic-machine` Command](#example)

## Options <a id="options"></a>

The sections in this topic each correspond to an entry in the Configure Networks page of the Create Virtual Container Host wizard, and to the  corresponding `vic-machine create` options.

### HTTP Proxy

The address of the HTTP proxy server through which the VCH accesses image registries when using HTTP.

#### Create VCH Wizard

Enter the IP address or FQN of an HTTP proxy in the **HTTP proxy** text box, for example `192.168.3.1`.

#### vic-machine Option 

`--http-proxy`, no short name

Specify the address of the proxy server in the `--http-proxy` option, as either an FQDN or an IP address.

<pre>--http-proxy http://proxy.example.mycompany.org:80</pre>

### HTTPS Proxy

The address of the HTTPS proxy server through which the VCH accesses image registries when using HTTPS.

#### Create VCH Wizard

Enter the IP address or FQN of an HTTPS proxy in the **HTTPS proxy** text box, for example `192.168.3.1`.

#### vic-machine Option 

`--https-proxy`, no short name

Specify the address of the proxy server in the `--https-proxy` option, as either an FQDN or an IP address.

<pre>--https-proxy https://proxy.example.mycompany.org:443</pre>

## Example `vic-machine` Command <a id="example"></a>

This example `vic-machine create` command deploys a VCH that accesses the network via an HTTPS proxy server.

<pre>vic-machine-<i>operating_system</i> create
--target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>/dc1
--compute-resource cluster1
--image-store datastore1
--bridge-network vch1-bridge
--https-proxy https://proxy.example.mycompany.org:443
--name vch1
--thumbprint <i>certificate_thumbprint</i>
--no-tlsverify
</pre>