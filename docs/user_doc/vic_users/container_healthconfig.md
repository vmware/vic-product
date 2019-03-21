# Health Configuration #

You can configure a health check method to update the status of a container based on custom criteria.
vSphere Integrated Containers uses an own implementation of health checks and not the standard Docker implementation.

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