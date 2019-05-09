# Deployment of Container that supports DHCP Network Fails 

When you deploy a container by specifying the DHCP network in the Docker run command, deployment fails and the command times out with an error.

## Problem

If you use a network container that supports DHCP and the Docker run command to deploy the container, the command times out with the following error:
 
`docker: Error response from daemon: Server error from portlayer: unable to wait for process launch status`

## Cause

The `--dns` option is not specified in the docker run command.

## Solution 

 Specify the `--dns` option in the Docker run command for the container to get an IP address from DHCP server. For more information, see [Supported Docker Commands](../vic_app_dev/container_operations.md#container).