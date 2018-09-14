# Configure `dch-photon` to Use Proxy Servers #

If your environment uses proxies, you must configure `dch-photon` containers to use the proxy servers.

You can configure proxy servers on `dch-photon` containers either by setting environment variables at runtime, or by creating a custom `dch-photon` image that includes the same variables.

## Set Environment Variables at Runtime ##

When you run the `dch-photon` container, use the `--env` option to add the proxy servers as environment variables. If you use this method, you must set the environment variables every time that you run `dch-photon`.

<pre>$ docker run 
--detach 
--env https_proxy=https://proxy.server.com:3128 
--env http_proxy=http://proxy.server.com:3128 
--publish 12376:2376 
vmware/dch-photon:1.13 
-tls 
-vic-ip <i>vch_adress</i>
</pre>

This command instantiates a `dch-photon` container with the following configuration:

- Uses `--detach` to run the container in the background.
- Sets HTTP and HTTPS proxy servers as environment variables.
- Exposes the Docker API running in the `dch-photon` container to port 12376 on the virtual container host (VCH) on which it is deployed.
- Uses the `dch-photon` options `-tls` and `-vic-ip` to use auto-generated certificates without client verification when connecting to the VCH.


## Add Environment Variables to a Custom `dch-photon` Image ##

Build a new `dch-photon` image, for example named `dch-photon-proxy` based on the official one. To do this, you create a `Dockerfile` that includes proxy environment variables:

<pre>
dockerfile
FROM vmware/dch-photon:1.13
ENV http_proxy http://proxy.server.com:8080
ENV https_proxy https://proxy.server.com:8080
</pre>

If you use this method, you do not need to specify the environment variables each time you run containers from the custom  `dch-photon-proxy` image.