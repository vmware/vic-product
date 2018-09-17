# Deployment Topologies for the vSphere Integrated Containers Appliance #

You can deploy multiple vSphere Integrated Containers appliances to the same vCenter Server instance. 

- [Deployment Examples for vSphere Integrated Containers Registry](#examples)
  - [Two-Way Image Replication](#replication) 
  - [User Roles](#roles)
  - [Hub and Spoke Configuration](#hub)
  - [Separate Development from Production](#dev-prod)
- [vSphere Integrated Containers Plug-in and Multiple Appliance Deployments](#client) 

## Deployment Examples for vSphere Integrated Containers Registry <a id="examples"></a>

The main reason why you might deploy multiple vSphere Integrated Containers appliances is to take advantage of the image replication and user management features that vSphere Integrated Containers Registry provides.

For information about image replication between registries, see [Replicating Images](../vic_cloud_admin/replicating_images.md) in *vSphere Integrated Containers Management Portal Administration*.

For information about users and user access, see [vSphere Integrated Containers Roles and Personas](../vic_overview/roles_and_personas.md)  in *Overview of vSphere Integrated Containers* and [Working with Projects](../vic_cloud_admin/working_with_projects.md) in *vSphere Integrated Containers Management Portal Administration*.

The following sections provide some examples of typical deployment topologies. The examples are not exhaustive. 

### Two-Way Image Replication <a id="replication"></a>

You can deploy two vSphere Integrated Containers appliances and use the vSphere Integrated Containers Registry instance in each one as the image replication endpoint for the other. 

### User Roles <a id="roles"></a>

If a Platform Services Controller manages multiple vCenter Server instances, you can deploy multiple appliances to different vCenter Server instances that share that Platform Services Controller. This setup provides the following advantages:

- All of the user accounts that are configured in the Platform Services Controller are available to all of the vSphere Integrated Containers appliances. 
- You can assign different roles to the same user account in different instances of the appliance. For example, a user can be a vSphere Integrated Containers Management Portal administrator for one appliance, but not for another.

### Hub and Spoke Configuration <a id="hub"></a>

In a large vSphere environment, in which not all vCenter Server instances are located in the same place, or are not all in the same vCenter Single Sign On domain, you can create a hub and spoke configuration: 

- You deploy one vSphere Integrated Containers appliance to a vCenter Server instance in a centralized location. This appliance acts as a hub. 
- You deploy one vSphere Integrated Containers appliance to each of the remote vCenter Server instances.
- You configure image replication between the registry in the central hub the vSphere Integrated Containers Registry instances in each location.

In this way, all of the remote locations have access to all of the images from the registry in the central hub. Remote locations benefit from data proximity when pulling images from their local registry. You must add the same users to projects on the different vSphere Integrated Containers instances.

### Separate Development from Production <a id="dev-prod"></a>

You can use the registries in different appliances to manage images that are under development, being tested, and are ready for production. For example:

|**Registry**|**Push/Pull**|**Used For**|**Replicates To**|
|---|---|---|---|
|`Registry_1`|Push and pull|Image development and builds|`Registry_2`|
|`Registry_2`|Pull only|Quality testing of newly developed and built images|`Registry_3`|
|`Registry_3`|Pull only|Staging for images that have passed quality testing|`Registry_4`|
|`Registry_4`|Pull only|Location from which images are deployed from staging to production|Spokes|

In this example, `Registry_4` could act as the hub in a hub and spoke configuration, for operations with many different physical locations.

## vSphere Integrated Containers Plug-in and Multi-Appliance Deployments <a id="client"></a>

The vSphere Integrated Containers plug-in for the vSphere Client allows you to deploy virtual container hosts (VCHs) from the vSphere Client. The vSphere Integrated Containers plug-in deploys VCHs by calling on the `vic-machine` API server that runs in a vSphere Integrated Containers appliance.

In an environment in which multiple vSphere Integrated Containers appliances are deployed to the same vCenter Server instance, the vSphere Integrated Containers plug-in connects to the API server in one appliance only. The version of the client plug-in must correspond to the version of the appliance. However, the appliance that the client connects to might not be the one that was most recently registered with vCenter Server. Consequently, if you deploy different versions of the appliance to vCenter Server, you might or might not want to install the latest version of the client plug-in.

For information about installing the vSphere Integrated Containers plug-in, see [Deploy the vSphere Integrated Containers Appliance](../vic_vsphere_admin/deploy_vic_appliance.md).

For information about how to find the versions of the client plug-in and the appliance instance to which it is connected, see [View vSphere Integrated Containers Information in the HTML5 vSphere Client](../vic_vsphere_admin/access_h5_ui.md).