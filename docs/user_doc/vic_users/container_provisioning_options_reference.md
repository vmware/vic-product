# Container Provisioning Options Reference #

When you create containers, configure the following settings:

- [Basic configuration](#basic-configuration)
- [Network configuration](#network-configuration)
- [Storage configuration](#storage-configuration)
- [Policy configuration](#policy-configuration)
- [Environment configuration](#environment-configuration)
- [Health configuration](#health-configuration)
- [Logging configuration](#logging-configuration)

## Basic Configuration ##

Configure the basic configuration of the container on the **Basic** tab of the Provision a Container page.

Configure the following settings:

- **Image**. The image that you want to instantiate the container from.
- **Name**. The name of the container in the project.
- **Commands**. The command array that must execute when the container starts.
- **Links**. The link to containers in another service. Specify a service name and a link alias. For example, you can link your container to a database service that runs in another container. You can specify `db` as the **Service** and `database` as the **Alias**.

## Network Configuration ##

Configure the network settings of the container on the **Network** tab of the Provision a Container page.

Configure the following settings:

- **Port Bindings**. A list of the exposed container ports and the host port that they should bind to.
- **Publish All Ports**. Select this option to publish all ports exposed by the container.
- **Hostname**. The virtual container host (VCH) or Docker host of the container.
- **Network mode. The networking mode of the container. Select one of the following options:
    - **Bridge**. The default network.
    - **None**. Select this option to indicate that the container is a standalone container.
    - **Host**. Selct this option if you want the container to use the networking stack of the virtual container host (VCH). In this case, both the container and the VCH will have the same networing stack.

## Storage Configuration ##

Configure the volume settings of the container on the **Storage** tab of the Provision a Container page.

Configure the following settings:

- **Volumes**. The volume name on the VCH and container structure of the volume. You must specify a volume name or an absolute path. The container field is mandatory and must contain an absolute path.

    For example, enter **Host** as `pgdata` and **Container** as `/var/lib/postgresql/data`.

- **Read Only**. Select this option to configure your volume as read only. For example, if you have an application that contains a Web and database service and the Web service shares its volume with the database service, you might want to configure the volume as read only.
- **Volumes From**. A list of volumes to inherit from another container.
- **Working Directory**. The working directory for the commands to run in.

## Policy Configuration ##

You can create container clusters by using Policy settings to specify cluster size.

When you configure a cluster, a specified number of containers are provisioned. Requests are load balanced among all containers in the cluster. You can modify the cluster size on a provisioned container or application to increase or decrease the size of the cluster by one. When you modify the cluster size at runtime, all affinity filters and placement rules are considered. 

For example, if you require three NGINX containers to serve a web application, specify **Cluster Size** as `3` Three containers are provisioned and a load balancer automatically load balances requests among the three containers.

Configure the following cluster settings on the **Policy** tab of the Provision a Container page:

- **Cluster Size**. The number of nodes that you want to provision.
- **Restart Policy**. The restart behavior that should be applied when the container exits. You can select one of the following options:
    - **None**. Default behavior.
    - **On-failure**. Indicates that the container must restart only when the process running on it fails. If you select this, you must specify the maximum number of restarts.
    - **Always**. Indicates that the container must restart when the process it is running completes.
- **Max Restarts**. The maximum number of times that the container tries to restart when it fails.
- **CPU shares**. An integer value that specifies the CPU shares for this container in relation to the other container VMs in the VCH resource pool.
- **Memory Limit**. The quantity of memory for use by the VCH resource pool. This limit also applies to the container VMs that run in the VCH resource pool. Specify the memory reservation value in MB.
- **Memory Swap Limit**. The total amount of RAM that the container must use. When the container runs out of RAM, it swaps to disk or physical storage.
- **Affinity Constraints**. Specify VM-Host affinity rules either as a requirement (must/must not rules) or a preference (should/should not rules).

For more information, see [Virtual Container Host Compute Capacity](../vic_vsphere_admin/vch_compute.md).

## Environment Configuration ##

When you configure a container, on the **Environment** tab, you can add industry standard variables.

Configure the following properties:

- **Environment Variables**. Configure the variables and values that you want to associate with the container For example, if you are creating a PostgreSQL container, you enter `POSTGRES_PASSWORD` in **Name** and the password in **Value**.
- **Custom Properties**.

For information about using Docker environment variables, see [Environment variables in Compose](https://docs.docker.com/compose/environment-variables/) in the Docker documentation.

## Health Configuration ##

You can configure a health check method to update the status of a container based on custom criteria.
vSphere Integrated Containers uses its own implementation of health checks and not the standard Docker implementation.

You can use HTTP or TCP protocols when executing a command on the container. You can also specify a health check method.

Configure the following health checks settings on the **Health Config** tab of the Provision a Container page:

- **Mode**. Configure one of the following modes:
    - **None**. Default. No health checks are configured.
    - **HTTP**. If you select HTTP, configure the **URL Path** and port for the container. Provide an API to access and an HTTP method and version to use. The API is relative and you do not need to enter the address of the container.
        
        You can also specify a timeout period for the operation and set health thresholds. For example, a healthy threshold of 2 means that two consecutive successful calls must occur for the container to be considered healthy and in the RUNNING status. An unhealthy threshold of 2 means that two unsuccessful calls must occur for the container to be considered unhealthy and in the ERROR status. For all the states in between the healthy and unhealthy thresholds, the container status is DEGRADED.
    - **TCP connection**. If you select TCP connection, you must only enter a port for the container. The health check attempts to establish a TCP connection with the container on the provided port. You can also specify a timeout value for the operation and set healthy or unhealthy thresholds as with HTTP.
    - **Command**. If you select Command, you must enter a command to be run on the container. The success of the health check is determined by the exit status of the command.
- **Ignore health check on provision**. You can enable a health check as part of the provisioning process for a container. By default, health checks are not performed during provisioning. Deselect this check box to require at least one successful health check before a container can be considered successfully provisioned.
- **Autoredeploy**. When a container returns an ERROR status, you can configure an automated redeploy for that container by selecting the **Autoredeploy** check box.

## Logging Configuration ##

Configure the logging mechanism of the container on the **Log Config** tab of the Provision a Container page.

Configure the following settings:

- **Driver**. The logging driver that you want to use for the container VM. For example, `json-file`.
- **Options**. The options to configure for the logging driver you select. For example, you can set the following names and corresponding values:
    - `max-size`: `10m`,
    - `max-file`: `3`,
    - `labels`: `production_status`,
    - `env`: `os,customer`
