# Creating New Networks #

You can create and attach network configurations to containers, container templates, and applications. You can create a bridge network or a container network. 

You can dissociate a network from a container by deleting it.

For more information about container networks and how to configure them, see [Configure Container Networks](../vic_vsphere_admin/container_networks.md)

**Procedure**

1. In the management portal, navigate to **Deployments** > **Networks** and click **+Network**.
2. On the Create Network page, select the **Advanced** check box to access all available settings.
2. Configure the following settings:
    - **Name**. Enter a name for the network.
    - **IPAM config**. Enter subnet, IP range, and gateway values that are unique to this network configuration. They must not overlap with any other networks on the same container host.
    - **Custom Properties**. Optionally specify custom properties for the new network configuration.
        
        For example, you can specify the following properties: 
        
        - `bridge.default_bridge`: `true`,
        - `bridge.enable_icc`: `true`,
        - `bridge.enable_ip_masquerade`: `true`,
        - `bridge.host_binding_ipv4`: `0.0.0.0`,
        - `bridge.name`: `docker0`,
        - `driver.mtu`: `9001`
       
    - **Hosts**. Specify the IP address or FQDN of the container.
3. Click **Create**.

**Result**

The new network is created and you can provision containers on it.