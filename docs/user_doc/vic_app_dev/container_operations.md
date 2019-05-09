# Supported Docker Commands

 vSphere Integrated Containers Engine 1.5 supports Docker client 1.13.0. The supported version of the Docker API is 1.25. 

- [Docker Management Commands](#mgmt)
- [Image Commands](#image)
- [Container Commands](#container)
- [Hub and Registry Commands](#registry)
- [Network and Connectivity Commands](#network)
- [Shared Data Volume Commands](#volume)
- [Docker Compose Commands](#compose)
- [Swarm Commands](#swarm)

## Docker Management Commands <a id="mgmt"></a>

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
|`dockerd`|[Launch the Docker daemon](https://docs.docker.com/engine/reference/commandline/dockerd/)|Not applicable. This construct does not exist in vSphere Integrated Containers|
|`info`|[Docker system information](https://docs.docker.com/engine/reference/commandline/info/)|Yes, since 1.0. Provides Docker-specific data, basic capacity information, lists configured volume stores, and virtual container host information. Does not reveal vSphere datastore paths that might contain sensitive vSphere information.|
|`inspect`|[Inspect a container or image](https://docs.docker.com/engine/reference/commandline/inspect/)|Yes, since 1.0. Includes information about the container network. You can use container labels when running `docker inspect`.|
|`version`|[Docker version information](https://docs.docker.com/engine/reference/commandline/version/)|Yes, since 1.0|

## Image Commands <a id="image"></a>

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
|`build`|[Build an image from a Dockerfile](https://docs.docker.com/engine/reference/commandline/build/)|No|
|`commit`|[Create a new image from a container’s changes](https://docs.docker.com/engine/reference/commandline/commit/)|Yes, since 1.2. You can only run `docker commit` on stopped containers.|
|`history`|[Show the history of an image](https://docs.docker.com/engine/reference/commandline/history/)|No|
|`images`|[Images](https://docs.docker.com/engine/reference/commandline/images/)|Yes, since 1.0. Supports `--filter`, `--no-trunc`, and `--quiet`|
|`import`|[Import the contents from a tarball to create a filesystem image](https://docs.docker.com/engine/reference/commandline/import/)|No|
|`load`|[Load an image from a tar archive or STDIN](https://docs.docker.com/engine/reference/commandline/load/)|No|
|`rmi`|[Remove a Docker image](https://docs.docker.com/engine/reference/commandline/rmi/)|Yes, since 1.0|
|`save`|[Save images](https://docs.docker.com/engine/reference/commandline/save/)|No|
|`tag`|[Tag an image into a repository](https://docs.docker.com/engine/reference/commandline/tag/)|Yes, since 1.0|

## Container Commands <a id="container"></a>

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
|`attach`|[Attach to a container](https://docs.docker.com/engine/reference/commandline/attach/)|Yes, since 1.0|
|`container list`|[List Containers](https://docs.docker.com/engine/reference/api/docker_remote_api_v1.22/#list-containers)|Yes, since 1.0|
|`container resize`|[Resize a container](https://docs.docker.com/engine/reference/api/docker_remote_api_v1.23/#resize-a-container-tty)|Yes, since 1.0|
|`cp`|[Copy files or folders between a container and the local filesystem](https://docs.docker.com/engine/reference/commandline/cp/)|Yes, since 1.2. You cannot copy to an NFS volume that is not in use by a running container. You cannot copy from an unstarted container that uses NFS volumes.|
|`create`|[Create a container](https://docs.docker.com/engine/reference/commandline/create/)|Yes, since 1.0. <br>`--cpuset-cpus` in Docker specifies CPUs the container is allowed to use during execution (0-3, 0,1). In vSphere Integrated Containers Engine, this parameter specifies the number of virtual CPUs to allocate to the container VM. Minimum CPU count is 1, maximum is unlimited. Default is 2.<br>`--ip` allows you to set a static IP on the container. By default, the virtual container host  manages the container IP.<br> Minimum value for `--memory` is 512MB, maximum unlimited. If unspecified, the default is 2GB. Supports the `--attach`, `--cidfile`, `--cpuset-cpus`, `--entrypoint`, `--env`, `--env-file`, `--help`, `--interactive`, `--ip`, `--label`, `--label-file`, `--link`, `--memory`, `--name`, `--net`, `--net-alias`, `--publish`, `--rm`, `--stop-signal`, `--stop-timeout`, `--tty`, `--user`, `--volume`, and `--workdir` options.|
|`diff`|[Inspect changes on a container's filesystem](https://docs.docker.com/engine/reference/commandline/diff/)|Yes, since 1.2|
|`events`|[Get real time events from the server](https://docs.docker.com/engine/reference/commandline/events/)|Yes, since 1.0. Supports passive Docker events for containers and images. Does not yet support events for volumes or networks.|
|`exec`|[Run a command in a running container](https://docs.docker.com/engine/reference/commandline/exec/)|Yes, since 1.2|
|`export`|[Export a container](https://docs.docker.com/engine/reference/commandline/export/)|No|
|`kill`|[Kill a running container](https://docs.docker.com/engine/reference/commandline/kill/)|Yes, since 1.0. Docker must wait for the container to shut down.|
|`logs`|[Get container logs](https://docs.docker.com/engine/reference/commandline/logs/)|Yes, since 1.0. Supports `--since` and `--timestamps` since 1.2. |
|`pause`|[Pause processes in a container](https://docs.docker.com/engine/reference/commandline/pause/)|No|
|`port`|[Obtain port data](https://docs.docker.com/engine/reference/commandline/port/)|Yes, since 1.0. Displays port mapping data. <br>Supports mapping a random host port to the container when the host port is not specified.|
|`ps`|[Show running containers](https://docs.docker.com/engine/reference/commandline/ps/)|Yes, since 1.0. Supports the `-a/--all`, `-f/--filter`, `--no-trunc`, and `-q/--quiet` options. Filtering by network name is supported, but filtering by network ID is not supported. You can use `docker ps --filter="label=..."` to filter out containers with certain labels.|
|`rename`|[Rename a container](https://docs.docker.com/engine/reference/commandline/rename/)|Yes, since 1.1. Name resolution for renamed running containers is not supported, but if you restart the container the new name is resolved.|
|`restart`|[Restart a container](https://docs.docker.com/engine/reference/commandline/restart/)|Yes, since 1.0|
|`rm`|[Remove a container](https://docs.docker.com/engine/reference/commandline/rm/)|Yes, since 1.0. Supports the `--force` option and the `name` parameter. To view volumes attached to a container that is removed, use `docker volume ls` and `docker volume inspect <id>`. If you continually invoke `docker create` to make more anonymous volumes, those volumes are left behind after each subsequent removal of that container. <br>Supports `docker rm -v` since 1.3. Running the command removes the container and any anonymous volumes joined to that container. If an anonymous volume is in use by another container, it is not removed. Named volumes that you specify by name in the create/run command are not deleted.|
|`run`|[Run a command in a new container](https://docs.docker.com/engine/reference/commandline/run/)| <a id="docker_run"></a>Yes, since 1.0.  Supports mapping a random host port to the container when the host port is not specified. <br>Supports running images from private and custom registries.<br>`docker run -h` is supported since 1.3.0. You can specify a container network by using the [`--container-network`](../vic_vsphere_admin/container_networks.md) option when you deploy a virtual container host. Supports the `--attach`, `--cidfile`, `--cpuset-cpus`, `--detach`, `--detach-keys`, `--dns`, `--entrypoint`, `--env`, `--env-file`, `--help`, `--interactive`, `--ip`, `--label`, `--label-file`, `--link`, `--memory`, `--name`, `--net`, `--net-alias`, `--publish`, `--rm`, `--stop-signal`, `--stop-timeout`, `--tty`, `--user`, `--volume`, and `--workdir` options.<br>**NOTE**: If you use a network container that supports DHCP, you must specify the `--dns` option (DNS server) for the container to get an IP address from DHCP server. If you do not specify a DNS server, the command times out with an error.|
|`start`|[Start a container](https://docs.docker.com/engine/reference/commandline/start/)|Yes, since 1.0. Supports the `--attach` and `--interactive` options.|
|`stats`|[Get container stats based on resource usage](https://docs.docker.com/engine/reference/commandline/stats/)|Yes. Provides statistics about CPU and memory usage since 1.1. Provides statistics about network or disk usage since 1.2.|
|`stop`|[Stop a container](https://docs.docker.com/engine/reference/commandline/stop/)|Yes, since 1.0. Attempts to politely stop the container. If that fails, powers down the VM.|
|`top`|[Display the running processes of a container](https://docs.docker.com/engine/reference/commandline/top/)|No|
|`unpause`|[Unpause processes within a container](https://docs.docker.com/engine/reference/commandline/unpause/)|No|
|`update`| [Update a container](https://docs.docker.com/engine/reference/commandline/update/)|No|
|`wait`|[Wait for a container](https://docs.docker.com/engine/reference/commandline/wait/)|Yes, since 1.0|

## Hub and Registry Commands <a id="registry"></a>

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
|`login`|[Log into a registry](https://docs.docker.com/engine/reference/commandline/login/)|Yes, since 1.0|
|`logout`|[Log out from a registry](https://docs.docker.com/engine/reference/commandline/logout/)|Yes, since 1.0|
|`pull`|[Pull an image or repository from a registry](https://docs.docker.com/engine/reference/commandline/pull/)| Yes, since 1.0. Supports pulling from  secure or insecure public and private registries.|
|`push`|[Push an image or a repository to a registry](https://docs.docker.com/engine/reference/commandline/push/)|No|
|`search`|[Search the Docker hub for images](https://docs.docker.com/engine/reference/commandline/search/)|No|

## Network and Connectivity Commands <a id="network"></a>

For more information about network operations with vSphere Integrated Containers Engine, see [Container Networking with vSphere Integrated Containers Engine](network_use_cases.md).

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
|`network connect`|[Connect to a network](https://docs.docker.com/engine/reference/commandline/network_connect/)|Yes, since 1.0. Not supported for running containers.<br><br>You can specify the `--ip` option to assign a static IP address to a container. If you do not specify `--ip`, the VCH assigns an IP address from the provided range of addresses for the container network. Using the `--ip` option on container networks with DHCP enabled is not supported.|
|`network create`|[Create a network](https://docs.docker.com/engine/reference/commandline/network_create/)|Yes, since 1.1. See the use case to connect a container to an external network in [Container Networking with vSphere Integrated Containers Engine](network_use_cases.md). Bridge is also supported.|
|`network disconnect`|[Disconnect a network](https://docs.docker.com/engine/reference/commandline/network_disconnect/)|No|
|`network inspect`|[Inspect a network](https://docs.docker.com/engine/reference/commandline/network_inspect/)|Yes, since 1.0|
|`network ls`|[List networks/](https://docs.docker.com/engine/reference/commandline/network_ls/)|Yes, since 1.0|
|`network rm`|[Remove a network](https://docs.docker.com/engine/reference/commandline/network_rm/)|Yes, since 1.0. Network name and network ID are supported.|

## Shared Data Volume Commands <a id="volume"></a>

For more information about volume operations with vSphere Integrated Containers Engine, see [Using Volumes with vSphere Integrated Containers Engine](using_volumes_with_vic.md).

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
|`volume create`|[Create a volume](https://docs.docker.com/engine/reference/commandline/volume_create/)|Yes, since 1.0. Supports the `--opt Capacity` and `--opt VolumeStore` options, and ignores any other options that you might specify. Currently only supports `ext4` file systems for volume stores. |
|`volume inspect`|[Information about a volume](https://docs.docker.com/engine/reference/commandline/volume_inspect/)|Yes, since 1.0|
|`volume ls`|[List volumes](https://docs.docker.com/engine/reference/commandline/volume_ls/)|Yes, since 1.0|
|`volume rm`|[Remove or delete a volume](https://docs.docker.com/engine/reference/commandline/volume_rm/)|Yes, since 1.0|

## Docker Compose Commands <a id="compose"></a>

vSphere Integrated Containers Engine 1.5 supports Docker Compose version 1.11.2.

For more information about using Docker Compose with vSphere Integrated Containers Engine, see [Creating a Containerized Application with vSphere Integrated Containers Engine](creating_containerized_app_with_vic.md).

For information about Docker Compose file support, see [Supported Docker Compose File Options](docker_compose_file_options.md).

| **Command** | **Docker Reference** | **Supported** |
| --- | --- | --- |
| `build`  | [Build or rebuild service](https://docs.docker.com/compose/reference/build/)  | No. Depends on `docker build`.|
| `bundle`  | [Generate a Distributed Application Bundle (DAB) from the Compose file](https://docs.docker.com/compose/reference/bundle/)| Yes, since 1.1 |
| `config`  | [Validate and view the compose file](https://docs.docker.com/compose/reference/config/)  | Yes, since 1.0  |
| `create`  | [Create services](https://docs.docker.com/compose/reference/create/)  | Yes, since 1.0  |
| `down`  | [Stop and remove containers, networks, images, and volumes](https://docs.docker.com/compose/reference/down/)  | Yes, since 1.0  |
| `events`  |[Receive real time events from containers](https://docs.docker.com/compose/reference/events/)  | Yes, since 1.0. Supports passive Docker events for containers and images. Does not yet support events for volumes or networks.|
| `exec`  | [Run commands in services](https://docs.docker.com/compose/reference/exec/) | No. Depends on `docker exec`. |
| `help`  | [Get help on a command](https://docs.docker.com/compose/reference/help/)  | Yes, since 1.0  |
| `kill`  | [Kill containers](https://docs.docker.com/compose/reference/kill/)  | No, but `docker kill` works. |
| `logs`  | [View output from containers](https://docs.docker.com/compose/reference/logs/)  | Yes, since 1.0 |
| `pause`  | [Pause services](https://docs.docker.com/compose/reference/pause/)  | No. Depends on `docker pause`.  |
| `port`  | [Print the public port for a port binding](https://docs.docker.com/compose/reference/port/)  | Yes, since 1.0 |
| `ps`  | [List containers](https://docs.docker.com/compose/reference/ps/)  |Yes, since 1.0 |
| `pull`  | [Pulls service images](https://docs.docker.com/compose/reference/pull/)  | Yes, since 1.0  |
| `push`  | [Pushes images for service](https://docs.docker.com/compose/reference/push/)  | No. Depends on `docker push`  |
| `restart`  |	[Restart services](https://docs.docker.com/compose/reference/restart/)  | Yes, since 1.0  |
| `rm`  | [Remove stopped containers](https://docs.docker.com/compose/reference/rm/)  | Yes, since 1.0  |
| `run`  | [Run a one-off command](https://docs.docker.com/compose/reference/run/)  | Yes, since 1.0  |
| `scale`  | [Set number of containers for a service](https://docs.docker.com/compose/reference/scale/)  | Yes, since 1.0 |
| `start`  | [Start services](https://docs.docker.com/compose/reference/start/)  | Yes, since 1.0  |
| `stop`  | [Stop services](https://docs.docker.com/compose/reference/stop/)  | Yes, since 1.0  |
| `unpause`  | [Unpause services](https://docs.docker.com/compose/reference/unpause/)  | No. Depends on `docker unpause`.  |
| `up`  | [Create and start containers]()  | Yes, since 1.1|
| `version`  | Show Docker Compose version information  | Yes, since 1.0  |

## Swarm Commands <a id="swarm"></a>

This version of vSphere Integrated Containers Engine does not directly support Docker Swarm. However, you can use the [`dch-photon` Docker Engine](build_push_images.md) to instantiate a Docker swarm for use with vSphere Integrated Containers. 

**NOTE**: Using `dch-photon` to instantiate Docker swarm is not officially supported.