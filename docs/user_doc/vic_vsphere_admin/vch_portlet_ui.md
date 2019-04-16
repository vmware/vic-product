# View Individual VCH and Container Information in the vSphere Clients #

After you have installed the client plug-in for vSphere Integrated Containers, you can find information about individual virtual container hosts (VCHs) and container VMs in the HTML5 vSphere Client or the Flex-based vSphere Web Client.

**IMPORTANT**: Do not perform operations on virtual container hosts (VCHs) or container VMs in the vSphere Client inventory views. Specifically, using the vSphere Client inventory views to power off, power on, or delete the VCH endpoint VM, or to modify the VCH resource pool or folder, can cause vSphere Integrated Containers Engine to not function correctly. Always use the vSphere Integrated Containers plug-in for the HTML5 vSphere Client or `vic-machine` to perform operations on VCHs. The vSphere Client does not allow you to delete container VMs, but do not use the vSphere Client to power container VMs on or off. Always use Docker commands or vSphere Integrated Containers Management Portal to perform operations on containers.

## Prerequisites

- You deployed a VCH and at least one container VM.
- You installed the plug-in for vSphere Integrated Containers.

  - The vSphere Integrated Containers plug-in for the HTML5 vSphere Client plug-in is available in vSphere 6.5 and 6.7.
  - The vSphere Integrated Containers plug-in for the Flex-based vSphere  Web Client is available in vSphere 6.0.

**NOTE**: vSphere Integrated Containers 1.5.2 and later versions do not include the Flex-based vSphere Web Client.

## Procedure

1. Log in to the vSphere Client.
2. On the **Home** page, select **Hosts and Clusters**.
2. Expand the hierarchy of vCenter Server objects to navigate to the VCH resource pool.
3. Expand the VCH resource pool and select the VCH endpoint VM.

    Information about the VCH appears in the **Virtual Container Host** portlet in the **Summary** tab:

    - The `DOCKER_HOST` environment variable that container developers use to connect to this VCH.
    - The link to the VCH Admin Portal for this VCH.

4. Select a container VM.

    Information about the container VM appears in the **Container** portlet in the **Summary** tab:
    - The name of the running container. If the container developer used <code>docker run -name <i>container_name</i></code> to run the container, <code><i>container_name</i></code> appears in the portlet.
    - The image from which the container was deployed.
    - If the container developer used <code>docker run -p <i>port</i></code> to map a port when running the container, the port number and the protocol appear in the portlet.



