<!-- THIS TOPIC IS LINKED FROM THE GETTING STARTED PAGE / UI -->

# Deploy Virtual Container Hosts #

In vSphere Integrated Containers, you deploy virtual container hosts (VCHs) that serve as Docker API endpoints. VCHs allow Docker developers to provision containers as VMs in your vSphere environment. For a description of the role and function of VCHs, see [Introduction to vSphere Integrated Containers Engine](../vic_overview/intro_to_vic_engine.md). 

After you deploy the vSphere Integrated Containers appliance, you download the vSphere Integrated Containers Engine bundle from the appliance to your usual working machine. The vSphere Integrated Containers Engine bundle includes the `vic-machine` CLI utility. You use `vic-machine` to deploy and manage VCHs at the command line. 

The HTML5 vSphere Client plug-in for vSphere Integrated Containers allows you to deploy VCHs interactively from the vSphere Client.

- [Using the `vic-machine` CLI Utility](using_vicmachine.md)
- [Deploy Virtual Container Hosts in the vSphere Client](deploy_vch_client.md)
- [General Settings](vch_general_settings.md)
- [Compute Capacity](vch_compute.md)
- [Storage Capacity](vch_storage.md)
- [Networks](vch_networking.md)
- [Security](vch_security.md)
- [Operations User](set_up_ops_user.md)
- [Finish VCH Deployment in the vSphere Client](complete_vch_deployment_client.md)
- [Deploy a Virtual Container Host for Use with `dch-photon`](deploy_vch_dchphoton.md)