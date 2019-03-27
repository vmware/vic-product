# Network Configuration #

Configure the network settings of the container on the **Network** tab of the Provision a Container page. 

Configure the following settings:

- Port Bindings. A list of the exposed container ports and the host port that they should bind to. 
- Publish All Ports. Select this option to publish all ports exposed by the image.
- Hostname. The host name of the container.
- Network mode. The networking mode of the container. Select one of the following options:
    - Bridge. The default network.
    - None. Select this option to indicate that the container is a standalonec ontainer.
    - Host. Selct this option if you want the container to use the networking stack of the virtual container host (VCH). In this case, both the container and the VCH will have the same networing stack.