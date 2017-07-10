# Docker-in-VIC (DinV)

## Introduction

Docker-in-VIC (also known as DinV) is a way to run a full fledged docker engine as a ContainerVM using vSphere Integrated Containers, this functionality marries the flexibility and speed of containers with the security features and operational effectiveness of vSphere.

DinV hosts are packaged as containers and they can be instantiated on VIC just like any other regular container, DinV containers have several options that can be passed over the command line to enable/disable features in the Docker engine.

All the DinV packages are based on Photon OS and the source, dockerfiles and documentation is available at [github.com/vmware/vic-product](github.com/vmware/vic-product).

## Quickstart

The easiest way to get started with DinV is to run:

```console
$ docker run -p 12375:2375 -d vmware/dinv
```

And then connect to the newly deployed docker engine with:

```console
$ docker -H <VCH Host>:12375 info
```

With this quickstart configuration, the DinV container is not saved and communication is unencrypted, this can be easily fixed with more arguments when invoking the run command.

## Configuration

The DinV container is distributed prevalently through the Docker Hub, as of this writing, two versions of the engine are available: 1.13 and 1.12, versions can be used as a tag for the container (e.g. `vmware/dinv:1.12`).

When the container is run with the `-h` or `--help` flag, the help is shown and the container will quit without starting docker engine.

```console
$ docker run vmware/dinv -h
Usage of /dinv:
  -insecure-registry string
    	Enable insecure registry communication
  -local
    	Do not bind API to external interfaces
  -storage string
    	Storage driver to use (default "overlay2")
  -tls
    	Use TLS; implied by --tlsverify. Certs are generated automatically if not available
  -tlsverify
    	Use TLS and verify the remote. Certs are generated automatically if not available
```

- `insecure-registry`: is a list of registries for which no security consideration is given.
- `local`: will not bind the API endpoint to the external interface, the engine will only listen on `/var/run/docker.sock`.
- `storage`: this selects the docker storage driver to be used by the running engine, by default is set as `overlay2` which is the recommended engine when running as a ContainerVM.
- `tls`: this will enable secure communication with no verification of the remote, certs are loaded from `/certs` as `/certs/docker.crt` (Server certificate) and `/certs/docker.key` (Key for the server certificate).
- `tlsverify`: this will enable secure communication with verification of the remote, certs are loaded from `/certs/` as `/certs/ca.crt` (CA certificate), `/certs/docker.crt` (Server certificate) and `/certs/docker.key` (Key for the server certificate).

Two volumes are available to persist the docker engine certificates and image cache: `/certs` and `/var/lib/docker`, they can be used to persist state across runs and when performing engine upgrades.

## Certificate management

DinV containers probe the `/certs` directory during startup, looking for certificates to be used with docker engine, if those certificates are not present, the DinV container will create fresh ones using the IP of the ContainerVM.

If DinV container is run with `-tlsverify` and no certificates are provided, then a CA, server and client certificates will be created on startup, clients certificate can be copied with `docker cp` from the running container to your local host, these are the locations of the generated certs.

- When running with `-tls` and no certificates are present in `/certs`:

  - `/certs/docker.crt` - server certificate
  - `/certs/docker.key` - server key

- When running with `-tlsverify` and no certificates are present in `/certs/`:
  - `/certs/docker.key` - server key
  - `/certs/docker.crt` - server certificate
  - `/certs/ca.crt` - CA certificate
  - `/certs/ca-key.pem` - CA key
  - `/certs/docker-client.key` - client key
  - `/certs/docker-client.crt` - client certificate

They can be copied locally with `docker cp` when needed.

## Examples

### 1. Loading VCH certificates into a DinV ContainerVM used to perform docker builds

- Creates the DinV container, without starting the process

```console
$ docker create -p 12376:2376 --name dinv-build -v mycerts:/certs vmware/dinv -tlsverify
```
- Copy the certificates for the VCH into the newly created container

```console
$ docker cp virtual-container-host/ca.pem dinv-build:/certs/ca.crt
$ docker cp virtual-container-host/server-cert.pem dinv-build:/certs/docker.crt
$ docker cp virtual-container-host/server-key.pem dinv-build:/certs/docker.key
```
- Run DinV

```console
$ docker start dinv-build
```

- Connect to DinV
```console
$ source virtual-container-host/virtual-container-host.env
$ docker -H <VCH HOST>:12376 info
```

### 2. Store the Engine image cache in a persistent volume

- Run a DinV container with `/var/lib/docker` mounted in a persistent volume

```console
$ docker run -v myregistry:/var/lib/docker -v mycerts:/certs -p 12376:2376 vmware/dinv -tlsverify
```

### 3. Troubleshoot Docker Engine and the DinV wrapper

- Run a DinV container with `-e DEBUG=true`

```console
$ docker run -v mycerts:/certs -e DEBUG=true -p 12376:2376 -it vmware/dinv
```

### 4. Run a full-fledged DinV host with a separate network connection

- Creates the DinV container, without starting the process

```console
$ docker create --name dinv -v mycerts:/certs -v myregistry:/var/lib/docker --net=publicNet vmware/dinv -tlsverify
```

- Copy the certificates (pre created) into the newly created container

```console
$ docker cp ca.pem dinv:/certs/ca.crt
$ docker cp server-cert.pem dinv:/certs/docker.crt
$ docker cp server-key.pem dinv:/certs/docker.key
```
- Run DinV

```console
$ docker start dinv
```

- Connect to DinV (this requires [jq](https://stedolan.github.io/jq/))
```console
$ export DOCKER_HOST=$(docker inspect dinv | jq -r .[].NetworkSettings.Networks.publicNet.IPAddress):2376
$ export DOCKER_TLS_VERIFY=1
$ export DOCKER_CERT_PATH=.
$ docker info
```

### 5. Run a DinV host with mutual TLS without providing certificates upfromt

- Creates the DinV container, without starting the process

```console
$ docker run --name dinv -v mycerts:/certs -v myregistry:/var/lib/docker --net=publicNet -d vmware/dinv -tlsverify
```

- Copy the certificates (created by DinV) on your local machine

```console
$ docker cp dinv:/certs/ca.crt ca.pem
$ docker cp dinv:/certs/docker-client.crt cert.pem 
$ docker cp dinv:/certs/docker-client.key key.pem 
```

- Connect to DinV (this requires [jq](https://stedolan.github.io/jq/))
```console
$ export DOCKER_HOST=$(docker inspect dinv | jq -r .[].NetworkSettings.Networks.publicNet.IPAddress):2376
$ export DOCKER_TLS_VERIFY=1
$ export DOCKER_CERT_PATH=.
$ docker info
```
