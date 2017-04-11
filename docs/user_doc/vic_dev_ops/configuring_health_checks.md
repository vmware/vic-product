# Configuring Health Checks #

You can configure a health check method to update the status of a container based on custom criteria.

You can use HTTP or TCP protocols when executing a command on the container. You can also specify a health check method. The available health configuration modes are described below.

Mode | Description
------------ | -------------
**None** | Default. No health checks are configured.
**HTTP** | If you select HTTP, you must provide an API to access and an HTTP method and version to use . The API is
relative and you do not need to enter the address of the container. You can also specify a timeout period for the
operation and set health thresholds. For example, a healthy threshold of 2 means that two consecutive successful calls must occur for the container to be considered healthy and in the RUNNING status. An unhealthy threshold of 2 means that two unsuccessful calls must occur for the container to be considered unhealthy and in the ERROR status. For all the states in between the healthy and unhealthy thresholds, the container status is DEGRADED. 
**TCP connection** | If you select TCP connection, you must only enter a port for the container. The health check attempts to establish a TCP connection with the container on the provided port. You can also specify a timeout value for the operation and set healthy or unhealthy thresholds as with HTTP. 
**Command** | If you select Command, you must enter a command to be run on the container. The success of the health check is determined by the exit status of the command.  


