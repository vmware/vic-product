# Add a Custom Registry Certificate Authority to `dch-photon`

If your registry uses a custom Certificate Authority (CA), you can add the CA root and other certificates to trusted root of the `dch-photon` container.

You might need to do this if you have seen errors such as the following when attempting to log in to the registry:

<pre>Error response from daemon: Get https://exampleregistry:443/v2/: x509: certificate signed by unknown authority</pre>

**Prerequisites**

- You are using `dch-photon` as a container host in a CI or build/push setup.
- You used a custom CA to generate registry certificates.

**Procedure**

1. Obtain the root and any secondary certificate files, and copy them into `/etc/ssl/certs` on your working machine.
2. Build a new `dch-photon` image, for example named `dch-photon-ca`. 

    To do this, you create a `Dockerfile` that extends the standard `dch-photon` image:<pre>
dockerfile
FROM vmware/dch-photon
COPY certs/*.crt /etc/ssl/certs/
RUN tdnf install -y openssl-c_rehash</pre>
ADD docker-entrypoint.sh /docker-entrypoint.sh
</pre>This image adds the following to `dch-photon`:

    * Copies the root and any secondary certificates into `/etc/ssl/certs` in the `dch-photon` container.
    * Installs `openssl-c_rehash`. You need to rehash the CAs so that programs such as OpenSSL can find newly added CAs. 
    * Add in a script named `docker-entrypoint.sh` to run when you run containers from this image. This is optional.
3. Create the `docker-entrypoint.sh` script.

    This script injects the certificates into `dch-photon` and starts it.<pre>sh
echo "Injecting CA certs"
openssl x509 -in /etc/ssl/certs/root.pem -text >> /etc/pki/tls/certs/ca-bundle.crt
openssl x509 -in /etc/ssl/certs/root-secondary.pem -text >> /etc/pki/tls/certs/ca-bundle.crt
echo "Rehashing new certificates"
c_rehash
echo "Starting DinV"
exec /dinv -tls
</pre>

**Result**

You can log in to the Docker registry that uses the custom CA from containers that you run from the `dch-photon-ca` image.