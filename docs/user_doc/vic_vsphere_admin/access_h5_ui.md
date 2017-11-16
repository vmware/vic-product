# View All VCH and Container Information in the HTML5 vSphere Client #

If you have installed the HTML5 plug-in for vSphere Integrated Containers, you can find information about your vSphere Integrated Containers deployment in the HTML5 vSphere Client.

**IMPORTANT**: Do not use the vSphere Client or to perform operations on virtual container hosts or container VMs. Specifically, using the vSphere Client to power off, power on, or delete the VCH vApp or VCH endpoint VM can cause vSphere Integrated Containers Engine to not function correctly. Always use `vic-machine` to perform operations on VCHs. The vSphere Client does not allow you to delete container VMs, but do not use the vSphere Client to power container VMs on or off. Always use Docker commands to perform operations on containers. 

**NOTE**: More functionality will be added to the vSphere Integrated Containers view in future releases.

**Prerequisites**

- You are running vCenter Server 6.5.0d or later. The vSphere Integrated Containers view does not function with earlier versions of vCenter Server 6.5.0.
- You installed the HTML5 plug-in for vSphere Integrated Containers.

**Procedure**

1. Log in to the HTML5 vSphere Client and click the **vSphere Client** logo in the top left corner.
2. Under Inventories, click **vSphere Integrated Containers**.

    The vSphere Integrated Containers view presents the number of VCHs and container VMs that you have deployed.

3. Click **vSphere Integrated Containers** in the main panel and select the **Summary** tab.

    The **Summary** tab shows the version of vSphere Integrated Containers that you are running and the number of VCHs.
4. Select the **Virtual Container Hosts** tab. 

    The **Virtual Container Hosts** tab provides information about the VCHs that are registered with this vCenter Server instance: 

    - Lists all VCHs by name. Click the VCH name to go to the Summary tab for the VCH endpoint VM.
    - Indicates that the VCH is running correctly.
    - Displays the `DOCKER_HOST` environment variable that container developers use to connect to this VCH.
    - Provides the link to the VCH Admin Portal for this VCH.

5. Select the **Containers** tab.

    The **Containers** tab shows information about all of the container VMs that are running in this vCenter Server instance, for all VCHs:

    - Lists all containers by name.
    - Indicates whether the container VM is powered on or off.
    - Provides information about the memory, CPU, and storage consumption of the container VM.
    - Lists the port number and the protocol of any mapped ports that the container VM exposes.
    - Provides links to the Summary tabs for the VCH that manages the container VM and for the VM itself.
    - Displays the image from which this container VM was created.




