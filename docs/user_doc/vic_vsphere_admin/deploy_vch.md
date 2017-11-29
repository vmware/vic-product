<!-- THIS TOPIC IS LINKED FROM THE GETTING STARTED PAGE / UI -->

# Deploy Virtual Container Hosts #

In vSphere Integrated Containers, you deploy virtual container hosts (VCHs) that serve as Docker API endpoints. VCHs allow Docker developers to provision containers as VMs in your vSphere environment. For a description of the role and function of VCHs, see [What is vSphere Integrated Containers Engine?](../vic_overview/introduction.md#whats_vic_for) in *Overview of vSphere Integrated Containers*. 

After you deploy the vSphere Integrated Containers appliance, you download the vSphere Integrated Containers Engine bundle from the appliance to your usual working machine. The vSphere Integrated Containers Engine bundle includes the `vic-machine` CLI utility. You use `vic-machine` to deploy and manage virtual container hosts (VCHs) at the command line. 

The HTML5 vSphere Client plug-in for vSphere Integrated Containers allows you to deploy VCHs interactively from the vSphere Client.

* [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md)
* [Using the `vic-machine` CLI Utility](using_vicmachine.md)
* [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md)
* [Deploy Virtual Container Hosts in the HTML5 vSphere Client](deploy_vch_client.md)
* [Deploy a Virtual Container Host for Use with `dch-photon`](deploy_vch_dchphoton.md)