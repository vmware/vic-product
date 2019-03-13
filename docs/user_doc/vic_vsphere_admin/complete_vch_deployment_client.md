# Finish VCH Deployment in the vSphere Client #

When you have completed all of the pages in the Create Virtual Container Host wizard, you can review the details of the virtual container host (VCH) that you have configured. You can also copy the generated `vic-machine create` command. 

## Prerequisites

You completed all of the pages of the Create Virtual 
Container Host wizard in the vSphere Client.

## Procedure

1. In the Summary page, review the details of the VCH that you have configured.

    Expand the entries as necessary to see more configuration details.
2. Scroll down to the bottom of the page to see the generated `vic-machine create` command that results from the configuration that you have specified in the wizard.
3. (Optional) Select a platform from the **Copy CLI command** drop-down menu, and click the clipboard icon to copy the command to the clipboard.

    Copying the `vic-machine create` command allows you to recreate similar VCHs at the command line or by using scripting. The platform that you select corresponds to the system on which you run `vic-machine` commands.
4. Click **Finish** to deploy the VCH.
5. In the **Virtual Container Hosts** tab, click the **>** icon next to the new VCH to follow its deployment progress.

    At the end of a successful deployment, you can see the connection details for this VCH in the Virtual Container Hosts view.
6. (Optional) When the deployment has succeeded, click the link to the VCH Admin Portal for this VCH.

**NOTE**: The Create Virtual Container Host wizard does not include any escape characters in the generated `vic-machine` command. Consequently, if any of the values that you specified in the wizard include special characters or spaces, you must edit the saved `vic-machine` command to wrap those values in quotes before you can reuse the command to create similar VCHs. For information about using quotes to escape special characters and spaces, see Specifying Option Arguments in [Using the `vic-machine` CLI Utility](using_vicmachine.md#args). 

## What to Do Next

- To experiment further with deploying VCHs, follow the procedures in [Deploy a Virtual Container Host to an ESXi Host with No vCenter Server](deploy_vch_esxi.md) or [Deploy a Virtual Container Host with a Volume Store and vSphere Integrated Containers Registry Access](deploy_vch_dchphoton.md). 
- To manage the VCHs that you have deployed, see [Virtual Container Host Administration](vch_admin.md).
- To register your VCHs with vSphere Integrated Containers Management Portal, see [Add Container Hosts to Projects](../vic_cloud_admin/vchs_and_mgmt_portal.md) in *vSphere Integrated Containers Management Portal Administration*.

## Troubleshooting

If you see errors during deployment, see [Troubleshoot Virtual Container Host Deployment](ts_deploy_vch.md).

For information about how to access VCH logs, including the deployment log, see [Access Virtual Container Host Log Bundles](log_bundles.md).