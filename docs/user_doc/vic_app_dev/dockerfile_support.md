# Supported Dockerfile Instructions #

Some Dockerfile instructions are directives to the build process and a subset of them are directives to the container engine when a container is run. The latter is an important consideration when it comes to putting a Docker image into production.

For more information on Dockerfile instructions, see the [Dockerfile reference](https://docs.docker.com/engine/reference/builder) here.

This topic provides information about which of the runtime Dockerfile instructions that vSphere Integrated Containers Engine 1.3 supports.

| **Option** | **Dockerfile Reference** | **Supported** |
| --- | --- | --- |
|`LABEL`|[Add metadata to an image](https://docs.docker.com/engine/reference/builder/#label)|Yes|
|`EXPOSE`|[Expose a port](https://docs.docker.com/engine/reference/builder/#expose)|Not yet supported. Port mappings need to be explicitly declared with `docker run -p`|
|`ENV`|[Set an environment variable](https://docs.docker.com/engine/reference/builder/#env)|Yes|
|`ENTRYPOINT`|[Set the executable to be run on start](https://docs.docker.com/engine/reference/builder/#entrypoint)|Yes|
|`CMD`|[Set commands to be run on start](https://docs.docker.com/engine/reference/builder/#cmd)|Yes|
|`USER`|[Set the user that runs the main process](https://docs.docker.com/engine/reference/builder/#user)|Yes|
|`WORKDIR`|[Set the working directory](https://docs.docker.com/engine/reference/builder/#workdir)|Yes|
|`STOPSIGNAL`|[Set a stop signal for the container](https://docs.docker.com/engine/reference/builder/#stopsignal)|Not yet supported. A stop signal can be explicitly declared with `docker run --stop-signal`|
|`HEALTHCHECK`|[Set a health check process](https://docs.docker.com/engine/reference/builder/#healthcheck)|No health check options supported yet.|
|`SHELL`|[Set a default shell](https://docs.docker.com/engine/reference/builder/#shell)|Yes|

