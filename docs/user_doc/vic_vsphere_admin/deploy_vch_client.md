# Deploy Virtual Container Hosts in the vSphere Client #

If you have installed the HTML5 plug-in for vSphere Integrated Containers, you can deploy virtual container hosts (VCHs) interactively in the vSphere Client.

The different options that you configure in the Create Virtual Container Host wizard in the vSphere Client correspond to `vic-machine create` options. The `vic-machine create` options are exposed by the `vic-machine-server` service of the vSphere Integrated Containers appliance. When you use the Create Virtual Container Host wizard, it deploys VCHs to the vCenter Server instance with which the vSphere Integrated Containers appliance is registered, and uses the vSphere credentials with which you are logged in to the vSphere Client. Consequently, when using the Create Virtual Container Host wizard, you do not need to provide any information about the deployment target, vSphere administrator credentials, or vSphere certificate thumbprints.

**Prerequisites**

- You are running vCenter Server 6.7 or vCenter Server 6.5.0d or later. The vSphere Integrated Containers view does not function with earlier versions of vCenter Server 6.5.0.
- You installed the HTML5 plug-in for vSphere Integrated Containers.
- Make sure that your virtual infrastructure meets the requirements for VCH deployment. For information about virtual infrastructure requirements, see [Deployment Prerequisites for vSphere Integrated Containers](vic_installation_prereqs.md). 

    **IMPORTANT**: Pay particular attention to the [Networking Requirements for VCH Deployment](network_reqs.md#vchnetworkreqs).
- Familiarize yourself with the way in which VCHs use certificates to authenticate connections from clients. For information about certificate use by VCHs and Docker, see the [Virtual Container Host Certificate Requirements](vch_cert_reqs.md).
- Make sure that the correct ports are open on all ESXi hosts. For information about how to open ports on ESXi hosts, see [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md).

**Procedure**

1. Log in to the HTML5 vSphere Client with a vSphere administrator account, and click the **vSphere Client** logo in the top left corner.
2. Under Inventories, click **vSphere Integrated Containers**.

    The vSphere Integrated Containers view presents the number of VCHs and container VMs that you have deployed to this vCenter Server instance.

3. Click **vSphere Integrated Containers** in the main panel and select the **Virtual Container Hosts** tab. 

    On first connection after installation or upgrade, if you see the message <code>Failed to verify the vic-machine server at endpoint https://vic_appliance_address:8443</code>, perform the following steps to trust the certificate of the `vic-machine` service that is running in the appliance: 

    1. Click the link **View API directly in your browser** that appears in step 3 of the error message.  
    2. In the new browser tab that opens, follow your browser's usual procedure to trust the certificate. 
    
        You should see the confirmation message `You have successfully accessed the VCH Management API`.

    3. Close the new browser tab and click the **Refresh** button in the error message in the **Virtual Container Hosts** tab.
    
    When you have trusted the certificate, the error message disappears.

4. Click **+ New Virtual Container Host**.

    The Create Virtual Container Host wizard opens.

**What to Do Next**

See [Virtual Container Host Deployment Options](vch_deployment_options.md) for instructions about how to fill in the pages of the Create Virtual Container Host wizard.