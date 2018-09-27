<!-- THIS TOPIC IS LINKED FROM THE appliance welcome page / UI -->

# Virtual Container Host Deployment #

In vSphere Integrated Containers, you deploy virtual container hosts (VCHs) that serve as Docker API endpoints. VCHs allow Docker developers to provision containers as VMs in your vSphere environment. For a description of the role and function of VCHs, see [Introduction to vSphere Integrated Containers Engine](../vic_overview/intro_to_vic_engine.md). 

After you deploy the vSphere Integrated Containers appliance, you download the vSphere Integrated Containers Engine bundle from the appliance to your usual working machine. The vSphere Integrated Containers Engine bundle includes the `vic-machine` CLI utility. You use `vic-machine` to deploy and manage VCHs at the command line. 

The HTML5 vSphere Client plug-in for vSphere Integrated Containers allows you to deploy VCHs interactively from the vSphere Client.

- [Using the `vic-machine` CLI Utility](using_vicmachine.md)
- [Open the Required Ports on ESXi Hosts](open_ports_on_hosts.md)
- [Obtain vSphere Certificate Thumbprints](obtain_thumbprint.md)
- [Virtual Container Host Certificate Requirements](vch_cert_reqs.md)
- [Create the Operations User Account](create_ops_user.md)
- [Deploy Virtual Container Hosts in the vSphere Client](deploy_vch_client.md)
- [Virtual Container Host Deployment Options](vch_deployment_options.md) 
- [Deploy a Test VCH](deploy_test_vch.md)
- [Virtual Container Hosts Sizing Guidelines](vch_sizing_guidelines.md)