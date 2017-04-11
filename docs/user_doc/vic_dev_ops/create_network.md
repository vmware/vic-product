# Create New Networks for Provisioning Containers #

You can create, modify, and attach network configurations to containers and container templates.

** Procedure **

1. In the management portal, navigate to **Deployments** > **Networks** and click **Create Network**.
2. On the Create Network page, select the **Advanced** check box to access all available settings.
3. Configure the new network settings and click **Create**.

Setting | Description
------------ | -------------
**Name** | Enter a name for the network.
**IPAM config** | Enter subnet, IP range, and gateway values that are unique to this network configuration. They must not overlap with any other networks on the same container host.
**Custom Properties** | (Optional) Specify custom properties for the new network configuration.  `containers.ipam.driver` - for use with containers only. Specifies the IPAM driver to be used when adding a network component. The supported values depend on the drivers that are installed in the container host environment in which they are used. For example, a supported value might be infoblox or calico depending on the IPAM plug-ins that are installed on the container host. This property name and value are case-sensitive. The property value is not validated when you add it. If the specified driver does not exist on the container host at provisioning time, an error message is returned and provisioning fails. `containers.network.driver` - for use with containers only. Specifies the network driver to be used when adding a network component. The supported values depend on the drivers that are installed in the container host environment in which they are used. By default, Docker-supplied network drivers include bridge, overlay, and macvlan, while VCH-supplied network drivers include the bridge driver. Third-party network drivers such as weave and calico might also be available, depending on what networking plug-ins are installed on the container host. This property name and value are case-sensitive. The property value is not validated when you add it. If the specified driver does not exist on the container host at provisioning time, an error message is returned and provisioning fails. 
**Hosts** | Select the hosts to use the new network.

**Result**

New network is created and you can provision containers on it.