# Deploy Virtual Container Hosts in the vSphere Client #

If you have installed the HTML5 plug-in for vSphere Integrated Containers, you can deploy virtual container hosts (VCHs) interactively in the HTML5 vSphere Client.

The different options that you configure in the Create Virtual Container Host wizard in the vSphere Client correspond to `vic-machine create` options. The `vic-machine create` options are exposed by an API that runs in the `vic-machine-server` service of the vSphere Integrated Containers appliance. When you use the Create Virtual Container Host wizard, it deploys VCHs to the vCenter Server instance with which the vSphere Integrated Containers appliance is registered. Consequently, when you use the Create Virtual Container Host wizard, you do not need to provide any information about the deployment target, vSphere  administrator credentials, or vSphere certificate thumbprints.

**Prerequisites**

- You are running vCenter Server 6.5.0d or later. The vSphere Integrated Containers view does not function with earlier versions of vCenter Server 6.5.0.
- You installed the HTML5 plug-in for vSphere Integrated Containers.
- Make sure that your virtual infrastructure meets the requirements for VCH deployment. For information about virtual infrastructure requirements, see [Deployment Prerequisites for vSphere Integrated Containers](vic_installation_prereqs.md).
- Make sure that the correct ports are open on all ESXi hosts. For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

**Procedure**

1. Log in to the HTML5 vSphere Client with a vSphere administrator account, and click the **vSphere Client** logo in the top left corner.
2. Under Inventories, click **vSphere Integrated Containers**.

    The vSphere Integrated Containers view presents the number of VCHs and container VMs that you have deployed to this vCenter Server instance.

3. Click **vSphere Integrated Containers** in the main panel and the **Virtual Container Hosts** tab. 
4. Click **+ New Virtual Container Host**.

**What to Do Next**

See the following topics for instructions about how to fill in the different pages of the Create Virtual Container Host wizard:

- [General Settings](vch_general_settings.md)
- [Compute Capacity](vch_compute.md)
- [Storage Capacity](vch_storage.md)
- [Networks](vch_networking.md)
- [Security](vch_security.md)
- [Operations User](set_up_ops_user.md)
- [Summary](complete_vch_deployment_client.md)
