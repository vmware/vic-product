# Summary

## vSphere Integrated Containers 1.1


----


* [Introduction](README.md)
* [Quick Start Links](vic_quickstart.md)
* 

----


* [vSphere Administrators](vic_vsphere_admin/README.md)
  * [Overview for vSphere Admins](vic_vsphere_admin/introduction.md)
    * [Interoperability](vic_vsphere_admin/interop.md)
    * [Networking](vic_vsphere_admin/networks.md)
  * [Installation](vic_vsphere_admin/installing_vic.md)
    * [Download](vic_vsphere_admin/download_vic.md) 
    * [Deploy the Appliance](vic_vsphere_admin/deploy_vic_appliance.md)
    * [Installing the Plug-ins](vic_vsphere_admin/install_vic_plugin.md)
      * [vCenter Server for Windows](vic_vsphere_admin/plugins_vc_windows.md)
      * [vCenter Server Appliance](vic_vsphere_admin/plugins_vcsa.md)
      * [Access the vSphere Integrated Containers View](vic_vsphere_admin/access_h5_ui.md)
      * [Find VCH Information](vic_vsphere_admin/vch_portlet_ui.md)
      * [Find Container Information](vic_vsphere_admin/container_portlet_ui.md)
  * [Deploy VCHs](vic_vsphere_admin/deploy_vch.md)
    * [Contents of the vSphere Integrated Containers Engine Binaries](vic_vsphere_admin/contents_of_vic_binaries.md)
    * [Environment Prerequisites for VCH Deployment](vic_vsphere_admin/vic_installation_prereqs.md)
    * [Open the Required Ports on ESXi Hosts](vic_vsphere_admin/open_ports_on_hosts.md)
    * [Deploy a VCH to an ESXi Host with No vCenter Server](vic_vsphere_admin/deploy_vch_esxi.md)
    * [Deploy a VCH to a Basic vCenter Server Cluster](vic_vsphere_admin/deploy_vch_vcenter.md)
    * [Verify the Deployment of a VCH](vic_vsphere_admin/verify_vch_deployment.md)
    * [VCH Deployment Options](vic_vsphere_admin/vch_installer_options.md)
    * [Advanced Examples of Deploying a VCH](vic_vsphere_admin/vch_installer_examples.md)
    * [Deploy a VCH for Use with vSphere Integrated Containers Registry](vic_vsphere_admin/deploy_vch_registry.md)
    * [Use Different User Accounts for VCH Deployment and Operation](vic_vsphere_admin/set_up_ops_user.md)
  * [Manage VCHs](vic_vsphere_admin/vch_admin.md)
    * [Obtain Version Information](vic_vsphere_admin/vic_machine_version.md)
    * [Common Options](vic_vsphere_admin/common_vic_options.md)
    * [List VCHs](vic_vsphere_admin/list_vch.md)
    * [Obtain VCH Information](vic_vsphere_admin/inspect_vch.md)
    * [Delete a VCH](vic_vsphere_admin/remove_vch.md)
       * [VCH Delete Options](vic_vsphere_admin/delete_vch_options.md)
    * [Access the VCH Admin Portal](vic_vsphere_admin/access_vicadmin.md)
      * [Browser-Based Certificate Login](vic_vsphere_admin/browser_login.md)
      * [Command Line Certificate Login](vic_vsphere_admin/cmdline_login.md)
      * [VCH Admin Status Reference](vic_vsphere_admin/vicadmin_status_ref.md)
    * [Access Log Bundles](vic_vsphere_admin/log_bundles.md)
    * [Debugging the VCH](vic_vsphere_admin/debug_vch.md)
      * [Enable Shell Access](vic_vsphere_admin/vch_shell_access.md)
      * [Authorize SSH Access](vic_vsphere_admin/vch_ssh_access.md) 
      * [VCH Debug Options](vic_vsphere_admin/debug_vch_options.md)
  * [Upgrading](vic_vsphere_admin/upgrading_vic.md)
     * [Upgrade the Appliance](vic_vsphere_admin/upgrade_appliance.md)
     * [Upgrade VCHs](vic_vsphere_admin/upgrade_vch.md)
       * [VCH Upgrade Options](vic_vsphere_admin/upgrade_vch_options.md)
     * [Upgrade the HTML5 Plug-In](vic_vsphere_admin/upgrade_h5_plugin.md)
     * [Upgrade 0.5 Registry](vic_vsphere_admin/upgrade_registry.md)
  * [Troubleshooting vSphere Integrated Containers](vic_vsphere_admin/troubleshoot_vic.md)
    * [Check Service Status](vic_vsphere_admin/service_status.md)
    * [Restart Services](vic_vsphere_admin/restart_services.md)
    * [VCH Deployment Times Out](vic_vsphere_admin/ts_vch_deployment_timeout.md)
    * [Certificate Verification Error](vic_vsphere_admin/ts_thumbprint_error.md)
    * [Missing Common Name Error Even When TLS Options Are Specified Correctly](vic_vsphere_admin/ts_cli_argument_error.md)
    * [Firewall Validation Error](vic_vsphere_admin/ts_firewall_error.md)
    * [Certificate cname Mismatch](vic_vsphere_admin/ts_cname_mismatch.md)
    * [Docker API Endpoint Check Failed Error](vic_vsphere_admin/ts_docker_api_check_error.md)
    * [No Single Host Can Access All Datastores](vic_vsphere_admin/ts_datastore_access_error.md)
    * [Plug-In Does Not Appear](vic_vsphere_admin/ts_ui_not_appearing.md)
    * [Deleting or Inspecting a VCH Fails](vic_vsphere_admin/ts_delete_inspect_error.md)
    * [Certificate Errors when Using Full TLS Authentication with Trusted Certificates](vic_vsphere_admin/ts_clock_skew.md)
  * [Security Reference](vic_vsphere_admin/security_reference.md)


----


* [DevOps Administrators](vic_dev_ops/README.md)
    * [Overview for DevOps Admins](vic_dev_ops/overview_of_vic_devops.md)
    * [Managing Images, Projects, Users](vic_dev_ops/using_registry.md)
      * [Configure a Registry](vic_dev_ops/configure_registry.md)
      * [Create Users](vic_dev_ops/creating_users_registry.md)
      * [Assign the Administrator Role](vic_dev_ops/assign_admin_role.md)
      * [Create a Project](vic_dev_ops/creating_projects_registry.md)
        * [Assign Users to a Project](vic_dev_ops/add_users_registry.md)
        * [Manage Project Members](vic_dev_ops/manage_project_members.md)
        * [Manage Projects](vic_dev_ops/manage_projects.md)
        * [Access Project Logs](vic_dev_ops/access_project_logs.md)
      * [Building and Pushing Images](vic_app_dev/build_push_images.md)
      * [Manage Repositories](vic_dev_ops/manage_repository_registry.md)
      * [Replicating Images](vic_dev_ops/replicating_images.md)
        * [Create Replication Endpoints](vic_dev_ops/create_replication_endpoints.md)
        * [Create Replication Rules](vic_dev_ops/create_replication_rules.md)
        * [Manage Replication Endpoints](vic_dev_ops/manage_replication_endpoints.md)
    * [View and Manage VCHs, Add Registries, and Provision Containers Through the Management Portal](vic_dev_ops/vchs_and_mgmt_portal.md)
      * [Add Hosts with No TLS Authentication to the Management Portal](vic_dev_ops/add_vch_noTLS_in_portal.md)
      * [Add Hosts with Server-Side TLS Authentication to the Management Portal](vic_dev_ops/add_vch_serversideTLS_in_portal.md)
      * [Add Hosts with Full TLS Authentication to the Management Portal](vic_dev_ops/add_vch_fullTLS_in_portal.md)
      * [Create and Manage Container Placements](vic_dev_ops/creating_placements.md)
      * [Create New Networks for Provisioning Containers](vic_dev_ops/create_network.md)
      * [Add Registries to the Management Portal](vic_dev_ops/add_repos_in_portal.md)
      * [Provisioning Container VMs in the Management Portal](vic_dev_ops/provision_containers_portal.md)
       * [Configuring Links for Templates and Images](vic_dev_ops/configuring_links.md)
       * [Configuring Health Checks for Templates and Images](vic_dev_ops/configuring_health_checks.md)
       * [Configuring Cluster Size and Scale](vic_dev_ops/configuring_clusters.md)


----


* [Container App Developers](vic_app_dev/README.md)
  * [Overview for Developers](vic_app_dev/overview_of_vic_appdev.md)
  * [Supported Docker Commands](vic_app_dev/container_operations.md)
    * [Supported Docker Compose File Options](vic_app_dev/docker_compose_file_options.md)
  * [Use and Limitations](vic_app_dev/container_limitations.md)
  * [Obtain a VCH](vic_app_dev/obtain_vch.md)
  * [Configure the Docker Client](vic_app_dev/configure_docker_client.md)
  * [Building and Pushing Images](vic_app_dev/build_push_images.md)
  * [Using Volumes](vic_app_dev/using_volumes_with_vic.md) 
  * [Container Networking](vic_app_dev/network_use_cases.md)
  * [Creating a Containerized App](vic_app_dev/creating_containerized_app_with_vic.md)
    * [Docker Compose Constraints](vic_app_dev/constraints_using_compose.md)
    * [Example of Building an App](vic_app_dev/build_app_with_vic.md)
  * [Default Volume Store Error](vic_app_dev/ts_volume_store_error.md)


----


* [Send Doc Feedback](vic_vsphere_admin/feedback.md)
* [Printable PDFs](pdf.md)