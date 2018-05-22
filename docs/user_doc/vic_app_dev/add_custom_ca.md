# Adding a custom Certificate Authority to DCH Photon

If you have deployed the VIC registry with a custom Certificate Authority, this procedure will provide the CA root and other certificates to Photon's trusted root.

You may have seen errors such as the following when attempting to login to your custom registry:

`Error response from daemon: Get https://exampleregistry:443/v2/: x509: certificate signed by unknown authority`


**Prerequisites**

- You are using DCH Photon as a Virtual Container Host in a CI or Build / Push setup
- A custom Certificate Authority was used to generate the VIC SSL certificates

**Procedure**

1. Obtain your Root and/or secondary certificate files

2. Create a Dockerfile which starts from vmware/dch-photon, add commands to:
    * Copy your root and/or secondary certificates into /etc/ssl/certs
    * Install openssl-c_rehash
    * Add in docker-entrypoint.sh (optional if you want to do this on execution of the container)


e.g. Dockerfile

```dockerfile
FROM vmware/dch-photon

# Copy your root and/or secondary certificates into /etc/ssl/certs
COPY certs/*.crt /etc/ssl/certs/

# Ensure you have openssl-c_rehash installed via tdnf (package manager for photon)
RUN tdnf install -y openssl-c_rehash

# Create an entrypoint file which hashes the certificates
ADD docker-entrypoint.sh /docker-entrypoint.sh
```

e.g. docker-entrypoint.sh

```sh
#!/bin/sh
echo "Injecting CA"
openssl x509 -in /etc/ssl/certs/root.pem -text >> /etc/pki/tls/certs/ca-bundle.crt
openssl x509 -in /etc/ssl/certs/root-secondary.pem -text >> /etc/pki/tls/certs/ca-bundle.crt
echo "Starting DinV"
exec /dinv -tls
```

**Result**

You should now be able to login to your custom signed docker registry
